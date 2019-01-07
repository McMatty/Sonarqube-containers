#!/bin/bash

set -x

PROJECT_KEY="${PROJECT_KEY:-Application}"
PROJECT_NAME="${PROJECT_NAME:-Application}"
PROJECT_VERSION="${PROJECT_VERSION:-1.0}"
SONAR_HOST="${HOST:-http://localhost:9000}"

if [ -z "$SONAR_LOGIN_KEY"]
then
    SONAR_LOGIN_KEY="$(curl -u admin:admin -x POST $HOST/api/user_tokens/generate -d "name=access_other" --noproxy "*" | jq -r '.token')"
fi

sonar-scanner -D sonar.login=$SONAR_LOGIN_KEY  -D sonar.host.url=$SONAR_HOST -D sonar.projectKey=$PROJECT_KEY -D sonar.projectName=$PROJECT_NAME -D sonar.projectVersion=$PROJECT_VERSION -D sonar.sources=. -D sonar.java.binaries=. -D sonar.sourceEncoding=UTF-8