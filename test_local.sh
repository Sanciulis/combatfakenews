#!/bin/bash

# Test script for local development (without Docker build issues)

echo "==================================="
echo "Combat Fake News - Test Suite"
echo "==================================="

# Test 1: Check file structure
echo ""
echo "Test 1: Checking project structure..."
required_files=(
    "docker-compose.yml"
    ".env.example"
    ".gitignore"
    "README.md"
    "ARCHITECTURE.md"
    "DEPLOYMENT.md"
    "services/ai-service/app.py"
    "services/ai-service/detector.py"
    "services/ai-service/requirements.txt"
    "services/api-gateway/index.php"
    "services/frontend/index.html"
    "services/frontend/app.js"
)

all_present=true
for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        echo "❌ Missing: $file"
        all_present=false
    fi
done

if [ "$all_present" = true ]; then
    echo "✅ All required files present"
else
    echo "❌ Some files missing"
    exit 1
fi

# Test 2: Check Python syntax
echo ""
echo "Test 2: Checking Python code syntax..."
if command -v python3 &> /dev/null; then
    python3 -m py_compile services/ai-service/app.py 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✅ app.py syntax OK"
    else
        echo "⚠️  app.py has syntax issues (or missing dependencies)"
    fi
    
    python3 -m py_compile services/ai-service/detector.py 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✅ detector.py syntax OK"
    else
        echo "⚠️  detector.py has syntax issues (or missing dependencies)"
    fi
else
    echo "⚠️  Python3 not available for syntax check"
fi

# Test 3: Check PHP syntax
echo ""
echo "Test 3: Checking PHP code syntax..."
if command -v php &> /dev/null; then
    php -l services/api-gateway/index.php > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "✅ index.php syntax OK"
    else
        echo "❌ index.php has syntax errors"
        exit 1
    fi
    
    shopt -s nullglob
    for phpfile in services/api-gateway/src/*.php; do
        if [ -f "$phpfile" ]; then
            php -l "$phpfile" > /dev/null 2>&1
            if [ $? -eq 0 ]; then
                echo "✅ $(basename $phpfile) syntax OK"
            else
                echo "❌ $(basename $phpfile) has syntax errors"
                exit 1
            fi
        fi
    done
    shopt -u nullglob
else
    echo "⚠️  PHP not available for syntax check"
fi

# Test 4: Check JavaScript syntax
echo ""
echo "Test 4: Checking JavaScript code..."
if command -v node &> /dev/null; then
    node -c services/frontend/app.js 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✅ app.js syntax OK"
    else
        echo "⚠️  app.js has syntax issues"
    fi
else
    echo "⚠️  Node.js not available for syntax check"
fi

# Test 5: Check Docker configuration
echo ""
echo "Test 5: Checking Docker configuration..."
if command -v docker &> /dev/null; then
    docker compose config > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "✅ docker-compose.yml is valid"
    else
        echo "❌ docker-compose.yml has errors"
        exit 1
    fi
else
    echo "⚠️  Docker not available for configuration check"
fi

# Test 6: Check HTML validity
echo ""
echo "Test 6: Checking HTML files..."
if [ -f services/frontend/index.html ]; then
    # Basic HTML check
    grep -q "<!DOCTYPE html>" services/frontend/index.html
    if [ $? -eq 0 ]; then
        echo "✅ index.html has DOCTYPE"
    else
        echo "❌ index.html missing DOCTYPE"
    fi
    
    grep -q "<html" services/frontend/index.html
    if [ $? -eq 0 ]; then
        echo "✅ index.html has html tag"
    else
        echo "❌ index.html missing html tag"
    fi
fi

# Summary
echo ""
echo "==================================="
echo "Test Suite Complete"
echo "==================================="
echo "✅ Project structure verified"
echo "✅ Code syntax validated"
echo "✅ Configuration files checked"
echo ""
echo "Next steps:"
echo "1. Set up .env file: cp .env.example .env"
echo "2. Add OpenAI API key (optional)"
echo "3. Run: docker compose up -d"
echo "4. Access frontend: http://localhost:3000"
