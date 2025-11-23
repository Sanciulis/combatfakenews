# Quick Start Guide

Este guia rápido mostra como iniciar o sistema Combat Fake News em minutos.

## 🚀 Início Rápido (5 minutos)

### Passo 1: Pré-requisitos

Certifique-se de ter instalado:
- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

Verificar instalação:
```bash
docker --version
docker compose version
```

### Passo 2: Clonar o Repositório

```bash
git clone https://github.com/Sanciulis/combatfakenews.git
cd combatfakenews
```

### Passo 3: Configurar Variáveis de Ambiente

```bash
cp .env.example .env
```

**Opcional:** Edite `.env` e adicione sua chave da OpenAI para análise avançada com IA:
```bash
nano .env
# Ou use seu editor favorito
```

### Passo 4: Iniciar os Serviços

```bash
docker compose up -d
```

Aguarde alguns minutos enquanto as imagens são baixadas e os containers iniciados.

### Passo 5: Verificar Status

```bash
docker compose ps
```

Você deve ver 3 serviços rodando:
- `fakenews-ai-service` (porta 5000)
- `fakenews-api-gateway` (porta 8080)
- `fakenews-frontend` (porta 3000)

### Passo 6: Acessar a Aplicação

Abra seu navegador e acesse:
```
http://localhost:3000
```

## 🧪 Testar a API

### Via cURL

```bash
# Health check
curl http://localhost:8080/health

# Analisar uma notícia
curl -X POST http://localhost:8080/api/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "text": "Cientistas descobrem cura milagrosa! Clique aqui para saber mais!",
    "title": "Cura Milagrosa Descoberta"
  }'
```

### Exemplo de Resposta

```json
{
  "is_fake": true,
  "confidence": 0.75,
  "overall_score": 0.35,
  "analysis": {
    "sentiment_score": 0.45,
    "credibility_score": 0.30,
    "ai_verification": "Alta probabilidade de ser fake news...",
    "warning_signs": [
      "Contains suspicious keyword: \"milagrosa\"",
      "Excessive use of exclamation marks"
    ],
    "recommendation": "Highly likely to be fake news. Do not share without verification."
  }
}
```

## 📱 Usando a Interface Web

1. Acesse http://localhost:3000
2. Cole o texto da notícia no campo de texto
3. (Opcional) Adicione o título e URL da fonte
4. Clique em "Analisar Notícia"
5. Veja os resultados com:
   - Classificação (Fake/Real/Incerto)
   - Nível de confiança
   - Análise detalhada
   - Sinais de alerta
   - Recomendação

## 🛠️ Comandos Úteis

### Ver logs dos serviços
```bash
# Todos os serviços
docker compose logs -f

# Serviço específico
docker compose logs -f ai-service
```

### Parar os serviços
```bash
docker compose down
```

### Reiniciar um serviço
```bash
docker compose restart ai-service
```

### Reconstruir após mudanças no código
```bash
docker compose down
docker compose up -d --build
```

## 🔧 Troubleshooting

### Porta já em uso

Se as portas 3000, 5000 ou 8080 já estiverem em uso:

Edite `docker-compose.yml` e altere as portas:
```yaml
ports:
  - "3001:80"  # Mude de 3000 para 3001
```

### Container não inicia

```bash
# Ver logs do container com problema
docker compose logs ai-service

# Forçar rebuild
docker compose down
docker compose build --no-cache
docker compose up -d
```

### Erro de permissão

No Linux, adicione seu usuário ao grupo docker:
```bash
sudo usermod -aG docker $USER
# Logout e login novamente
```

## 📊 Exemplos de Teste

### Notícia Provavelmente Falsa
```json
{
  "text": "CHOCANTE! Descoberta INACREDITÁVEL! Cientistas não querem que você saiba! Clique aqui URGENTE!",
  "title": "Você não vai acreditar nisso!"
}
```

**Resultado esperado:** Alta probabilidade de fake news

### Notícia Provavelmente Real
```json
{
  "text": "Segundo relatório publicado pela OMS, os casos de gripe aumentaram 15% este ano em comparação com o ano anterior. O estudo foi conduzido por pesquisadores do Instituto de Saúde Pública.",
  "url": "https://nytimes.com/example",
  "title": "OMS reporta aumento de casos de gripe"
}
```

**Resultado esperado:** Alta credibilidade

## 🎯 Próximos Passos

1. **Adicionar API Key da OpenAI** para análise avançada
2. **Explorar a documentação** completa em [README.md](README.md)
3. **Entender a arquitetura** em [ARCHITECTURE.md](ARCHITECTURE.md)
4. **Preparar para produção** com [DEPLOYMENT.md](DEPLOYMENT.md)

## 💡 Dicas

- **OpenAI API Key:** Para análises mais precisas, obtenha uma chave em https://platform.openai.com/api-keys
- **Rate Limiting:** Por padrão, há limite de 10 requisições por minuto
- **Performance:** Com OpenAI habilitado, análises levam ~5-10 segundos
- **Sem OpenAI:** Análises levam ~2-5 segundos usando apenas algoritmos locais

## 🆘 Suporte

Problemas? 
1. Consulte os logs: `docker compose logs -f`
2. Verifique a documentação completa
3. Abra uma issue no GitHub

---

**Boa análise de notícias! 🛡️**
