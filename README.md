# artem198315_microservices
artem198315 microservices repository

[![Build Status](https://travis-ci.com/otus-devops-2019-02/artem198315_microservices.svg?branch=master)](https://travis-ci.com/otus-devops-2019-02/artem198315_microservices)

# Домашнее задание 14

## Описание конфигурации

Установлен docker, docker-compose, docker-machine

Опробованы команды докера.


# Домашнее задание 15

Запуск VM с установленным Docker Engine при помощи Docker Machine. 
Написание Dockerfile и сборка образа с тестовым приложением. Сохранение образа на DockerHub.
Разворачивание инфраструктуры в GCE через terraform.
Ansible с GCE. Установка докер и деплой приложения.

## Описание конфигурации

### Создание VM в облаке GCE через docker-machine.

Создаем новый проект docker-239418.

Устанавливаем его по умолчанию для gcloud
```
gcloud config set core/project docker-239418
```


Настраиваем docker-machine и создаем instance:
 
```
export GOOGLE_PROJECT=docker-239418 

docker-machine create --driver google --google-machine-image \
https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
--google-machine-type n1-standard-1 \
--google-zone europe-west3-c \
docker-host
```

Проверка:

docker-machine ls

Подклюсение к docker'у на docker-host:
```
eval $(docker-machine env docker-host)
```

Создание образа с монго на docker-host:

Используем 
- Dockerfile (Устанавливаем mongo, приложение, puma)
- файл конфига mongod.conf
- файл для env db_config (В нем укажем DATABASE_URL дял приложения)
- скрипт для запуска монго и приложения
```
#!/bin/bash
/usr/bin/mongod --fork --logpath /var/log/mongod.log --config /etc/mongodb.conf
source /reddit/db_config
cd /reddit && puma || exit
```

Билдим:
```
docker build -t reddit:latest .
```

Запускаем контейнер:
```
docker run --name reddit -d --network=host reddit:latest
```

Настраиваем фаервол в GCE:
```
gcloud compute firewall-rules create reddit-app \
 --allow tcp:9292 \
 --target-tags=docker-machine \
 --description="Allow PUMA connections" \
 --direction=INGRESS
 --project=docker-239418
```


Пушим образ в в docker hub. Теперь он доступен так:
```
docker pull artem198315/otus-reddit:1.0
```


### dynamic inventory через inventory.gcp.yml

В ansible.cfg 
```
[defaults]
inventory = ./inventory.gcp.yml
remote_user = appuser
private_key_file = ~/.ssh/appuser
host_key_checking = False
retry_files_enabled = False
vault_password_file = ~/.ansible/vault.key

roles_path = ./roles

[inventory]
enable_plugins = host_list, script, yaml, ini, auto, gcp_compute
```

Создана своя роль docker (https://github.com/artem198315/ansible-docker):

Использовать с --tags=install,config для установки докер и конфигурирования (защита от случайного накатывания)

Provision через ansible:
```
ansible-playbook infra/ansible/playbooks/site.yml --tags=install,config,deploy
```

Создан шаблон packer с запеченным докером:

infra/packer/docker.json

```
packer build -var ssh_username=appuser -var project_id=docker-239418 packer/docker.json
```


# Домашнее задание 16

Разбиение приложения на несколько микросервисов. Выбор базового образа. Подключение volume к контейнеру.

## Описание конфигурации

Для проверки докерфайла использую линтер
```
docker run --rm -i hadolint/hadolint < Dockerfile
```

Созданы три Dockerfile на базе alpine:
src/post-py/Dockerfile
src/comment/Dockerfile
src/ui/Dockerfile

Для минимизации размера образов, использую alpine и multistage building.
*Уменьшенный в размерах образ Dockerfile.1*

Данные о подключениях между контейнерами заданы через ENV переменные (объявлены и устанавливаются по умолчанию в докерфайлах)


Билдим:
```
docker build -t artem198315/post:1.0 src/post-py
...
...
```

Для обеспечения persistancy данных в бд подключаю к контейнеру с mongodb volume redditdb
Для запуска контейнеров

```
docker run -d --network=reddit \
--network-alias=post_db --network-alias=comment_db -v redditdb:/data/db --name=mongo mongo:latest

docker run -d --network=reddit \
--network-alias=post --name=post artem198315/post:1.0

docker run -d --network=reddit \
--network-alias=comment --name=comment artem198315/comment:1.0

docker run -d --network=reddit \
-p 9292:9292 --name=ui artem198315/ui:1.0
```

Или если нужно поменять значения кто куда подключается, можно установить изменить --network-alias(или прописать --name ) и явно задать переменные окружения:
```
docker run -d --network=reddit \
--network-alias=mongo_db -v redditdb:/data/db --name=mongo mongo:latest

docker run -d --network=reddit \
--network-alias=post_app -e POST_DATABASE_HOST=mongo_db --name=post artem198315/post:1.0

docker run -d --network=reddit \
--network-alias=comment_app -e COMMENT_DATABASE_HOST=mongo_db --name=comment artem198315/comment:1.0

docker run -d --network=reddit \
-p 9292:9292 -e POST_SERVICE_HOST=post_app -e COMMENT_SERVICE_HOST=comment_app --name=ui artem198315/ui:1.0
```

