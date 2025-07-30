# Infraestrutura como Código (IaC) - Microserviço API

Este projeto implementa a infraestrutura como código (IaC) usando Terraform para provisionar e deployar um microserviço API na AWS.

## 📋 Visão Geral

O projeto automatiza o provisionamento de uma infraestrutura completa na AWS para hospedar um microserviço desenvolvido em Go, incluindo:

- **EC2 Instance** para hospedar a aplicação
- **MySQL Database** instalado e configurado automaticamente
- **Security Groups** para controle de acesso
- **Deployment automatizado** da aplicação Go
- **Systemd service** para gerenciamento da aplicação

## 🏗️ Arquitetura

```
┌─────────────────────────────────────────┐
│                AWS Cloud                │
│                                         │
│  ┌─────────────────────────────────────┐│
│  │            VPC Default              ││
│  │                                     ││
│  │  ┌─────────────────────────────────┐││
│  │  │         EC2 Instance            │││
│  │  │                                 │││
│  │  │  ┌─────────────────────────────┐│││
│  │  │  │      Microserviço API       ││││
│  │  │  │       (Go Application)      ││││
│  │  │  │        Port: 8080           ││││
│  │  │  └─────────────────────────────┘│││
│  │  │                                 │││
│  │  │  ┌─────────────────────────────┐│││
│  │  │  │      MySQL Database        ││││
│  │  │  │        Port: 3306           ││││
│  │  │  └─────────────────────────────┘│││
│  │  └─────────────────────────────────┘││
│  └─────────────────────────────────────┘│
│                                         │
│  ┌─────────────────────────────────────┐│
│  │        Security Group              ││
│  │  - HTTP (80)                       ││
│  │  - HTTPS (443)                     ││
│  │  - SSH (22)                        ││
│  │  - Custom (8080)                   ││
│  │  - MySQL (3306)                    ││
│  └─────────────────────────────────────┘│
└─────────────────────────────────────────┘
```

## 🚀 Tecnologias Utilizadas

- **Terraform** - Infraestrutura como Código
- **AWS EC2** - Computação em nuvem
- **AWS Security Groups** - Controle de acesso
- **Ubuntu 24.04** - Sistema operacional
- **Go 1.23.4** - Linguagem de programação da aplicação
- **MySQL** - Banco de dados
- **Systemd** - Gerenciamento de serviços
- **Git** - Controle de versão

## 📁 Estrutura do Projeto

```
IAC_Microservico/
├── env/
│   └── Prod/
│       ├── main.tf                    # Configuração do ambiente de produção
│       ├── terraform.tfstate          # Estado do Terraform (produção)
│       ├── terraform.tfstate.backup   # Backup do estado
│       └── terraform.tfvars           # Variáveis de produção
├── infra/
│   ├── Grupo_de_Seguranca.tf         # Configuração do Security Group
│   ├── main.tf                       # Configuração principal do Terraform
│   ├── outputs.tf                    # Outputs da infraestrutura
│   ├── variables.tf                  # Definição das variáveis
│   ├── terraform.tfvars              # Valores das variáveis
│   ├── terraform.tfvars.example      # Exemplo de configuração
│   ├── user-data.sh                  # Script de inicialização da instância
│   └── README.md                     # Este arquivo
└── microservico-api-key.pem         # Chave SSH para acesso à instância
```

## ⚙️ Pré-requisitos

1. **Terraform** instalado (versão >= 1.0)
2. **AWS CLI** configurado com credenciais válidas
3. **Chave SSH** criada na AWS
4. **Repositório da aplicação** disponível no GitHub

### Instalação do Terraform

```bash
# Ubuntu/Debian
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com releases main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Verificar instalação
terraform --version
```

### Configuração do AWS CLI

```bash
# Instalar AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configurar credenciais
aws configure
```

## 🛠️ Configuração

### 1. Clonar o Repositório

```bash
git clone <url-do-repositorio>
cd IAC_Microservico
```

### 2. Configurar Variáveis

Copie o arquivo de exemplo e configure suas variáveis:

```bash
cp infra/terraform.tfvars.example infra/terraform.tfvars
```

Edite o arquivo `infra/terraform.tfvars` com suas configurações:

