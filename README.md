# Repositório de Infraestrutura do Banco de Dados

Este repositório é responsável pela infraestrutura do banco de dados da aplicação Oficina Mecânica.

## Objetivo

- provisionar o banco de dados em ambiente controlado
- separar usuários, permissões e credenciais do restante da solução
- permitir deploy independente por ambiente
- minimizar riscos de infraestrutura e facilitar governança de dados

## Stack principal

- Terraform
- AWS
- PostgreSQL
- GitHub Actions

## Recursos provisionados

- instância ou serviço de banco em cloud
- usuários e permissões de acesso
- variáveis e secrets de conexão
- reproduzibilidade por ambiente (`homologacao` e `production`)

## Estrutura do repositório

```text
repo-db-infra/
├── .github/
│   └── workflows/
│       └── ci-cd.yml
├── README.md
├── database.tf
├── terraform.tfvars.example
├── variables.tf
└── .gitignore
```

## Fluxo recomendado

```text
feature/* -> PR -> homologacao -> deploy automático
feature/* -> PR -> main -> deploy automático em produção
```

## Branches

- `homologacao`
- `main`

## CI/CD

O workflow deste repositório executa:

1. validação do Terraform
2. `terraform fmt`
3. `terraform validate`
4. `terraform plan` em pull request
5. `terraform apply` em homologação e produção

## Secrets obrigatórios

- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_REGION`
- `DB_PASSWORD`

## Como usar

```bash
cp terraform.tfvars.example terraform.tfvars
# ajustar dados de conexão e senha
terraform init
terraform plan
terraform apply
```

## Observações

- não versionar senhas no código
- manter a infraestrutura isolada da aplicação principal
- o banco deve ser provisionado antes do deploy da aplicação que depende de conexão

## Regras de proteção

- commits diretos bloqueados
- merge somente via Pull Request
- status checks obrigatórios
- revisão mínima exigida
- bloqueio de force push
- bloqueio de exclusão da branch
