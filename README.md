

```sh
export RASA_X_VERSION=0.21.5
export RASA_SDK_VERSION=1.3.3
docker-compose build --no-cache
docker-compose up -d --remove-orphans
docker-compose logs | grep password
docker-compose exec rasa bash
docker-compose down --remove-orphans
```
