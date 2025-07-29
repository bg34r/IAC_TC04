#!/bin/bash

# Update system
apt-get update -y

# Install required packages
apt-get install -y \
    curl \
    wget \
    unzip \
    htop \
    git

# Install MySQL Server
apt-get install -y mysql-server

# Start and enable MySQL
systemctl start mysql
systemctl enable mysql

# Secure MySQL installation (basic setup)
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${DB_PASS}';"
mysql -e "DELETE FROM mysql.user WHERE User='';"
mysql -e "DROP DATABASE IF EXISTS test;"
mysql -e "FLUSH PRIVILEGES;"

# Create database for the application - usando as configurações do .env
mysql -u root -p${DB_PASS} -e "CREATE DATABASE IF NOT EXISTS lanchonete;"
mysql -u root -p${DB_PASS} -e "FLUSH PRIVILEGES;"

# Install Go
GO_VERSION="1.22.0"
wget https://go.dev/dl/go$GO_VERSION.linux-amd64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go$GO_VERSION.linux-amd64.tar.gz

# Set Go environment variables globally
echo 'export PATH=$PATH:/usr/local/go/bin' >> /etc/profile
echo 'export PATH=$PATH:/usr/local/go/bin' >> /home/ubuntu/.bashrc
echo 'export GOPATH=/home/ubuntu/go' >> /etc/profile
echo 'export GOPATH=/home/ubuntu/go' >> /home/ubuntu/.bashrc
echo 'export GOMODCACHE=/home/ubuntu/go/pkg/mod' >> /etc/profile
echo 'export GOMODCACHE=/home/ubuntu/go/pkg/mod' >> /home/ubuntu/.bashrc
echo 'export GOCACHE=/home/ubuntu/go/cache' >> /etc/profile
echo 'export GOCACHE=/home/ubuntu/go/cache' >> /home/ubuntu/.bashrc
echo 'export HOME=/home/ubuntu' >> /etc/profile

# Set Go environment for current session
export PATH=$PATH:/usr/local/go/bin
export GOPATH=/home/ubuntu/go
export GOMODCACHE=/home/ubuntu/go/pkg/mod
export GOCACHE=/home/ubuntu/go/cache
export HOME=/home/ubuntu

# Create Go workspace directory
mkdir -p /home/ubuntu/go/pkg/mod
mkdir -p /home/ubuntu/go/cache
chown -R ubuntu:ubuntu /home/ubuntu/go

# Log Go installation
echo "Go installation:" >> /var/log/deployment.log
/usr/local/go/bin/go version >> /var/log/deployment.log 2>&1
echo "GOPATH: $GOPATH" >> /var/log/deployment.log
echo "GOMODCACHE: $GOMODCACHE" >> /var/log/deployment.log
echo "GOCACHE: $GOCACHE" >> /var/log/deployment.log
echo "HOME: $HOME" >> /var/log/deployment.log

# Create application directory
mkdir -p /opt/microservico-api
cd /opt/microservico-api

# Clone your repository
echo "Cloning repository..." >> /var/log/deployment.log
git clone ${api_repo_url} . >> /var/log/deployment.log 2>&1

# Check if clone was successful
if [ ! -f "main.go" ]; then
    echo "ERROR: main.go not found after git clone" >> /var/log/deployment.log
    ls -la . >> /var/log/deployment.log
    exit 1
fi

# Create .env file for the application
cat > /opt/microservico-api/.env << EOF
APP_ENV=${APP_ENV}
SERVER_ADDRESS=${SERVER_ADDRESS}
PORT=${PORT}
CONTEXT_TIMEOUT=${CONTEXT_TIMEOUT}
DB_HOST=${DB_HOST}
DB_PORT=${DB_PORT}
DB_USER=${DB_USER}
DB_PASS=${DB_PASS}
DB_NAME=${DB_NAME}
PRODUTO_QUEUE_URL=${PRODUTO_QUEUE_URL}
CLIENTE_QUEUE_URL=${CLIENTE_QUEUE_URL}
PEDIDO_QUEUE_URL=${PEDIDO_QUEUE_URL}
ACCESS_TOKEN_EXPIRY_HOUR=${ACCESS_TOKEN_EXPIRY_HOUR}
REFRESH_TOKEN_EXPIRY_HOUR=${REFRESH_TOKEN_EXPIRY_HOUR}
ACCESS_TOKEN_SECRET=${ACCESS_TOKEN_SECRET}
REFRESH_TOKEN_SECRET=${REFRESH_TOKEN_SECRET}
EOF

