# 🏢 Yii Gestor - Backend do Sistema Qui

[![PHP Version](https://img.shields.io/badge/PHP-8.1%2B-purple)](https://php.net)
[![Yii2 Version](https://img.shields.io/badge/Yii2-2.0.48-blue)](https://www.yiiframework.com)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

Backend RESTful API desenvolvido em Yii2 para o ecossistema **Qui**, composto pelos aplicativos quiPede, quiManda e quiGestor.

## 📋 Sobre o Projeto

O Yii Gestor é a API central que gerencia todo o ecossistema Qui, fornecendo endpoints seguros e eficientes para:

- **👤 Gestão de usuários** (gestores, lojistas, clientes)
- **🏪 Controle de lojas e produtos**
- **📦 Gerenciamento de pedidos**
- **📊 Relatórios e dashboards**

## 🚀 Tecnologias Utilizadas

- **Framework:** Yii2 PHP Framework
- **Banco de Dados:** MySQL 8.0
- **Autenticação:** JWT (JSON Web Tokens)
- **Documentação:** OpenAPI 3.0 (Swagger)
- **Ambiente:** Docker / Nginx / PHP-FPM

## 📁 Estrutura do Projeto

```
yii-gestor/
├── controllers/           # Controladores da API
│   ├── api/               
│   │   ├── gestor/        # Endpoints do Gestor
│   │   └── app/           # Endpoints do App
│   └── lojista/           # Endpoints do Lojista
├── models/                 # Models do banco de dados
├── migrations/             # Migrações do banco
├── config/                 # Configurações do Yii2
└── web/                    # Ponto de entrada
    └── .htaccess           # Configuração do Apache
```

## 🔧 Instalação

### Pré-requisitos
- PHP 8.1 ou superior
- MySQL 8.0
- Composer
- Apache/Nginx

### Passo a Passo

```bash
# Clone o repositório
git clone https://github.com/seu-usuario/yii-gestor.git
cd yii-gestor

# Instale as dependências
composer install

# Configure o banco de dados
cp config/db.php.example config/db.php
# Edite config/db.php com suas credenciais

# Execute as migrações
php yii migrate

# Configure o servidor web (Apache/Nginx)
# Aponte o document root para a pasta /web

# Pronto! Acesse: http://localhost:8001
```

## 📡 Endpoints da API

### Autenticação

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| `POST` | `/api/gestor/gestor-usuarios/login` | Login de gestor |
| `POST` | `/api/gestor/gestor-usuarios/create` | Criar novo gestor |
| `POST` | `/lojista/auth-lojista/login` | Login de lojista |
| `POST` | `/lojista/auth-lojista/create` | Criar novo lojista |

### Gestão

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| `GET` | `/api/gestor/dashboard` | Dados do dashboard |
| `GET` | `/api/gestor/gestor-usuarios` | Listar gestores |
| `PUT` | `/api/gestor/gestor-usuarios/{id}` | Atualizar gestor |
| `DELETE` | `/api/gestor/gestor-usuarios/{id}` | Deletar gestor |
| `GET` | `/api/gestor/lojas` | Listar lojas |
| `POST` | `/api/gestor/lojas` | Criar loja |

## 🔐 Autenticação JWT

A API utiliza JWT para autenticação. Após o login, o token deve ser enviado no header:

```http
Authorization: Bearer seu_token_jwt_aqui
```

## 📊 Exemplos de Requisições

### Login de Gestor

```bash
curl -X POST http://localhost:8001/api/gestor/gestor-usuarios/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "gestor@email.com",
    "senha": "123456"
  }'
```

**Resposta:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "nome": "Gestor Teste",
    "email": "gestor@email.com",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "tipo": "admin"
  }
}
```

### Listar Gestores (com autenticação)

```bash
curl -X GET http://localhost:8001/api/gestor/gestor-usuarios \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

## 🗄️ Migrações

```bash
# Criar nova migração
php yii migrate/create create_nome_da_tabela

# Executar migrações pendentes
php yii migrate

# Reverter última migração
php yii migrate/down
```

## 🐳 Docker (Opcional)

Caso prefira usar Docker:

```bash
# Construir e iniciar os containers
docker-compose up -d

# Acessar o container
docker-compose exec app bash

# Executar migrações
docker-compose exec app php yii migrate
```

## 🧪 Testes

```bash
# Executar testes unitários
php vendor/bin/codecept run unit

# Executar testes de API
php vendor/bin/codecept run api
```

## 📚 Documentação da API

A documentação completa da API está disponível em:

- **Swagger UI:** `http://localhost:8001/docs`
- **Postman Collection:** `/docs/postman_collection.json`

## 🤝 Contribuindo

1. Fork o projeto
2. Crie sua feature branch (`git checkout -b feature/nova-feature`)
3. Commit suas mudanças (`git commit -m 'Adiciona nova feature'`)
4. Push para a branch (`git push origin feature/nova-feature`)
5. Abra um Pull Request

## 📝 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## ✨ Autores

- **DeepSeek Team** - *Desenvolvimento inicial*
- **Contribuidores** - *Melhorias e manutenção*

## 📞 Suporte

- **Issues:** [GitHub Issues](https://github.com/seu-usuario/yii-gestor/issues)
- **Email:** [suporte@quigestor.com](mailto:suporte@quigestor.com)

---

<p align="center">
  Desenvolvido com ❤️ para o ecossistema Qui
</p>
