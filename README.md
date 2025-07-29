# Microserviço API - Infraestrutura

Este projeto contém a infraestrutura como código (IaC) para deploy do microserviço de API usando Terraform e AWS.

## 🚀 Deploy Automático via GitHub Actions

### Trigger Manual
1. Vá para **Actions** → **Deploy Infrastructure**
2. Clique em **Run workflow**
3. Configure:
   - **Docker image tag**: Tag da imagem (ex: `pr-3`, `latest`)
   - **Environment**: `dev`, `staging`, ou `prod`
   - **Action**: `plan`, `apply`, ou `destroy`

### Trigger Automático
O deploy é disparado automaticamente quando:
- Uma nova imagem é construída no repositório da API
- Push na branch `main` (apenas para dev)

## 🔧 Deploy Local

### Pré-requisitos

1. **AWS CLI** configurado com suas credenciais
2. **Terraform** instalado (>= 1.0)
3. **Chave SSH** criada no AWS Console
4. **Bucket S3** para Terraform state (opcional)

### Configuração

1. Clone o repositório:
```bash
git clone <seu-repositorio>
cd IAC_Microservico
```

2. Copie o arquivo de exemplo:
```bash
cp infra/terraform.tfvars.example infra/terraform.tfvars
```

3. Edite o `terraform.tfvars` com seus valores:
```bash
nano infra/terraform.tfvars
```

### Valores a configurar:

- `key_name`: Nome da sua chave SSH criada no AWS Console
- `region`: Região AWS desejada
- `docker_image`: Sua imagem Docker (já configurada)

### Deploy

```bash
cd infra
terraform init
terraform plan
terraform apply
```

## 🌐 Acesso

Após o deploy, use o comando SSH mostrado no output:
```bash
ssh -i ~/.ssh/SUA_CHAVE.pem ubuntu@IP_PUBLICO
```

**URL da aplicação:** `http://IP_PUBLICO:8080`

## 🧹 Limpeza

Para destruir a infraestrutura:
```bash
terraform destroy
```

Ou via GitHub Actions com action `destroy`.

## 🔐 Secrets Necessários

Configure os seguintes secrets no GitHub:

### Repository Secrets:
- `AWS_ACCESS_KEY_ID`: Sua AWS Access Key
- `AWS_SECRET_ACCESS_KEY`: Sua AWS Secret Key  
- `AWS_REGION`: Região AWS (ex: `us-west-2`)
- `AWS_KEY_NAME`: Nome da sua chave SSH no AWS

### Repository Variables (opcional):
- `INSTANCE_TYPE`: Tipo da instância EC2 (padrão: `t3.micro`)

## 📁 Estrutura do Projeto

```
infra/
├── main.tf              # Recursos principais
├── variables.tf         # Variáveis
├── outputs.tf          # Outputs
├── user-data.sh        # Script de inicialização
├── backend.tf          # Backend remoto (opcional)
└── terraform.tfvars.example
```