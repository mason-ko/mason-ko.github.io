---
layout: post
title:  "Redis Replication Docker로 설치"
date:   2018-12-28 16:42:46 +0900
categories: tech docker
permalink: /tech/docker/:title
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

1. redis.conf 만듬
2. Redis Stable Config 복사
3. protected-mode 사용중일 때 비밀번호 필요하며
4. Docker 외부에서 사용가능하도록 bind 주석 처리
5. 각 slave config에 master 정보 추가

{% highlight Kconfig %}
mkdir ./s1 ./s2 ./s3
wget http://download.redis.io/redis-stable/redis.conf
sed -i "s/bind 127.0.0.1/#bind 127.0.0.1/" redis.conf
echo 'masterauth "password"' >> redis.conf
echo 'requirepass "password"' >> redis.conf

cp -rf redis.conf ./s1/redis.conf
cp -rf redis.conf ./s2/redis.conf
cp -rf redis.conf ./s3/redis.conf
 
echo 'slaveof 10.0.0.1 7000' >> ./s2/redis.conf
echo 'slaveof 10.0.0.1 7000' >> ./s3/redis.conf
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

<h2>
Info
</h2>

slave of 를 통해 초기 slave를 지정 할 수 있음 <br/>
서버의 상태 변경 시 target 지정한 conf 값이 변함 <br/>
slave가 master로 승격이 될 경우를 대비해서 <br/>
master와 slave 구분없이 모든 auto에 대해 공통 단일화 시켜야함 <br/>
