---
layout: post
title:  "Redis Sentinel Docker로 설치"
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
Redis Sentinel Config File 준비
</h2>

sentinel.conf 만듬

{% highlight Kconfig %}
mkdir ./sentinel1 ./sentinel2 ./sentinel3
 
echo 'sentinel monitor mymaster 10.0.0.1 7000 2' >> sentinel.conf
echo 'sentinel down-after-milliseconds mymaster 5000' >> sentinel.conf
echo 'sentinel failover-timeout mymaster 7000' >> sentinel.conf
echo 'sentinel auth-pass mymaster password' >> sentinel.conf
 
cp -rf sentinel.conf ./sentinel1/sentinel.conf
cp -rf sentinel.conf ./sentinel2/sentinel.conf
cp -rf sentinel.conf ./sentinel3/sentinel.conf
{% endhighlight %}

<h2>
Docker Compose File
</h2>

docker-compose.yaml

{% highlight Kconfig %}
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
{% endhighlight %}


<h3>참고</h3>
[레디스 센티널 예제(Redis Sentinel)] <br/>
[Sentinel 센티널 시작하기]

[레디스 센티널 예제(Redis Sentinel)]: https://jdm.kr/blog/159
[Sentinel 센티널 시작하기]: http://redisgate.jp/redis/sentinel/sentinel.php