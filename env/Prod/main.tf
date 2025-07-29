module "aws-prod"{
    source = "../../infra"
    instance_type = "t3.micro"
    region = "us-west-2"
    key_name = "microservico-api-key"
    grupoDeSeguranca = "Producao"
    environment = "prod"
    project_name = "api_produtos_pedidos"
    api_repo_url = "https://github.com/bg34r/api_microservico.git"
}