<?php

namespace Gateway;

class AIServiceClient {
    private $baseUrl;
    
    public function __construct($baseUrl) {
        $this->baseUrl = rtrim($baseUrl, '/');
    }
    
    public function analyze($text, $url = '', $title = '') {
        $data = [
            'text' => $text,
            'url' => $url,
            'title' => $title
        ];
        
        return $this->makeRequest('/api/v1/analyze', $data);
    }
    
    public function batchAnalyze($articles) {
        $data = [
            'articles' => $articles
        ];
        
        return $this->makeRequest('/api/v1/batch-analyze', $data);
    }
    
    private function makeRequest($endpoint, $data) {
        $url = $this->baseUrl . $endpoint;
        
        $options = [
            'http' => [
                'header'  => "Content-Type: application/json\r\n",
                'method'  => 'POST',
                'content' => json_encode($data),
                'timeout' => 30
            ]
        ];
        
        $context = stream_context_create($options);
        $result = @file_get_contents($url, false, $context);
        
        if ($result === false) {
            throw new \Exception('Failed to connect to AI service');
        }
        
        return json_decode($result, true);
    }
}