```hcl
# Configurações da AWS
region                = "us-west-2"
instance_type        = "t3.micro"
key_name            = "sua-chave-aws"

# Configurações do projeto
project_name        = "microservico-api"
environment         = "dev"
api_repo_url        = "https://github.com/seu-usuario/seu-repositorio.git"

# Configurações da aplicação
app_env             = "production"
server_address      = "0.0.0.0"
port               = "8080"
context_timeout    = "30"

# Configurações do banco de dados
db_host            = "localhost"
db_port            = "3306"
db_user            = "root"
db_pass            = "sua-senha-mysql"
db_name            = "microservico_db"

# URLs das filas (se aplicável)
produto_queue_url  = ""
cliente_queue_url  = ""
pedido_queue_url   = ""

# Configurações de autenticação
access_token_expiry_hour  = "1"
refresh_token_expiry_hour = "24"
access_token_secret       = "seu-token-secreto"
refresh_token_secret      = "seu-refresh-token-secreto"
```

## 🚀 Deploy

### Deploy no Ambiente de Desenvolvimento

```bash
cd infra

# Inicializar o Terraform
terraform init

# Validar a configuração
terraform validate

# Planejar o deploy
terraform plan

# Aplicar as mudanças
terraform apply
```

### Deploy no Ambiente de Produção

```bash
cd env/Prod

# Inicializar o Terraform
terraform init

# Planejar o deploy
terraform plan

# Aplicar as mudanças
terraform apply
```

## 📊 Outputs

Após o deploy bem-sucedido, você receberá as seguintes informações:

- **instance_id**: ID da instância EC2
- **instance_public_ip**: IP público da instância
- **instance_public_dns**: DNS público da instância
- **security_group_id**: ID do grupo de segurança
- **ssh_command**: Comando para conectar via SSH
- **application_url**: URL da aplicação

## 🔍 Monitoramento e Logs

### Verificar Status da Aplicação

```bash
# Conectar via SSH
ssh -i microservico-api-key.pem ubuntu@<IP_PUBLICO>

# Verificar status do serviço
sudo systemctl status microservico-api

# Verificar logs da aplicação
sudo journalctl -u microservico-api -f

# Verificar logs de deployment
sudo tail -f /var/log/deployment.log
```

### Health Check

A aplicação expõe endpoints de health check:

```bash
# Verificar saúde da aplicação
curl http://<IP_PUBLICO>:8080/health

# Ou usar o script de health check
/home/ubuntu/health-check.sh
```

## 🛡️ Segurança

### Security Group Rules

O Security Group criado permite acesso nas seguintes portas:

- **22** (SSH) - Para administração
- **80** (HTTP) - Para redirecionamento
- **443** (HTTPS) - Para HTTPS
- **8080** (Custom) - Para a aplicação
- **3306** (MySQL) - Para o banco de dados

### Boas Práticas de Segurança

1. **Restrinja o CIDR blocks** para IPs específicos em produção
2. **Use senhas fortes** para o banco de dados
3. **Configure HTTPS** com certificados SSL
4. **Mantenha as chaves SSH seguras**
5. **Monitore os logs** regularmente

## 🔧 Troubleshooting

### Problemas Comuns

#### 1. Falha na Build da Aplicação

```bash
# Verificar logs de deployment
sudo tail -f /var/log/deployment.log

# Verificar se o Go está instalado corretamente
/usr/local/go/bin/go version

# Verificar se o repositório foi clonado
ls -la /opt/microservico-api/
```

#### 2. Serviço não Inicia

```bash
# Verificar status do serviço
sudo systemctl status microservico-api

# Verificar configuração do arquivo .env
sudo cat /opt/microservico-api/.env

# Reiniciar o serviço
sudo systemctl restart microservico-api
```

#### 3. Problemas de Conexão com o Banco

```bash
# Verificar status do MySQL
sudo systemctl status mysql

# Testar conexão com o banco
mysql -u root -p<senha> -e "SELECT 1;"

# Verificar se o banco foi criado
mysql -u root -p<senha> -e "SHOW DATABASES;"
```

## 🧹 Limpeza de Recursos

Para remover todos os recursos criados:

```bash
# No diretório do ambiente
terraform destroy

# Confirmar com 'yes' quando solicitado
```

## 📚 Recursos Adicionais

- [Documentação do Terraform](https://www.terraform.io/docs)
- [Documentação da AWS](https://docs.aws.amazon.com/)
- [Guia do Provider AWS para Terraform](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

## 🤝 Contribuição

1. Faça um fork do projeto
2. Crie uma branch para sua feature (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 👥 Autores

- **Seu Nome** - *Trabalho inicial* - [SeuUsuario](https://github.com/bg34r)

## 📞 Suporte

Se você encontrar algum problema ou tiver dúvidas, por favor abra uma [issue](https://github.com/bg34r/IAC_TC04/issues) no repositório do projeto.
