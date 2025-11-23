"""
Fake News Detection Engine
Combines multiple techniques for comprehensive fake news detection
"""

import re
from textblob import TextBlob
from typing import Dict, List, Any
import openai


class FakeNewsDetector:
    """Main fake news detection class"""
    
    def __init__(self, api_key: str = None):
        """Initialize the detector with optional OpenAI API key"""
        self.api_key = api_key
        self.openai_client = None
        if api_key:
            self.openai_client = openai.OpenAI(api_key=api_key)
        
        # Suspicious keywords that may indicate fake news
        self.suspicious_keywords = [
            'shocking', 'unbelievable', 'miracle', 'conspiracy',
            'they don\'t want you to know', 'secret', 'exposed',
            'breaking', 'exclusive', 'must see', 'click here'
        ]
        
        # Credible source patterns
        self.credible_domains = [
            'bbc.com', 'cnn.com', 'reuters.com', 'apnews.com',
            'nytimes.com', 'theguardian.com', 'washingtonpost.com'
        ]
    
    def analyze(self, text: str, url: str = '', title: str = '') -> Dict[str, Any]:
        """
        Perform comprehensive fake news analysis
        
        Args:
            text: The article text to analyze
            url: Optional source URL
            title: Optional article title
            
        Returns:
            Dictionary with analysis results
        """
        # Perform various analyses
        sentiment_score = self._analyze_sentiment(text)
        credibility_score = self._check_credibility(text, url)
        warning_signs = self._detect_warning_signs(text, title)
        
        # Use AI for fact verification if API key is available
        ai_verification = ''
        ai_score = 0.5
        
        if self.api_key:
            try:
                ai_verification, ai_score = self._ai_fact_check(text, title)
            except Exception as e:
                ai_verification = f'AI verification unavailable: {str(e)}'
        
        # Calculate overall confidence
        # Combine scores with weights
        overall_score = (
            credibility_score * 0.4 +
            ai_score * 0.4 +
            (1 - len(warning_signs) * 0.1) * 0.2
        )
        
        # Determine if likely fake (threshold at 0.5)
        is_fake = overall_score < 0.5
        confidence = abs(overall_score - 0.5) * 2  # Scale to 0-1
        
        return {
            'is_fake': is_fake,
            'confidence': round(confidence, 2),
            'overall_score': round(overall_score, 2),
            'analysis': {
                'sentiment_score': round(sentiment_score, 2),
                'credibility_score': round(credibility_score, 2),
                'ai_verification': ai_verification,
                'warning_signs': warning_signs,
                'recommendation': self._get_recommendation(is_fake, confidence)
            }
        }
    
    def _analyze_sentiment(self, text: str) -> float:
        """
        Analyze text sentiment
        Extreme sentiment might indicate bias
        """
        try:
            blob = TextBlob(text)
            # Polarity ranges from -1 (negative) to 1 (positive)
            polarity = blob.sentiment.polarity
            
            # Extreme sentiment might indicate fake news
            # Return score closer to 1 for moderate sentiment
            sentiment_score = 1 - abs(polarity)
            return sentiment_score
        except:
            return 0.5
    
    def _check_credibility(self, text: str, url: str) -> float:
        """Check source credibility"""
        score = 0.5  # Start with neutral score
        
        # Check if URL is from credible source
        if url:
            for domain in self.credible_domains:
                if domain in url.lower():
                    score += 0.3
                    break
        
        # Check text quality indicators
        if len(text) > 200:  # Longer articles tend to be more credible
            score += 0.1
        
        # Check for proper grammar and structure
        if '.' in text and len(text.split('.')) > 3:
            score += 0.1
        
        return min(score, 1.0)
    
    def _detect_warning_signs(self, text: str, title: str) -> List[str]:
        """Detect warning signs of fake news"""
        warnings = []
        
        full_text = (title + ' ' + text).lower()
        
        # Check for suspicious keywords
        for keyword in self.suspicious_keywords:
            if keyword in full_text:
                warnings.append(f'Contains suspicious keyword: "{keyword}"')
        
        # Check for excessive punctuation
        if text.count('!') > 3:
            warnings.append('Excessive use of exclamation marks')
        
        # Check for all caps
        if len([word for word in text.split() if word.isupper() and len(word) > 3]) > 5:
            warnings.append('Excessive use of capital letters')
        
        # Check for lack of sources
        if 'according to' not in full_text and 'source' not in full_text:
            warnings.append('No sources or attributions mentioned')
        
        return warnings
    
    def _ai_fact_check(self, text: str, title: str) -> tuple:
        """
        Use generative AI to fact-check the content
        Returns (verification_text, score)
        """
        if not self.openai_client:
            return ('AI verification not configured', 0.5)
        
        try:
            # Limit text length for API call
            text_sample = text[:1000] if len(text) > 1000 else text
            
            prompt = f"""Analyze the following news article for credibility and potential misinformation.
Title: {title}
Text: {text_sample}

Provide:
1. Overall credibility assessment (High/Medium/Low)
2. Key concerns or red flags if any
3. Whether claims seem verifiable

Keep response brief (max 150 words)."""

            response = self.openai_client.chat.completions.create(
                model="gpt-3.5-turbo",
                messages=[
                    {"role": "system", "content": "You are a fact-checking assistant that analyzes news articles for credibility."},
                    {"role": "user", "content": prompt}
                ],
                max_tokens=200,
                temperature=0.3
            )
            
            verification = response.choices[0].message.content.strip()
            
            # Calculate score based on AI response
            verification_lower = verification.lower()
            if 'high' in verification_lower and 'credibility' in verification_lower:
                score = 0.8
            elif 'low' in verification_lower and 'credibility' in verification_lower:
                score = 0.3
            else:
                score = 0.5
            
            return (verification, score)
            
        except Exception as e:
            return (f'AI verification error: {str(e)}', 0.5)
    
    def _get_recommendation(self, is_fake: bool, confidence: float) -> str:
        """Generate a recommendation based on analysis"""
        if is_fake and confidence > 0.7:
            return 'Highly likely to be fake news. Do not share without verification.'
        elif is_fake and confidence > 0.4:
            return 'Possibly fake news. Verify with multiple reliable sources before sharing.'
        elif not is_fake and confidence > 0.7:
            return 'Appears to be credible. Still recommended to verify important claims.'
        else:
            return 'Uncertain. Please verify with multiple reliable sources.'
