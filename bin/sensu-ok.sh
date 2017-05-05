# /usr/bin/env bash
echo '{ "handlers": ["default"],
        "name": "alpo-check",
        "output": "Dog food looks great 🐶!",
        "status": 0 }' | nc -w1 127.0.0.1 3030
