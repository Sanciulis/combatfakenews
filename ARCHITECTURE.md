# Arquitetura do Sistema Combat Fake News

## Visão Geral da Arquitetura

O Combat Fake News utiliza uma arquitetura de microserviços containerizada, permitindo escalabilidade, manutenibilidade e independência tecnológica.

## Diagrama de Arquitetura

```
┌─────────────────────────────────────────────────────────────────┐
│                           USUÁRIO                                │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                     FRONTEND SERVICE                             │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  • HTML5 + CSS3 + JavaScript Vanilla                      │  │
│  │  • Interface Responsiva                                   │  │
│  │  • Nginx como Web Server                                  │  │
│  │  • Port: 3000                                             │  │
│  └───────────────────────────────────────────────────────────┘  │
└────────────────────────────┬────────────────────────────────────┘
                             │ HTTP/REST
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                      API GATEWAY SERVICE                         │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  • PHP 8.2 + Apache                                       │  │
│  │  • Request Routing & Orchestration                        │  │
│  │  • Rate Limiting                                          │  │
│  │  • API Key Validation                                     │  │
│  │  • Request/Response Transformation                        │  │
│  │  • Port: 8080                                             │  │
│  └───────────────────────────────────────────────────────────┘  │
└────────────────────────────┬────────────────────────────────────┘
                             │ HTTP/REST
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                        AI SERVICE                                │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  • Python 3.11 + Flask                                    │  │
│  │  • Machine Learning (scikit-learn)                        │  │
│  │  • NLP (TextBlob)                                         │  │
│  │  • OpenAI Integration                                     │  │
│  │  • Sentiment Analysis                                     │  │
│  │  • Pattern Recognition                                    │  │
│  │  • Port: 5000                                             │  │
│  └───────────────────────────────────────────────────────────┘  │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │  OpenAI API     │
                    │  (Opcional)     │
                    └─────────────────┘
```

## Componentes Detalhados

### 1. Frontend Service

**Tecnologias:**
- HTML5, CSS3, JavaScript (Vanilla)
- Nginx (Alpine Linux)

**Responsabilidades:**
- Interface de usuário responsiva
- Coleta de entrada do usuário
- Exibição de resultados
- Comunicação com API Gateway

**Features:**
- Design moderno e intuitivo
- Feedback visual em tempo real
- Validação de entrada no cliente
- Responsivo para mobile/desktop

### 2. API Gateway Service

**Tecnologias:**
- PHP 8.2
- Apache Web Server
- Custom routing system

**Responsabilidades:**
- Roteamento de requisições
- Rate limiting (proteção DDoS)
- Validação de requisições
- Transformação de respostas
- Logging e monitoramento

**Componentes:**
- `Router.php` - Sistema de roteamento
- `AIServiceClient.php` - Cliente HTTP para AI Service
- `RateLimiter.php` - Implementação de rate limiting

**Padrões de Design:**
- Router Pattern
- Client Pattern
- Middleware Pattern (Rate Limiting)

### 3. AI Service

**Tecnologias:**
- Python 3.11
- Flask (Web Framework)
- TextBlob (NLP)
- scikit-learn (ML)
- OpenAI API (Generative AI)

**Responsabilidades:**
- Análise de sentimento
- Detecção de padrões suspeitos
- Verificação de credibilidade
- Fact-checking com IA generativa
- Geração de scores e recomendações

**Componentes:**
- `app.py` - API Flask com endpoints REST
- `detector.py` - Motor de detecção de fake news

**Algoritmos:**
1. **Sentiment Analysis**
   - Usa TextBlob para análise de polaridade
   - Score baseado em neutralidade (extremos = suspeito)

2. **Credibility Checking**
   - Validação de domínio contra lista de fontes confiáveis
   - Análise de estrutura e qualidade do texto

3. **Pattern Detection**
   - Keywords suspeitas (sensacionalismo)
   - Análise de pontuação excessiva
   - Verificação de fontes citadas

4. **AI Fact-Checking**
   - Integração com OpenAI GPT-3.5
   - Verificação contextual avançada
   - Análise de consistência

5. **Score Aggregation**
   ```
   overall_score = (
       credibility_score * 0.4 +
       ai_score * 0.4 +
       pattern_score * 0.2
   )
   ```

## Fluxo de Dados

### Análise de Notícia (Fluxo Normal)

