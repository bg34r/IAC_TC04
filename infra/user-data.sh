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

# Secure MySQL installation (basic setup) - usando a senha do .env
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${DB_PASS}';"
mysql -e "DELETE FROM mysql.user WHERE User='';"
mysql -e "DROP DATABASE IF EXISTS test;"
mysql -e "FLUSH PRIVILEGES;"

# Create database for the application - usando as configurações do .env
mysql -u root -p${DB_PASS} -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME};"
mysql -u root -p${DB_PASS} -e "FLUSH PRIVILEGES;"

# Install Go
GO_VERSION="1.23.4"
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
echo "Creating .env file..." >> /var/log/deployment.log
cat > /opt/microservico-api/.env << EOF
APP_ENV=${APP_ENV}
SERVER_ADDRESS=${PORT}
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

# Fix permissions for Go directories
chown -R ubuntu:ubuntu /home/ubuntu/go
chmod -R 755 /home/ubuntu/go

# Build as ubuntu user to avoid permission issues
echo "Building as ubuntu user..." >> /var/log/deployment.log

# Remove old cache to avoid permission issues
rm -rf /home/ubuntu/go/cache/* 2>/dev/null || true
rm -rf /home/ubuntu/go/pkg/mod/cache/* 2>/dev/null || true

# Fix all permissions recursively
chown -R ubuntu:ubuntu /home/ubuntu/go
chown -R ubuntu:ubuntu /opt/microservico-api
chmod -R 755 /home/ubuntu/go

sudo -u ubuntu bash -c '
    export HOME=/home/ubuntu
    export GOPATH=/home/ubuntu/go
    export GOMODCACHE=/home/ubuntu/go/pkg/mod
    export GOCACHE=/home/ubuntu/go/cache
    export PATH=$PATH:/usr/local/go/bin
    cd /opt/microservico-api
    
    # Clean any existing builds
    rm -f microservico-api
    
    # Download dependencies
    /usr/local/go/bin/go mod download >> /var/log/deployment.log 2>&1
    
    # Build the application
    /usr/local/go/bin/go build -v -o microservico-api main.go >> /var/log/deployment.log 2>&1
' || echo "Build completed with sudo -u ubuntu"

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
StandardOutput=append:/var/log/microservico-api.log
StandardError=append:/var/log/microservico-api-error.log

[Install]
WantedBy=multi-user.target
EOF

# Start and enable the service
systemctl daemon-reload
systemctl enable microservico-api

# Stop any existing service first
systemctl stop microservico-api 2>/dev/null || true

# Try to start the service and capture detailed logs
echo "Starting microservico-api service..." >> /var/log/deployment.log
systemctl start microservico-api

# Wait longer for service to start
sleep 15

# Force restart to ensure .env changes are loaded
echo "Restarting service to load .env changes..." >> /var/log/deployment.log
systemctl restart microservico-api
sleep 10

# Check service status immediately
echo "Service status immediately after start:" >> /var/log/deployment.log
systemctl status microservico-api --no-pager -l >> /var/log/deployment.log

# Check if service is actually running
if systemctl is-active --quiet microservico-api; then
    echo "Service is running successfully" >> /var/log/deployment.log
else
    echo "Service failed to start. Detailed diagnosis:" >> /var/log/deployment.log
    systemctl is-failed microservico-api >> /var/log/deployment.log
    echo "Service logs from journalctl:" >> /var/log/deployment.log
    journalctl -u microservico-api --no-pager -l --since "1 minute ago" >> /var/log/deployment.log
fi

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

# Check network configuration
echo "Network configuration:" >> /var/log/deployment.log
ip addr show >> /var/log/deployment.log
echo "Listening ports:" >> /var/log/deployment.log
netstat -tlnp >> /var/log/deployment.log

# Final check
echo "Services status:" >> /var/log/deployment.log
systemctl is-active mysql >> /var/log/deployment.log
systemctl is-active microservico-api >> /var/log/deployment.log

# Check if application is binding to correct address
echo "Checking application binding:" >> /var/log/deployment.log
ss -tlnp | grep :8080 >> /var/log/deployment.log || echo "Application not listening on port 8080" >> /var/log/deployment.log

# Check firewall status
echo "Firewall status:" >> /var/log/deployment.log
ufw status >> /var/log/deployment.log || echo "UFW not active"

# Test database connection com as credenciais corretas
mysql -u root -p${DB_PASS} -e "SELECT 1;" >> /var/log/deployment.log 2>&1

# Test application
echo "Testing application:" >> /var/log/deployment.log

# Check if application is running
echo "Checking if microservico-api process is running:" >> /var/log/deployment.log
ps aux | grep microservico-api | grep -v grep >> /var/log/deployment.log

# Check what ports are listening
echo "Checking listening ports:" >> /var/log/deployment.log
netstat -tlnp | grep -E "(8080|3306)" >> /var/log/deployment.log

# Check systemd service logs
echo "Systemd service logs:" >> /var/log/deployment.log
journalctl -u microservico-api --no-pager -n 50 >> /var/log/deployment.log

# Manual test of the executable
echo "Testing executable manually:" >> /var/log/deployment.log
cd /opt/microservico-api
sudo -u ubuntu timeout 10 ./microservico-api >> /var/log/deployment.log 2>&1 || echo "Manual execution completed or timed out"

# Check if application logs exist
if [ -f "/var/log/microservico-api.log" ]; then
    echo "Application stdout logs:" >> /var/log/deployment.log
    tail -20 /var/log/microservico-api.log >> /var/log/deployment.log
fi

if [ -f "/var/log/microservico-api-error.log" ]; then
    echo "Application error logs:" >> /var/log/deployment.log
    tail -20 /var/log/microservico-api-error.log >> /var/log/deployment.log
fi

# Test local connectivity
echo "Testing local connectivity:" >> /var/log/deployment.log
curl -v http://localhost:8080 >> /var/log/deployment.log 2>&1 || echo "Local connection failed"

# Check .env file is readable by the service
echo "Checking .env file for service:" >> /var/log/deployment.log
sudo -u ubuntu cat /opt/microservico-api/.env >> /var/log/deployment.log

# Check if port 8080 is specifically listening
echo "Checking port 8080 specifically:" >> /var/log/deployment.log
ss -tlnp | grep :8080 >> /var/log/deployment.log || echo "Port 8080 not listening"

curl -s http://localhost:8080 >> /var/log/deployment.log 2>&1 || echo "Application not responding yet"