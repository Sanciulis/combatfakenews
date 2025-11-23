<?php

namespace Gateway;

class RateLimiter {
    private $dataDir = '/var/tmp/fakenews_rate_limits';
    private $maxRequests = 10;
    private $timeWindow = 60; // seconds
    
    public function __construct() {
        if (!is_dir($this->dataDir)) {
            mkdir($this->dataDir, 0755, true);
        }
    }
    
    public function checkLimit($clientId, $maxRequests = null) {
        $maxRequests = $maxRequests ?? $this->maxRequests;
        $file = $this->dataDir . '/' . md5($clientId) . '.json';
        
        $data = [];
        if (file_exists($file)) {
            $data = json_decode(file_get_contents($file), true);
        }
        
        $now = time();
        $windowStart = $now - $this->timeWindow;
        
        // Clean old requests
        if (isset($data['requests'])) {
            $data['requests'] = array_filter($data['requests'], function($timestamp) use ($windowStart) {
                return $timestamp > $windowStart;
            });
        } else {
            $data['requests'] = [];
        }
        
        // Check limit
        if (count($data['requests']) >= $maxRequests) {
            return false;
        }
        
        // Add current request
        $data['requests'][] = $now;
        file_put_contents($file, json_encode($data));
        
        return true;
    }
}
