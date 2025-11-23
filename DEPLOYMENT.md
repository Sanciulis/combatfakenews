# Guia de Deployment - Combat Fake News

Este guia detalha como fazer deploy do sistema Combat Fake News em diferentes ambientes.

## 📋 Pré-requisitos

### Ambiente de Desenvolvimento
- Docker Desktop (Windows/Mac) ou Docker Engine (Linux)
- Docker Compose v2.0+
- Git
- Editor de texto/IDE

### Ambiente de Produção
- Servidor Linux (Ubuntu 20.04+ recomendado)
- Docker Engine 20.10+
- Docker Compose v2.0+
- Domínio configurado (opcional)
- SSL/TLS certificado (recomendado)

## 🚀 Deployment Local (Desenvolvimento)

### 1. Clone o Repositório

```bash
git clone https://github.com/Sanciulis/combatfakenews.git
cd combatfakenews
```

### 2. Configure Variáveis de Ambiente

```bash
cp .env.example .env
```

Edite o arquivo `.env`:

```env
# OpenAI API Key (opcional, mas recomendado)
OPENAI_API_KEY=sk-your-key-here

# URLs dos serviços (para desenvolvimento local)
AI_SERVICE_URL=http://ai-service:5000
API_GATEWAY_URL=http://api-gateway:8080

# Ambiente
ENVIRONMENT=development
```

### 3. Inicie os Serviços

```bash
# Build e start
docker-compose up -d

# Verificar logs
docker-compose logs -f
```

### 4. Acesse a Aplicação

- **Frontend**: http://localhost:3000
- **API Gateway**: http://localhost:8080
- **AI Service**: http://localhost:5000

### 5. Teste os Endpoints

```bash
# Health check do AI Service
curl http://localhost:5000/health

# Health check do API Gateway
curl http://localhost:8080/health

# Teste de análise
curl -X POST http://localhost:8080/api/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Esta é uma notícia de teste para verificar o sistema."
  }'
```

## 🏭 Deployment em Produção

### Opção 1: Servidor Linux com Docker

#### 1. Preparar o Servidor

```bash
# Atualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Instalar Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Verificar instalação
docker --version
docker-compose --version
```

#### 2. Clonar e Configurar

```bash
# Criar usuário de deploy (recomendado)
sudo useradd -m -s /bin/bash deploy
sudo usermod -aG docker deploy
su - deploy

# Clonar repositório
git clone https://github.com/Sanciulis/combatfakenews.git
cd combatfakenews

# Configurar variáveis de ambiente
cp .env.example .env
nano .env  # Editar com suas configurações
```

#### 3. Ajustar docker-compose.yml para Produção

Crie um arquivo `docker-compose.prod.yml`:

```yaml
version: '3.8'

services:
  ai-service:
    restart: always
    environment:
      - FLASK_ENV=production
    deploy:
      resources:
        limits:
          cpus: '1.0'
          memory: 1G

  api-gateway:
    restart: always
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M

  frontend:
    restart: always
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 256M

  # Nginx Reverse Proxy (adicionar)
  nginx-proxy:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx-proxy.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    depends_on:
      - frontend
      - api-gateway
    networks:
      - fakenews-network
    restart: always

networks:
  fakenews-network:
    driver: bridge
```

#### 4. Deploy

```bash
# Build e start em produção
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d

# Verificar status
docker-compose ps

# Monitorar logs
docker-compose logs -f
```

### Opção 2: AWS (usando EC2)

#### 1. Provisionar EC2 Instance

```bash
# Tipo recomendado: t3.medium ou superior
# OS: Ubuntu Server 22.04 LTS
# Storage: 20GB+ SSD
# Security Group: Abrir portas 80, 443, 22
```

#### 2. Conectar e Configurar

```bash
# Conectar via SSH
ssh -i sua-chave.pem ubuntu@ip-do-servidor

# Instalar Docker (seguir passos da Opção 1)

# Deploy da aplicação
git clone https://github.com/Sanciulis/combatfakenews.git
cd combatfakenews
# ... continuar com configuração
```

#### 3. Configurar Domínio

```bash
# Associar Elastic IP
# Configurar DNS para apontar para o IP
# Instalar Certbot para SSL
sudo snap install --classic certbot
sudo certbot --nginx -d seu-dominio.com
```

### Opção 3: Cloud Platform (DigitalOcean, Linode, etc)

Similar ao AWS, mas usando a interface específica da plataforma para:
1. Criar Droplet/Instance
2. Instalar Docker
3. Fazer deploy
4. Configurar DNS e SSL

## 🔧 Configurações de Produção

### Nginx Reverse Proxy

Crie `nginx-proxy.conf`:

