#!/usr/bin/env python3
"""
Fake News Detection AI Service
This microservice provides AI-powered fake news detection using multiple techniques:
1. Text analysis and sentiment detection
2. Source credibility checking
3. Generative AI-based fact verification
"""

from flask import Flask, request, jsonify
from flask_cors import CORS
import os
from dotenv import load_dotenv
from detector import FakeNewsDetector

# Load environment variables
load_dotenv()

app = Flask(__name__)
CORS(app)

# Initialize the fake news detector
detector = FakeNewsDetector(api_key=os.getenv('OPENAI_API_KEY'))


@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'service': 'ai-service',
        'version': '1.0.0'
    }), 200


@app.route('/api/v1/analyze', methods=['POST'])
def analyze_news():
    """
    Analyze a news article for fake news detection
    
    Request body:
    {
        "text": "News article text",
        "url": "Optional source URL",
        "title": "Optional article title"
    }
    
    Response:
    {
        "is_fake": boolean,
        "confidence": float (0-1),
        "analysis": {
            "sentiment_score": float,
            "credibility_score": float,
            "ai_verification": string,
            "warning_signs": [list of warnings]
        }
    }
    """
    try:
        data = request.get_json()
        
        if not data or 'text' not in data:
            return jsonify({
                'error': 'Missing required field: text'
            }), 400
        
        text = data.get('text', '')
        url = data.get('url', '')
        title = data.get('title', '')
        
        # Perform fake news detection
        result = detector.analyze(text, url, title)
        
        return jsonify(result), 200
        
    except Exception as e:
        return jsonify({
            'error': f'Analysis failed: {str(e)}'
        }), 500


@app.route('/api/v1/batch-analyze', methods=['POST'])
def batch_analyze():
    """
    Analyze multiple news articles in batch
    
    Request body:
    {
        "articles": [
            {
                "text": "Article text",
                "url": "Optional URL",
                "title": "Optional title"
            },
            ...
        ]
    }
    """
    try:
        data = request.get_json()
        
        if not data or 'articles' not in data:
            return jsonify({
                'error': 'Missing required field: articles'
            }), 400
        
        articles = data.get('articles', [])
        results = []
        
        for article in articles:
            if 'text' in article:
                result = detector.analyze(
                    article.get('text', ''),
                    article.get('url', ''),
                    article.get('title', '')
                )
                results.append(result)
        
        return jsonify({
            'results': results,
            'count': len(results)
        }), 200
        
    except Exception as e:
        return jsonify({
            'error': f'Batch analysis failed: {str(e)}'
        }), 500


if __name__ == '__main__':
    port = int(os.getenv('PORT', 5000))
    app.run(host='0.0.0.0', port=port, debug=False)
