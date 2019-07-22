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


# Домашнее задание 17

Практика работы с основными типами Docker сетей. Декларативное описание Docker инфраструктуры при помощи Docker Compose.

## Описание конфигурации

Поднимаем микросервисы из HW16 через docker-compose.

docker-compose.yml параметризирован.
Переменные читаются из .env

Задать имя проекта:
- export COMPOSE_PROJECT_NAME=name
- прописать COMPOSE_PROJECT_NAME=name в .env файл.
- использовать флаг -p

docker-compose.override.yml
Переопределяет запуск puma для руби в дебаг режиме с двумя воркерами, через command
```
version: '3.3'
services:
  ui:
    command: ["puma","--debug","-w","2"]
  comment:
    command: ["puma","--debug","-w","2"]
```


При желании можно примонтировать к контейнерам директорию с приложением (через volume),
если есть необходимость обновлять код приложений, не пересобирая образ


# Домашнее задание 19

Gitlab CI. Построение процесса непрерывной интеграции

## Описание конфигурации

Развернут докер хост с ипользованием terraform и ansible, развернут gitlab-ce (gitlab-ci/terraform и gitlab-ci/ansible)


Протестированы возможности по созданию pipeline средствами gitlab-ci


# Домашнее задание 20

Создание и запуск системы мониторинга Prometheus.
Мониторинг состояния микросервисов, сбор метрик при помощи prometheus exporters.

## Описание конфигурации

Создаем хост в GCE
export GOOGLE_PROJECT=docker-239418

docker-machine create --driver google \
 --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
 --google-machine-type n1-standard-1 \
 --google-zone europe-west1-b \
 docker-host


Создаем файл настроек prometheus.yml
Создаем Dockerfile и прокидываем в нем prometheus.yml в /etc/prometheus/prometheus.yml
```
FROM prom/prometheus:v2.1.0
ADD prometheus.yml /etc/prometheus/
```

Добавляем в docker-compose сервис prometheus
```
prometheus:
    image: ${USERNAME}/prometheus
    ports:
      - '9090:9090'
    volumes:
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
      - '--storage.tsdb.retention=1d'
    networks:
      - reddit_front
      - reddit_back

volumes:
  post_db:
  prometheus_data:
```

Билдим образы приложения из директории src/
Используем для этого файлы docker_build.sh
Перед этим экспортируем переменную export USER_NAME=artem198315 

Образы запушены на docker hub (https://cloud.docker.com/repository/list)

Поднимаем стек:
USERNAME=artem198315 docker-compose up -d


# Домашнее задание 25

Установка и настройка Kubernetes.
Работа над автоматизацией процесса развертывания системы.

## Описание конфигурации
Лаба полностью поднимается с использованием terraform + ansible

Файлы конфигурации лежат в kubernetes/the_hard_way/

Папки:
- terraform (поднимает инстансы и генерирует сертификаты и конфиги для controller и workers)
- ansible (размызвает конфиги и сертификаты, настраивает окружение)
- certs (скрипты для генерации конфигов и сертификатов для терраформ, директории для certs и configs)

kube_remote.sh - настраивает remote access

# Домашнее задание 26

Установка и настройка Google Kubernetes Engine, настройка локального профиля администратора для GKE. Работа с с контроллерами: StatefulSet, Deployment, DaemonSet

## Описание конфигурации

Запущен локальный kubernetes cluster в minikube.
На нем оттестированы yaml манифесты для запуска приложения reddit и настройки RBAC.

С помощью терраформа развернут кластер kubernetes в GCE (сам кластер и firewall rules для него).
На него выкачено приложение reddit.

None! Настройки для kubernetes dashboard в GCE не проводились т.к он depricated

# Домашнее задание 27

Настройка балансировщиков нагрузки в Kubernetes и SSLTerminating.
Подключение удаленных хранилищ GCP данных к POD’ам.

## Описание конфигурации

Все описано в yml манифестах.

- Проверены варианты настройки балансировщиков в GCE. 
- Созданы secrets (в лабе это SSL сертификаты).
- Настроен INGRESS с TLS из secret.
- Протестированы ограничения доступа через NetworkPolicy(настроены разрешения для доступа на Mongo только с сервисов comment и post (mongo-network-policy.yml))

```
NetworkPolicy - инструмент для декларативного описания потоков трафика. Не все сетевые плагины поддерживают
политики сети. В частности, у GKE эта функция пока в Beta-тесте и для её работы отдельно будет включен сетевой плагин Calico (вместо Kubenet). 

Включаем:
```
gcloud beta container clusters update reddit-cluster --zone=europe-west3-c --update-addons=NetworkPolicy=ENABLED
gcloud beta container clusters update reddit-cluster --zone=europe-west3-c --enable-network-policy
```
```

- Настроены persistent volume 

Мы можем использовать не целый выделенный диск для каждого пода, а целый ресурс хранилища, общий для всего кластера.
Тогда при запуске Stateful-задач в кластере, мы сможем запросить хранилище в виде такого же ресурса, как CPU или оперативная память. Для этого будем использовать механизм PersistentVolume (mongo-volume.yml)

Чтобы выделить приложению часть такого ресурса - нужно
создать запрос на выдачу - PersistentVolumeClaim.

Реализовано динамическое выделение PVC, используя storageClass




