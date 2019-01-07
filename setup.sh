#!/bin/bash

curl -u admin:admin -x POST http://localhost:8001/api/user_tokens/generate -d "name=access" --noproxy "*"