# Set proper permissions for .env
chmod 600 /opt/microservico-api/.env
chown ubuntu:ubuntu /opt/microservico-api/.env

# Build the application com todas as variáveis de ambiente
echo "Building application..." >> /var/log/deployment.log
echo "Current environment:" >> /var/log/deployment.log
env | grep -E "GO|HOME" >> /var/log/deployment.log

# Download dependencies first
HOME=/home/ubuntu GOPATH=/home/ubuntu/go GOMODCACHE=/home/ubuntu/go/pkg/mod GOCACHE=/home/ubuntu/go/cache /usr/local/go/bin/go mod download >> /var/log/deployment.log 2>&1

# Build the application
HOME=/home/ubuntu GOPATH=/home/ubuntu/go GOMODCACHE=/home/ubuntu/go/pkg/mod GOCACHE=/home/ubuntu/go/cache /usr/local/go/bin/go build -v -o microservico-api main.go >> /var/log/deployment.log 2>&1

# Check if build was successful
if [ ! -f "microservico-api" ]; then
    echo "ERROR: Build failed, executable not created" >> /var/log/deployment.log
    echo "Directory contents:" >> /var/log/deployment.log
    ls -la . >> /var/log/deployment.log
    echo "Go module info:" >> /var/log/deployment.log
    HOME=/home/ubuntu GOPATH=/home/ubuntu/go GOMODCACHE=/home/ubuntu/go/pkg/mod GOCACHE=/home/ubuntu/go/cache /usr/local/go/bin/go mod tidy >> /var/log/deployment.log 2>&1
    exit 1
fi

# Set proper permissions
chown -R ubuntu:ubuntu /opt/microservico-api
chmod +x /opt/microservico-api/microservico-api

# Verify executable
echo "Executable info:" >> /var/log/deployment.log
ls -la /opt/microservico-api/microservico-api >> /var/log/deployment.log
file /opt/microservico-api/microservico-api >> /var/log/deployment.log

# Create systemd service
cat > /etc/systemd/system/microservico-api.service << 'EOF'
[Unit]
Description=Microservico API
After=network.target mysql.service
Requires=mysql.service

[Service]
Type=simple
User=ubuntu
WorkingDirectory=/opt/microservico-api
ExecStart=/opt/microservico-api/microservico-api
Restart=always
RestartSec=5
EnvironmentFile=/opt/microservico-api/.env
Environment=HOME=/home/ubuntu
Environment=GOPATH=/home/ubuntu/go
Environment=GOMODCACHE=/home/ubuntu/go/pkg/mod
Environment=GOCACHE=/home/ubuntu/go/cache

[Install]
WantedBy=multi-user.target
EOF

# Start and enable the service
systemctl daemon-reload
systemctl enable microservico-api
systemctl start microservico-api

# Wait a bit for service to start
sleep 5

# Create health check script
cat > /home/ubuntu/health-check.sh << 'EOF'
#!/bin/bash
curl -f http://localhost:8080/health || curl -f http://localhost:8080/ || exit 1
EOF

chmod +x /home/ubuntu/health-check.sh
chown ubuntu:ubuntu /home/ubuntu/health-check.sh

# Log the deployment
echo "Deployment completed at $(date)" >> /var/log/deployment.log
echo "Go version: $(/usr/local/go/bin/go version)" >> /var/log/deployment.log
echo "MySQL version: $(mysql --version)" >> /var/log/deployment.log

# Final check
echo "Services status:" >> /var/log/deployment.log
systemctl is-active mysql >> /var/log/deployment.log
systemctl is-active microservico-api >> /var/log/deployment.log

# Test database connection com as credenciais corretas
mysql -u root -p${DB_PASS} -e "SELECT 1;" >> /var/log/deployment.log 2>&1

# Test application
echo "Testing application:" >> /var/log/deployment.log
curl -s http://localhost:8080 >> /var/log/deployment.log 2>&1 || echo "Application not responding yet" >> /var/log/deployment.log