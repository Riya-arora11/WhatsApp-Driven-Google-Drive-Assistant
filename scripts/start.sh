#!/usr/bin/env bash
# Simple helper to start n8n via docker-compose
docker-compose pull
docker-compose up -d
echo "n8n is starting... Visit http://localhost:5678"
