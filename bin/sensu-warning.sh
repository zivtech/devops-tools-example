# /usr/bin/env bash

echo '{ "handlers": ["default"],
        "name": "alpo-check",
        "output": "You are running low on dog food 🐶 😭!",
        "status": 1 }' | nc -w1 127.0.0.1 3030
