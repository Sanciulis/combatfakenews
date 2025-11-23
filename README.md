# Combat Fake News 🛡️

Sistema online inteligente para detectar fake news na internet usando IA generativa, microserviços e containers.

## 🎯 Visão Geral

Combat Fake News é uma plataforma completa de detecção de notícias falsas que utiliza:

- **Python** - Serviço de IA e Machine Learning para análise de texto
- **PHP** - API Gateway para roteamento e orquestração
- **JavaScript** - Interface web interativa
- **IA Generativa** - Verificação de fatos usando OpenAI
- **Docker** - Containerização de todos os serviços
- **Arquitetura de Microserviços** - Serviços independentes e escaláveis

## 🏗️ Arquitetura

O sistema é composto por três microserviços principais:

```
┌─────────────────────────────────────────────────────────────┐
│                         Frontend                             │
│                  (JavaScript + HTML/CSS)                     │
│                       Port: 3000                             │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                      API Gateway                             │
│                         (PHP)                                │
│           Rate Limiting + Request Routing                    │
│                       Port: 8080                             │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                      AI Service                              │
│                  (Python + Flask)                            │
│        NLP + Sentiment Analysis + OpenAI                     │
│                       Port: 5000                             │
└─────────────────────────────────────────────────────────────┘
```

### Serviços

#### 1. AI Service (Python)
- Análise de sentimento usando TextBlob
- Detecção de padrões suspeitos
- Verificação de credibilidade da fonte
- Integração com OpenAI para fact-checking
- APIs REST para análise individual e em lote

#### 2. API Gateway (PHP)
- Roteamento de requisições
- Rate limiting (proteção contra abuso)
- Validação de requisições
- Orquestração de chamadas aos microserviços

#### 3. Frontend (JavaScript)
- Interface web responsiva
- Formulário para análise de notícias
- Visualização de resultados em tempo real
- Dashboard com métricas de credibilidade

## 🚀 Como Usar

### Pré-requisitos

- Docker e Docker Compose instalados
- (Opcional) Chave API da OpenAI para verificação avançada com IA

### Instalação

1. Clone o repositório:
```bash
git clone https://github.com/Sanciulis/combatfakenews.git
cd combatfakenews
```

2. Configure as variáveis de ambiente:
```bash
cp .env.example .env
# Edite .env e adicione sua chave OpenAI (opcional)
```

3. Inicie os serviços com Docker Compose:
```bash
docker-compose up -d
```

4. Acesse a aplicação:
- **Frontend**: http://localhost:3000
- **API Gateway**: http://localhost:8080
- **AI Service**: http://localhost:5000

### Uso Básico

1. Acesse o frontend em http://localhost:3000
2. Cole ou digite o texto da notícia que deseja analisar
3. Opcionalmente, adicione o título e URL da fonte
4. Clique em "Analisar Notícia"
5. Visualize os resultados detalhados incluindo:
   - Classificação (Fake/Real/Incerto)
   - Nível de confiança
   - Análise de sentimento
   - Credibilidade da fonte
   - Sinais de alerta identificados
   - Recomendações

## 📡 API Documentation

### Endpoints do AI Service

#### POST /api/v1/analyze
Analisa uma notícia individual.

**Request:**
```json
{
  "text": "Texto da notícia",
  "url": "https://fonte.com/noticia (opcional)",
  "title": "Título da notícia (opcional)"
}
```

**Response:**
```json
{
  "is_fake": false,
  "confidence": 0.85,
  "overall_score": 0.75,
  "analysis": {
    "sentiment_score": 0.65,
    "credibility_score": 0.80,
    "ai_verification": "Análise da IA...",
    "warning_signs": [],
    "recommendation": "Aparentemente confiável..."
  }
}
```

#### POST /api/v1/batch-analyze
Analisa múltiplas notícias em lote.

**Request:**
```json
{
  "articles": [
    {
      "text": "Texto 1",
      "url": "url1",
      "title": "título1"
    },
    {
      "text": "Texto 2",
      "url": "url2",
      "title": "título2"
    }
  ]
}
```

### Endpoints do API Gateway

#### POST /api/analyze
Proxy para análise de notícia (com rate limiting).

#### POST /api/batch-analyze
Proxy para análise em lote (com rate limiting).

#### GET /api/docs
Retorna documentação da API.

#### GET /health
Health check do gateway.

## 🔧 Desenvolvimento

### Estrutura do Projeto

```
combatfakenews/
├── docker-compose.yml          # Orquestração dos containers
├── .env.example                # Exemplo de variáveis de ambiente
├── services/
│   ├── ai-service/            # Serviço Python de IA
│   │   ├── Dockerfile
│   │   ├── app.py             # API Flask
│   │   ├── detector.py        # Motor de detecção
│   │   └── requirements.txt
│   ├── api-gateway/           # Gateway PHP
│   │   ├── Dockerfile
│   │   ├── index.php          # Router principal
│   │   ├── composer.json
│   │   └── src/
│   │       ├── Router.php
│   │       ├── AIServiceClient.php
│   │       └── RateLimiter.php
│   └── frontend/              # Frontend JavaScript
│       ├── Dockerfile
│       ├── index.html
│       ├── styles.css
│       ├── app.js
│       └── nginx.conf
└── README.md
```

### Desenvolvimento Local

Para desenvolvimento sem Docker:

**AI Service:**
```bash
cd services/ai-service
pip install -r requirements.txt
python app.py
```

**API Gateway:**
```bash
cd services/api-gateway
php -S localhost:8080
```

**Frontend:**
```bash
cd services/frontend
# Usar qualquer servidor HTTP, ex: python -m http.server 3000
```

## 🔬 Como Funciona a Detecção

O sistema usa múltiplas técnicas para detectar fake news:

### 1. Análise de Sentimento
- Detecta emoções extremas que podem indicar manipulação
- Textos objetivos tendem a ser mais confiáveis

### 2. Verificação de Credibilidade
- Analisa a fonte da notícia
- Compara com domínios conhecidos e confiáveis
- Verifica qualidade e estrutura do texto

### 3. Detecção de Padrões Suspeitos
- Palavras sensacionalistas ("chocante", "inacreditável")
- Excesso de pontuação e maiúsculas
- Falta de fontes e atribuições
- Clickbait patterns

### 4. IA Generativa (OpenAI)
- Verificação de fatos usando GPT
- Análise contextual avançada
- Identificação de inconsistências

### 5. Score Combinado
O sistema combina todos os fatores com pesos específicos para gerar:
- Score de credibilidade geral (0-1)
- Classificação (Fake/Real/Incerto)
- Nível de confiança na classificação

## 🔒 Segurança

- Rate limiting no API Gateway
- Validação de entrada em todos os endpoints
- Containerização para isolamento
- Sem armazenamento de dados sensíveis

## 🌟 Funcionalidades

- ✅ Análise individual de notícias
- ✅ Análise em lote
- ✅ Interface web intuitiva
- ✅ API RESTful
- ✅ Integração com IA generativa
- ✅ Rate limiting
- ✅ Containerização completa
- ✅ Arquitetura de microserviços
- ✅ Documentação detalhada

## 📝 Licença

Apache License 2.0 - Veja o arquivo [LICENSE](LICENSE) para detalhes.

## 🤝 Contribuindo

Contribuições são bem-vindas! Sinta-se livre para:
1. Fazer fork do projeto
2. Criar uma branch para sua feature
3. Commit suas mudanças
4. Push para a branch
5. Abrir um Pull Request

## 📧 Suporte

Para questões e suporte, abra uma issue no GitHub.

---

**Desenvolvido com ❤️ para combater a desinformação**
