# /usr/bin/env bash
echo '{ "handlers": ["default"],
        "name": "alpo-check",
        "output": "🔥 🐶 You are totally out of dog food! 🐶 🔥",
        "status": 2 }' | nc -w1 127.0.0.1 3030
