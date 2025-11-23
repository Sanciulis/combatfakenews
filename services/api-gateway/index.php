<?php
/**
 * API Gateway for Fake News Detection System
 * 
 * This gateway handles:
 * - Request routing to microservices
 * - Rate limiting
 * - API key validation
 * - Response formatting
 */

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit;
}

require_once __DIR__ . '/src/Router.php';
require_once __DIR__ . '/src/AIServiceClient.php';
require_once __DIR__ . '/src/RateLimiter.php';

use Gateway\Router;
use Gateway\AIServiceClient;
use Gateway\RateLimiter;

// Initialize components
$router = new Router();
$aiClient = new AIServiceClient(getenv('AI_SERVICE_URL') ?: 'http://ai-service:5000');
$rateLimiter = new RateLimiter();

// Health check endpoint
$router->get('/health', function() {
    return [
        'status' => 'healthy',
        'service' => 'api-gateway',
        'version' => '1.0.0',
        'timestamp' => date('c')
    ];
});

// Analyze news endpoint
$router->post('/api/analyze', function() use ($aiClient, $rateLimiter) {
    // Check rate limit
    $clientIp = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
    if (!$rateLimiter->checkLimit($clientIp)) {
        http_response_code(429);
        return [
            'error' => 'Rate limit exceeded. Please try again later.',
            'retry_after' => 60
        ];
    }
    
    // Get request body
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input || !isset($input['text'])) {
        http_response_code(400);
        return [
            'error' => 'Missing required field: text'
        ];
    }
    
    // Forward to AI service
    try {
        $result = $aiClient->analyze(
            $input['text'],
            $input['url'] ?? '',
            $input['title'] ?? ''
        );
        
        return $result;
    } catch (Exception $e) {
        http_response_code(500);
        return [
            'error' => 'Service temporarily unavailable',
            'message' => $e->getMessage()
        ];
    }
});

// Batch analyze endpoint
$router->post('/api/batch-analyze', function() use ($aiClient, $rateLimiter) {
    $clientIp = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
    if (!$rateLimiter->checkLimit($clientIp, 5)) { // Lower limit for batch
        http_response_code(429);
        return [
            'error' => 'Rate limit exceeded. Please try again later.'
        ];
    }
    
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (!$input || !isset($input['articles']) || !is_array($input['articles'])) {
        http_response_code(400);
        return [
            'error' => 'Missing required field: articles (array)'
        ];
    }
    
    try {
        $result = $aiClient->batchAnalyze($input['articles']);
        return $result;
    } catch (Exception $e) {
        http_response_code(500);
        return [
            'error' => 'Service temporarily unavailable',
            'message' => $e->getMessage()
        ];
    }
});

// API documentation endpoint
$router->get('/api/docs', function() {
    return [
        'name' => 'Fake News Detection API',
        'version' => '1.0.0',
        'endpoints' => [
            [
                'method' => 'POST',
                'path' => '/api/analyze',
                'description' => 'Analyze a single news article',
                'body' => [
                    'text' => 'string (required) - Article text',
                    'url' => 'string (optional) - Source URL',
                    'title' => 'string (optional) - Article title'
                ]
            ],
            [
                'method' => 'POST',
                'path' => '/api/batch-analyze',
                'description' => 'Analyze multiple news articles',
                'body' => [
                    'articles' => 'array (required) - Array of article objects'
                ]
            ],
            [
                'method' => 'GET',
                'path' => '/health',
                'description' => 'Health check endpoint'
            ]
        ]
    ];
});

// Route the request
try {
    $result = $router->dispatch(
        $_SERVER['REQUEST_METHOD'],
        parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH)
    );
    
    echo json_encode($result, JSON_PRETTY_PRINT);
} catch (Exception $e) {
    http_response_code(404);
    echo json_encode([
        'error' => 'Endpoint not found',
        'path' => $_SERVER['REQUEST_URI']
    ], JSON_PRETTY_PRINT);
}