```nginx
events {
    worker_connections 1024;
}

http {
    upstream frontend {
        server frontend:80;
    }

    upstream api {
        server api-gateway:80;
    }

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;

    server {
        listen 80;
        server_name seu-dominio.com;

        # Frontend
        location / {
            proxy_pass http://frontend;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }

        # API
        location /api/ {
            limit_req zone=api_limit burst=20;
            proxy_pass http://api;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
        }
    }

    # SSL configuration (após obter certificado)
    server {
        listen 443 ssl http2;
        server_name seu-dominio.com;

        ssl_certificate /etc/nginx/ssl/cert.pem;
        ssl_certificate_key /etc/nginx/ssl/key.pem;

        # ... mesmo conteúdo do server acima
    }
}
```

### Variáveis de Ambiente em Produção

```env
# .env para produção
OPENAI_API_KEY=sua-chave-real
AI_SERVICE_URL=http://ai-service:5000
API_GATEWAY_URL=http://api-gateway:80
ENVIRONMENT=production

# Configurações adicionais
MAX_REQUESTS_PER_MINUTE=10
ENABLE_DEBUG=false
LOG_LEVEL=INFO
```

## 📊 Monitoramento

### Verificação de Saúde

```bash
#!/bin/bash
# health-check.sh

echo "Checking services..."

# Frontend
curl -f http://localhost:3000 || echo "Frontend DOWN"

# API Gateway
curl -f http://localhost:8080/health || echo "API Gateway DOWN"

# AI Service
curl -f http://localhost:5000/health || echo "AI Service DOWN"

echo "Health check complete"
```

### Logs

```bash
# Ver logs em tempo real
docker-compose logs -f

# Ver logs de um serviço específico
docker-compose logs -f ai-service

# Logs com timestamp
docker-compose logs -f -t

# Últimas 100 linhas
docker-compose logs --tail=100
```

### Resource Monitoring

```bash
# Uso de recursos dos containers
docker stats

# Inspecionar um container específico
docker inspect combatfakenews-ai-service
```

## 🔄 Atualizações

### Atualizar Código

```bash
# Pull latest changes
git pull origin main

# Rebuild containers
docker-compose down
docker-compose build --no-cache
docker-compose up -d

# Verificar
docker-compose ps
```

### Rollback

```bash
# Voltar para commit anterior
git log --oneline -10
git checkout <commit-hash>

# Rebuild
docker-compose down
docker-compose build
docker-compose up -d
```

## 🗄️ Backup

### Backup dos Volumes

```bash
# Backup do volume de modelos
docker run --rm \
  -v combatfakenews_ai-models:/data \
  -v $(pwd):/backup \
  alpine tar czf /backup/ai-models-backup.tar.gz -C /data .
```

### Backup da Configuração

```bash
# Backup do .env e configurações
tar czf config-backup.tar.gz .env docker-compose*.yml nginx-proxy.conf
```

## 🛡️ Segurança

### Firewall

```bash
# Instalar UFW (Ubuntu)
sudo apt install ufw

# Configurar
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw enable
```

### SSL/TLS com Let's Encrypt

```bash
# Instalar Certbot
sudo snap install --classic certbot

# Obter certificado
sudo certbot --nginx -d seu-dominio.com -d www.seu-dominio.com

# Renovação automática já configurada
```

### Proteger Variáveis de Ambiente

```bash
# Permissões restritas para .env
chmod 600 .env
chown deploy:deploy .env
```

## 🚨 Troubleshooting

### Container não inicia

```bash
# Ver logs detalhados
docker-compose logs ai-service

# Verificar se a porta está em uso
sudo netstat -tlnp | grep 5000

# Rebuild forçado
docker-compose build --no-cache ai-service
docker-compose up -d ai-service
```

### Erro de conexão entre serviços

```bash
# Verificar rede Docker
docker network ls
docker network inspect combatfakenews_fakenews-network

# Testar conectividade
docker exec combatfakenews-api-gateway ping ai-service
```

### Performance Issues

```bash
# Verificar recursos
docker stats

# Aumentar limites no docker-compose.yml
# Reiniciar serviços
docker-compose restart
```

## 📝 Checklist de Deployment

- [ ] Servidor configurado com Docker
- [ ] Repositório clonado
- [ ] Variáveis de ambiente configuradas
- [ ] OpenAI API key adicionada (se disponível)
- [ ] Docker Compose executado
- [ ] Serviços verificados (health checks)
- [ ] Testes básicos realizados
- [ ] Firewall configurado
- [ ] SSL/TLS configurado (produção)
- [ ] Domínio configurado (produção)
- [ ] Monitoramento configurado
- [ ] Backups agendados
- [ ] Documentação atualizada

## 📞 Suporte

Para problemas durante o deployment:
1. Verificar logs: `docker-compose logs -f`
2. Consultar documentação: README.md e ARCHITECTURE.md
3. Abrir issue no GitHub

---

**Última atualização:** 2024