```
1. Usuário → Frontend
   - Preenche formulário com texto da notícia
   - (Opcional) Adiciona título e URL

2. Frontend → API Gateway
   POST /api/analyze
   {
     "text": "...",
     "url": "...",
     "title": "..."
   }

3. API Gateway → AI Service
   - Valida requisição
   - Verifica rate limit
   - Encaminha para AI Service
   POST /api/v1/analyze

4. AI Service → Processamento
   - Análise de sentimento
   - Verificação de credibilidade
   - Detecção de padrões
   - (Opcional) Consulta OpenAI

5. AI Service → API Gateway
   {
     "is_fake": boolean,
     "confidence": float,
     "analysis": {...}
   }

6. API Gateway → Frontend
   - Formata resposta
   - Retorna ao cliente

7. Frontend → Usuário
   - Exibe resultados formatados
   - Gráficos e visualizações
```

## Containerização

### Docker Compose

Todos os serviços são orquestrados via Docker Compose:

```yaml
services:
  - ai-service (Python)
  - api-gateway (PHP)
  - frontend (Nginx)

networks:
  - fakenews-network (bridge)

volumes:
  - ai-models (persistência de modelos)
```

### Benefícios da Containerização

1. **Isolamento** - Cada serviço roda em seu próprio ambiente
2. **Portabilidade** - Funciona em qualquer ambiente com Docker
3. **Escalabilidade** - Fácil de escalar horizontalmente
4. **Desenvolvimento** - Ambiente consistente para todos os desenvolvedores
5. **Deploy** - Processo simplificado de deployment

## Comunicação Entre Serviços

### Protocolo
- HTTP/REST
- JSON como formato de dados

### Network
- Docker bridge network (`fakenews-network`)
- Comunicação interna via DNS do Docker
- Resolução de nomes: `http://ai-service:5000`

### Timeout e Retry
- Timeout padrão: 30 segundos
- Sem retry automático (para evitar análises duplicadas)

## Segurança

### Rate Limiting
- Implementado no API Gateway
- 10 requisições por minuto por IP (padrão)
- 5 requisições por minuto para batch analysis

### Validação de Entrada
- Validação em múltiplas camadas:
  1. Frontend (JavaScript)
  2. API Gateway (PHP)
  3. AI Service (Python)

### Containerização
- Serviços isolados
- Sem privilégios root
- Networks segregadas

### Secrets Management
- Variáveis de ambiente para API keys
- Arquivo `.env` não commitado
- `.env.example` como template

## Escalabilidade

### Horizontal Scaling

Cada serviço pode ser escalado independentemente:

```bash
# Escalar AI Service para 3 instâncias
docker-compose up -d --scale ai-service=3

# Docker Compose automaticamente faz load balancing
```

### Vertical Scaling

Recursos podem ser ajustados no docker-compose.yml:

```yaml
ai-service:
  deploy:
    resources:
      limits:
        cpus: '2'
        memory: 2G
```

## Monitoramento

### Health Checks

Cada serviço expõe um endpoint `/health`:

```
GET /health

Response:
{
  "status": "healthy",
  "service": "ai-service",
  "version": "1.0.0"
}
```

### Logs

- Logs centralizados via Docker
- Visualização: `docker-compose logs -f [service]`

## Performance

### Otimizações

1. **Caching** - Nginx cache de assets estáticos
2. **Text Limiting** - Limite de 1000 caracteres para análise IA
3. **Batch Processing** - Endpoint otimizado para múltiplas análises
4. **Connection Pooling** - Reutilização de conexões HTTP

### Métricas Esperadas

- Análise individual: ~2-5 segundos
- Análise individual (com IA): ~5-10 segundos
- Throughput: ~10-20 análises/minuto por instância

## Extensibilidade

### Adicionar Novos Modelos de ML

1. Adicionar modelo em `services/ai-service/detector.py`
2. Integrar no método `analyze()`
3. Ajustar cálculo do `overall_score`

### Adicionar Novos Endpoints

1. Definir rota no API Gateway (`index.php`)
2. Implementar handler correspondente
3. Atualizar documentação

### Adicionar Novos Serviços

1. Criar diretório em `services/`
2. Adicionar Dockerfile
3. Registrar no `docker-compose.yml`
4. Configurar networking

## Tecnologias Futuras

### Possíveis Adições

- **Database** - PostgreSQL para histórico de análises
- **Cache** - Redis para cache de resultados
- **Message Queue** - RabbitMQ para processamento assíncrono
- **Search Engine** - Elasticsearch para busca de notícias verificadas
- **Monitoring** - Prometheus + Grafana

## Conclusão

A arquitetura de microserviços permite:
- Desenvolvimento independente de cada serviço
- Tecnologias específicas para cada problema
- Escalabilidade granular
- Manutenibilidade simplificada
- Deployment independente
