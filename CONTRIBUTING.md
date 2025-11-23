# Guia de Contribuição

Obrigado por considerar contribuir com o Combat Fake News! Este documento fornece diretrizes para contribuir com o projeto.

## 🎯 Como Contribuir

### Reportar Bugs

Se você encontrou um bug:

1. Verifique se o bug já não foi reportado nas [Issues](https://github.com/Sanciulis/combatfakenews/issues)
2. Se não foi reportado, crie uma nova issue incluindo:
   - Descrição clara do problema
   - Passos para reproduzir
   - Comportamento esperado vs. observado
   - Versão do Docker/Docker Compose
   - Logs relevantes

### Sugerir Melhorias

Para sugerir novas funcionalidades:

1. Abra uma issue com o label `enhancement`
2. Descreva a funcionalidade proposta
3. Explique por que seria útil
4. Se possível, sugira uma implementação

### Pull Requests

1. **Fork** o repositório
2. **Clone** seu fork localmente
3. **Crie uma branch** para sua feature: `git checkout -b feature/minha-feature`
4. **Faça suas alterações**
5. **Teste** suas alterações
6. **Commit** com mensagens claras: `git commit -m "Add: nova funcionalidade X"`
7. **Push** para sua branch: `git push origin feature/minha-feature`
8. Abra um **Pull Request**

## 📝 Padrões de Código

### Python

- Siga a [PEP 8](https://pep8.org/)
- Use type hints quando possível
- Docstrings para funções e classes
- Máximo de 100 caracteres por linha

```python
def analyze_text(text: str, url: str = '') -> Dict[str, Any]:
    """
    Analyze text for fake news detection.
    
    Args:
        text: The article text to analyze
        url: Optional source URL
        
    Returns:
        Dictionary with analysis results
    """
    pass
```

### PHP

- Siga a [PSR-12](https://www.php-fig.org/psr/psr-12/)
- Use type declarations
- Docblocks para métodos públicos
- Indentação de 4 espaços

```php
<?php

namespace Gateway;

class Router {
    /**
     * Register a GET route
     *
     * @param string $path Route path
     * @param callable $handler Route handler
     * @return void
     */
    public function get(string $path, callable $handler): void
    {
        // Implementation
    }
}
```

### JavaScript

- Use JavaScript moderno (ES6+)
- Nomes descritivos de variáveis
- Comentários para lógica complexa
- Indentação de 2 espaços

```javascript
// Fetch and display analysis results
async function analyzeNews() {
    const text = document.getElementById('text').value;
    
    try {
        const response = await fetch(API_URL, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ text })
        });
        
        const result = await response.json();
        displayResults(result);
    } catch (error) {
        console.error('Analysis failed:', error);
    }
}
```

## 🧪 Testes

### Antes de Submeter

Execute os testes locais:

```bash
# Teste de sintaxe
./test_local.sh

# Teste de API (requer containers rodando)
./api_tests.sh
```

### Adicionar Novos Testes

Se você adicionar funcionalidades:

1. Adicione testes para Python em `services/ai-service/tests/`
2. Adicione testes para PHP em `services/api-gateway/tests/`
3. Adicione testes de API em `api_tests.sh`

## 📂 Estrutura do Projeto

```
combatfakenews/
├── services/
│   ├── ai-service/         # Serviço Python de IA
│   │   ├── app.py          # API Flask
│   │   ├── detector.py     # Motor de detecção
│   │   └── tests/          # Testes unitários
│   ├── api-gateway/        # Gateway PHP
│   │   ├── index.php       # Router principal
│   │   ├── src/            # Classes PHP
│   │   └── tests/          # Testes PHP
│   └── frontend/           # Frontend JS
│       ├── index.html      # Página principal
│       ├── app.js          # Lógica JS
│       └── styles.css      # Estilos
├── docker-compose.yml      # Orquestração
├── README.md               # Documentação principal
├── ARCHITECTURE.md         # Documentação de arquitetura
└── CONTRIBUTING.md         # Este arquivo
```

## 🎨 Diretrizes de Design

### Frontend

- Design responsivo (mobile-first)
- Acessibilidade (ARIA labels, contraste)
- Performance (otimizar assets)
- UX intuitiva

### Backend

- RESTful APIs
- Tratamento adequado de erros
- Validação de entrada
- Logging apropriado

## 🔍 Áreas para Contribuição

### Fácil
- Melhorias na documentação
- Tradução para outros idiomas
- Correções de bugs pequenos
- Melhorias de UI/UX

### Médio
- Novos algoritmos de detecção
- Otimizações de performance
- Testes adicionais
- Integração com novas APIs

### Avançado
- Cache distribuído
- Processamento assíncrono
- Machine Learning avançado
- Escalabilidade horizontal

## 📋 Checklist para PR

Antes de submeter um Pull Request:

- [ ] Código segue os padrões do projeto
- [ ] Comentários e documentação atualizados
- [ ] Testes passam localmente
- [ ] Sem warnings ou erros de linting
- [ ] Commit messages são claros
- [ ] Branch está atualizada com main
- [ ] PR tem descrição clara
- [ ] Screenshots incluídos (se mudanças visuais)

## 💬 Comunicação

### Issues

Use labels apropriados:
- `bug` - Algo não funciona
- `enhancement` - Nova funcionalidade
- `documentation` - Melhorias na documentação
- `good first issue` - Bom para iniciantes
- `help wanted` - Precisa de ajuda

### Pull Requests

Descreva claramente:
- O que foi alterado
- Por que foi alterado
- Como testar
- Screenshots (se aplicável)

## 🎓 Recursos

### Aprender Mais

- [Flask Documentation](https://flask.palletsprojects.com/)
- [PHP Manual](https://www.php.net/manual/pt_BR/)
- [JavaScript MDN](https://developer.mozilla.org/pt-BR/docs/Web/JavaScript)
- [Docker Documentation](https://docs.docker.com/)

### Inspiração

Exemplos de projetos similares:
- [Fact-checking APIs](https://www.poynter.org/fact-checking/)
- [NLP Libraries](https://github.com/topics/nlp)
- [Microservices Patterns](https://microservices.io/patterns/)

## 🏆 Reconhecimento

Contribuidores são reconhecidos:
- No README.md
- Nos release notes
- Como colaboradores do projeto

## 📜 Código de Conduta

### Nossa Promessa

Nos comprometemos a tornar a participação em nosso projeto uma experiência livre de assédio para todos.

### Padrões

Comportamento esperado:
- ✅ Uso de linguagem acolhedora e inclusiva
- ✅ Respeito a pontos de vista diferentes
- ✅ Aceitação de críticas construtivas
- ✅ Foco no melhor para a comunidade

Comportamento inaceitável:
- ❌ Linguagem ou imagens sexualizadas
- ❌ Comentários insultuosos ou depreciativos
- ❌ Assédio público ou privado
- ❌ Publicar informações privadas de outros

### Aplicação

Instâncias de comportamento inaceitável podem ser reportadas aos mantenedores do projeto.

## ❓ Perguntas

Tem dúvidas sobre como contribuir?
- Abra uma issue com o label `question`
- Consulte a documentação existente
- Entre em contato com os mantenedores

---

**Obrigado por contribuir para combater a desinformação! 🛡️**
