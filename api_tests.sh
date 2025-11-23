#!/bin/bash

# API Test Suite for Combat Fake News
# This script tests all API endpoints

BASE_URL="http://localhost:8080"
AI_SERVICE_URL="http://localhost:5000"

echo "======================================"
echo "Combat Fake News - API Test Suite"
echo "======================================"
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Test function
test_endpoint() {
    local test_name="$1"
    local url="$2"
    local method="$3"
    local data="$4"
    local expected_code="$5"
    
    echo -n "Testing: $test_name... "
    
    if [ "$method" = "POST" ]; then
        response=$(curl -s -w "\n%{http_code}" -X POST "$url" \
            -H "Content-Type: application/json" \
            -d "$data")
    else
        response=$(curl -s -w "\n%{http_code}" "$url")
    fi
    
    status_code=$(echo "$response" | tail -n 1)
    body=$(echo "$response" | head -n -1)
    
    if [ "$status_code" = "$expected_code" ]; then
        echo -e "${GREEN}✓ PASSED${NC} (HTTP $status_code)"
        TESTS_PASSED=$((TESTS_PASSED + 1))
        if [ ! -z "$body" ]; then
            echo "  Response: $(echo $body | head -c 100)..."
        fi
    else
        echo -e "${RED}✗ FAILED${NC} (Expected: $expected_code, Got: $status_code)"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        if [ ! -z "$body" ]; then
            echo "  Response: $body"
        fi
    fi
    echo ""
}

# Wait for services to be ready
echo "Waiting for services to be ready..."
sleep 5

# Test 1: AI Service Health Check
test_endpoint \
    "AI Service Health Check" \
    "$AI_SERVICE_URL/health" \
    "GET" \
    "" \
    "200"

# Test 2: API Gateway Health Check
test_endpoint \
    "API Gateway Health Check" \
    "$BASE_URL/health" \
    "GET" \
    "" \
    "200"

# Test 3: API Documentation
test_endpoint \
    "API Documentation Endpoint" \
    "$BASE_URL/api/docs" \
    "GET" \
    "" \
    "200"

# Test 4: Analyze endpoint with valid data
test_endpoint \
    "Analyze Valid News (Suspicious)" \
    "$BASE_URL/api/analyze" \
    "POST" \
    '{
        "text": "SHOCKING discovery! Scientists dont want you to know! Click here NOW!",
        "title": "UNBELIEVABLE NEWS"
    }' \
    "200"

# Test 5: Analyze endpoint with credible news
test_endpoint \
    "Analyze Valid News (Credible)" \
    "$BASE_URL/api/analyze" \
    "POST" \
    '{
        "text": "According to a report published by the World Health Organization, flu cases have increased by 15% this year compared to last year. The study was conducted by researchers at the Institute of Public Health and included data from 50 countries.",
        "url": "https://nytimes.com/health/flu-report",
        "title": "WHO Reports Increase in Flu Cases"
    }' \
    "200"

# Test 6: Analyze endpoint with missing required field
test_endpoint \
    "Analyze Missing Required Field" \
    "$BASE_URL/api/analyze" \
    "POST" \
    '{
        "title": "No text field"
    }' \
    "400"

# Test 7: Batch analyze endpoint
test_endpoint \
    "Batch Analyze" \
    "$BASE_URL/api/batch-analyze" \
    "POST" \
    '{
        "articles": [
            {
                "text": "Breaking news from reliable source.",
                "title": "News 1"
            },
            {
                "text": "SHOCKING MIRACLE CURE!!!",
                "title": "Clickbait"
            }
        ]
    }' \
    "200"

# Test 8: Batch analyze with invalid data
test_endpoint \
    "Batch Analyze Invalid Data" \
    "$BASE_URL/api/batch-analyze" \
    "POST" \
    '{
        "wrong_field": []
    }' \
    "400"

# Test 9: Direct AI Service analyze endpoint
test_endpoint \
    "Direct AI Service Analyze" \
    "$AI_SERVICE_URL/api/v1/analyze" \
    "POST" \
    '{
        "text": "This is a test article about technology advancements."
    }' \
    "200"

# Test 10: Invalid endpoint
test_endpoint \
    "Invalid Endpoint" \
    "$BASE_URL/api/invalid" \
    "GET" \
    "" \
    "404"

# Summary
echo "======================================"
echo "Test Summary"
echo "======================================"
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
echo "Total Tests: $((TESTS_PASSED + TESTS_FAILED))"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}All tests passed! ✓${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed. ✗${NC}"
    exit 1
fi
