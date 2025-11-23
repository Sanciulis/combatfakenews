// Combat Fake News - Frontend Application

// Configuration
const API_URL = window.location.hostname === 'localhost' 
    ? 'http://localhost:8080/api/analyze'
    : '/api/analyze';

// DOM Elements
const form = document.getElementById('analyzeForm');
const resultSection = document.getElementById('resultSection');
const resultContent = document.getElementById('resultContent');
const analyzeBtn = document.getElementById('analyzeBtn');
const btnText = analyzeBtn.querySelector('.btn-text');
const btnLoading = analyzeBtn.querySelector('.btn-loading');

// Event Listeners
form.addEventListener('submit', async (e) => {
    e.preventDefault();
    await analyzeNews();
});

// Main Analysis Function
async function analyzeNews() {
    const title = document.getElementById('title').value.trim();
    const url = document.getElementById('url').value.trim();
    const text = document.getElementById('text').value.trim();

    if (!text) {
        showError('Por favor, insira o texto da notícia.');
        return;
    }

    // Show loading state
    setLoading(true);

    try {
        const response = await fetch(API_URL, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ title, url, text })
        });

        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }

        const result = await response.json();
        displayResults(result);
    } catch (error) {
        console.error('Error analyzing news:', error);
        showError('Erro ao analisar a notícia. Por favor, tente novamente.');
    } finally {
        setLoading(false);
    }
}

// Display Results
function displayResults(result) {
    const { is_fake, confidence, overall_score, analysis } = result;
    
    // Determine result type
    let resultClass, resultText, resultEmoji;
    if (confidence < 0.4) {
        resultClass = 'result-uncertain';
        resultText = 'Resultado Incerto';
        resultEmoji = '🤔';
    } else if (is_fake) {
        resultClass = 'result-fake';
        resultText = 'Provável Notícia Falsa';
        resultEmoji = '❌';
    } else {
        resultClass = 'result-real';
        resultText = 'Aparentemente Confiável';
        resultEmoji = '✅';
    }

    // Calculate color for confidence bar
    const confidenceColor = getConfidenceColor(confidence);
    const confidencePercent = Math.round(confidence * 100);

    // Build HTML
    const html = `
        <div class="result-header ${resultClass}">
            ${resultEmoji} ${resultText}
        </div>

        <div class="confidence-bar">
            <div class="confidence-label">
                <span>Nível de Confiança</span>
                <span>${confidencePercent}%</span>
            </div>
            <div class="progress-bar">
                <div class="progress-fill" style="width: ${confidencePercent}%; background-color: ${confidenceColor};">
                    ${confidencePercent}%
                </div>
            </div>
        </div>

        <div class="analysis-details">
            <div class="detail-item">
                <h4>📊 Score Geral</h4>
                <p>${Math.round(overall_score * 100)}% de credibilidade</p>
            </div>

            <div class="detail-item">
                <h4>💭 Análise de Sentimento</h4>
                <p>Score: ${Math.round(analysis.sentiment_score * 100)}%</p>
                <small>Sentimento moderado é um bom sinal de objetividade.</small>
            </div>

            <div class="detail-item">
                <h4>🔍 Credibilidade da Fonte</h4>
                <p>Score: ${Math.round(analysis.credibility_score * 100)}%</p>
            </div>

            ${analysis.ai_verification ? `
            <div class="detail-item">
                <h4>🤖 Verificação por IA</h4>
                <p>${analysis.ai_verification}</p>
            </div>
            ` : ''}

            ${analysis.warning_signs && analysis.warning_signs.length > 0 ? `
            <div class="detail-item">
                <h4>⚠️ Sinais de Alerta</h4>
                <ul class="warning-signs">
                    ${analysis.warning_signs.map(sign => `<li>${sign}</li>`).join('')}
                </ul>
            </div>
            ` : ''}
        </div>

        <div class="recommendation">
            <h4>💡 Recomendação</h4>
            <p>${analysis.recommendation}</p>
        </div>
    `;

    resultContent.innerHTML = html;
    resultSection.style.display = 'block';
    
    // Smooth scroll to results
    resultSection.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
}

// Helper Functions
function setLoading(isLoading) {
    analyzeBtn.disabled = isLoading;
    btnText.style.display = isLoading ? 'none' : 'inline';
    btnLoading.style.display = isLoading ? 'inline' : 'none';
}

function showError(message) {
    resultContent.innerHTML = `
        <div class="error-message">
            <strong>❌ Erro:</strong> ${message}
        </div>
    `;
    resultSection.style.display = 'block';
    resultSection.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
}

function getConfidenceColor(confidence) {
    if (confidence >= 0.7) return '#10b981'; // Green
    if (confidence >= 0.4) return '#f59e0b'; // Orange
    return '#ef4444'; // Red
}

// Sample news for testing (optional)
function loadSampleNews() {
    document.getElementById('title').value = 'Exemplo de Notícia';
    document.getElementById('text').value = 'Este é um texto de exemplo para testar o sistema de detecção de fake news.';
}

// Initialize
console.log('Combat Fake News - Frontend initialized');
console.log('API URL:', API_URL);
