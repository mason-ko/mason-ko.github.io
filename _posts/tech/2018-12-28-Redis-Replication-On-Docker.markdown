---
layout: post
title:  "Redis Replication Docker로 설치"
date:   2018-12-28 16:42:46 +0900
categories: tech hadoop
permalink: /tech/hadoop/:title
---

<h2>
Install Environment
</h2>

<p>CentOs 7</p>

<h2>
방화벽 해제 
</h2>

{% highlight Kconfig %}
sudo systemctl stop firewalld
sudo systemctl disable firewalld 
sudo setenforce 0
{% endhighlight %}

<h2>
Install Docker & Docker Compose
</h2>

{% highlight Kconfig %}
yum install -y docker
sudo curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
{% endhighlight %}

<h2>
Redis Replication Config File 준비
</h2>

Redis Stable Config 복사

<a>http://download.redis.io/redis-stable/redis.conf</a>

redis.conf 만듬

{% highlight Kconfig %}
mkdir ./s1 ./s2 ./s3
vi s1/redis.conf
vi s2/redis.conf
vi s3/redis.conf
{% endhighlight %}

protected-mode 사용중일 때 비밀번호 필요하며
Docker 외부에서 사용가능하도록 bind 주석 처리

{% highlight Kconfig %}
masterauth "password"
requirepass "password"
#bind 127.0.0.1
{% endhighlight %}

각 slave config에 master 정보 추가

{% highlight Kconfig %}
vi s2/redis.conf
vi s3/redis.conf

slaveof 10.0.0.1 7000
{% endhighlight %}

<h2>
Docker Compose File
</h2>

docker-compose.yaml

{% highlight Kconfig %}
version: "3.1"
services:
  redismaster1:
    image: redis:5.0.2-alpine
    ports:
      - 7000:7000
    command: sh -c "redis-server /etc/redis/redis.conf --port 7000"
    container_name: redismaster1
    volumes:
      - ./s1:/etc/redis
    networks:
      redisnet:
        ipv4_address: 10.0.0.2
  redisslave1:
    image: redis:5.0.2-alpine
    ports:
      - 7001:7001
    command: sh -c "redis-server /etc/redis/redis.conf --port 7001"
    container_name: redisslave1
    volumes:
      - ./s2:/etc/redis
    depends_on:
      - redismaster1
    networks:
      redisnet:
        ipv4_address: 10.0.0.3
  redisslave2:
    image: redis:5.0.2-alpine
    ports:
      - 7002:7002
    command: sh -c "redis-server /etc/redis/redis.conf --port 7002"
    container_name: redisslave2
    volumes:
      - ./s3:/etc/redis
    depends_on:
      - redismaster1
    networks:
      redisnet:
        ipv4_address: 10.0.0.4
 
networks:
  redisnet:
    driver: bridge
    ipam:
      config:
        - subnet: 10.0.0.0/16

{% endhighlight %}
