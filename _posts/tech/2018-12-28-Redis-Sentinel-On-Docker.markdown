---
layout: post
title:  "Redis Sentinel Docker로 설치"
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
Redis Sentinel Config File 준비
</h2>

sentinel.conf 만듬

{% highlight Kconfig %}
mkdir ./s1 ./s2 ./s3
vi s1/sentinel.conf
vi s2/sentinel.conf
vi s3/sentinel.conf
{% endhighlight %}

{% highlight Kconfig %}
sentinel monitor mymaster 10.0.0.1 7000 2
sentinel down-after-milliseconds mymaster 5000
sentinel failover-timeout mymaster 10000
sentinel auth-pass mymaster password
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
      - 20000:20000
    command: sh -c "redis-sentinel /etc/redis/sentinel.conf --port 20000"
    volumes:
      - ./s1:/etc/redis
    container_name: redissen1
  redissen2:
    image: redis:5.0.2-alpine
    ports:
      - 20001:20001
    command: sh -c "redis-sentinel /etc/redis/sentinel.conf --port 20001"
    volumes:
      - ./s2:/etc/redis
    container_name: redissen2
  redissen3:
    image: redis:5.0.2-alpine
    ports:
      - 20002:20002
    command: sh -c "redis-sentinel /etc/redis/sentinel.conf --port 20002"
    volumes:
      - ./s3:/etc/redis
    container_name: redissen3
{% endhighlight %}


<h3>참고</h3>
[레디스 센티널 예제(Redis Sentinel)] <br/>
[Sentinel 센티널 시작하기]

[레디스 센티널 예제(Redis Sentinel)]: https://jdm.kr/blog/159
[Sentinel 센티널 시작하기]: http://redisgate.jp/redis/sentinel/sentinel.php