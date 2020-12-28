---
layout: post
title:  "Redis Sentinel Docker로 설치"
date:   2018-12-28 16:42:46 +0900
author:
  name: Mason Ko
  image: /images/author/man.png
menu:
  sidebar:
    name: Redis Sentinel Docker로 설치
    parent: 2018
    weight: 10
---

## Install Environment

###### CentOs 7

## 방화벽 해제 

```
sudo systemctl stop firewalld
sudo systemctl disable firewalld 
sudo setenforce 0
```

## Install Docker & Docker Compose

```
yum install -y docker
sudo curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

## Redis Sentinel Config File 준비

sentinel.conf 만듬

```
mkdir ./sentinel1 ./sentinel2 ./sentinel3
 
echo 'sentinel monitor mymaster 10.0.0.1 7000 2' >> sentinel.conf
echo 'sentinel down-after-milliseconds mymaster 5000' >> sentinel.conf
echo 'sentinel failover-timeout mymaster 7000' >> sentinel.conf
echo 'sentinel auth-pass mymaster password' >> sentinel.conf
 
cp -rf sentinel.conf ./sentinel1/sentinel.conf
cp -rf sentinel.conf ./sentinel2/sentinel.conf
cp -rf sentinel.conf ./sentinel3/sentinel.conf
```

## Docker Compose File

docker-compose.yaml

```
version: "3.1"
services:
  redissen1:
    image: redis:5.0.2-alpine
    ports:
      - 17000:17000
    command: sh -c "redis-sentinel /etc/redis/sentinel.conf --port 17000"
    volumes:
      - ./sentinel1:/etc/redis
    container_name: redissen1
  redissen2:
    image: redis:5.0.2-alpine
    ports:
      - 17001:17001
    command: sh -c "redis-sentinel /etc/redis/sentinel.conf --port 17001"
    volumes:
      - ./sentinel2:/etc/redis
    container_name: redissen2
  redissen3:
    image: redis:5.0.2-alpine
    ports:
      - 17002:17002
    command: sh -c "redis-sentinel /etc/redis/sentinel.conf --port 17002"
    volumes:
      - ./sentinel3:/etc/redis
    container_name: redissen3
```

## Info

초기 설정되어있는 Master로 필수 설정임  
그 후 센티널 끼리 연결이 된 이후  
페일오버 시 Slave가 마스터로 변했을때 그 마스터 정보로  
Config가 변경이 됨  

#### 참고
[레디스 센티널 예제(Redis Sentinel)]  
[Sentinel 센티널 시작하기]

[레디스 센티널 예제(Redis Sentinel)]: https://jdm.kr/blog/159
[Sentinel 센티널 시작하기]: http://redisgate.jp/redis/sentinel/sentinel.php