---
layout: post
title:  "Kafka Cluster Docker Compose Yaml"
date:   2019-02-15 13:42:46 +0900
categories: tech docker
permalink: /tech/docker/:title
---

<h2>
Docker Compose File
</h2>

docker-compose.yaml

{% highlight Kconfig %}
version: '2.1'

services:
  zoo1:
    image: zookeeper:3.4.9
    hostname: zoo1
    ports:
      - "2181:2181"
    container_name: docker_zoo_1
    environment:
        ZOO_MY_ID: 1
        ZOO_PORT: 2181
        ZOO_SERVERS: server.1=zoo1:2888:3888 server.2=zoo2:2888:3888 server.3=zoo3:2888:3888
  zoo2:
    image: zookeeper:3.4.9
    hostname: zoo2
    ports:
      - "2182:2182"
    container_name: docker_zoo_2
    environment:
        ZOO_MY_ID: 2
        ZOO_PORT: 2182
        ZOO_SERVERS: server.1=zoo1:2888:3888 server.2=zoo2:2888:3888 server.3=zoo3:2888:3888
  zoo3:
    image: zookeeper:3.4.9
    hostname: zoo3
    ports:
      - "2183:2183"
    container_name: docker_zoo_3
    environment:
        ZOO_MY_ID: 3
        ZOO_PORT: 2183
        ZOO_SERVERS: server.1=zoo1:2888:3888 server.2=zoo2:2888:3888 server.3=zoo3:2888:3888
		
  kafka1:
    image: confluentinc/cp-kafka:5.0.0
    hostname: kafka1
    ports:
      - "9092:9092"
    container_name: docker_kafka_1
    environment:
      KAFKA_ADVERTISED_LISTENERS: LISTENER_DOCKER_INTERNAL://kafka1:19092,LISTENER_DOCKER_EXTERNAL://${DOCKER_HOST_IP:-192.168.56.102}:9092
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: LISTENER_DOCKER_INTERNAL:PLAINTEXT,LISTENER_DOCKER_EXTERNAL:PLAINTEXT
      KAFKA_INTER_BROKER_LISTENER_NAME: LISTENER_DOCKER_INTERNAL
      KAFKA_ZOOKEEPER_CONNECT: "zoo1:2181"
      KAFKA_BROKER_ID: 1
      KAFKA_LOG4J_LOGGERS: "kafka.controller=INFO,kafka.producer.async.DefaultEventHandler=INFO,state.change.logger=INFO"
    volumes:
      - ./zk-single-kafka-multiple/kafka1/data:/var/lib/kafka/data
    depends_on:
      - zoo1
  kafka2:
    image: confluentinc/cp-kafka:5.0.0
    hostname: kafka2
    ports:
      - "9093:9093"
    container_name: docker_kafka_2
    environment:
      KAFKA_ADVERTISED_LISTENERS: LISTENER_DOCKER_INTERNAL://kafka2:19093,LISTENER_DOCKER_EXTERNAL://${DOCKER_HOST_IP:-192.168.56.102}:9093
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: LISTENER_DOCKER_INTERNAL:PLAINTEXT,LISTENER_DOCKER_EXTERNAL:PLAINTEXT
      KAFKA_INTER_BROKER_LISTENER_NAME: LISTENER_DOCKER_INTERNAL
      KAFKA_ZOOKEEPER_CONNECT: "zoo2:2182"
      KAFKA_BROKER_ID: 2
      KAFKA_LOG4J_LOGGERS: "kafka.controller=INFO,kafka.producer.async.DefaultEventHandler=INFO,state.change.logger=INFO"
    volumes:
      - ./zk-single-kafka-multiple/kafka2/data:/var/lib/kafka/data
    depends_on:
      - zoo2
  kafka3:
    image: confluentinc/cp-kafka:5.0.0
    hostname: kafka3
    ports:
      - "9094:9094"
    container_name: docker_kafka_3
    environment:
      KAFKA_ADVERTISED_LISTENERS: LISTENER_DOCKER_INTERNAL://kafka3:19094,LISTENER_DOCKER_EXTERNAL://${DOCKER_HOST_IP:-192.168.56.102}:9094
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: LISTENER_DOCKER_INTERNAL:PLAINTEXT,LISTENER_DOCKER_EXTERNAL:PLAINTEXT
      KAFKA_INTER_BROKER_LISTENER_NAME: LISTENER_DOCKER_INTERNAL
      KAFKA_ZOOKEEPER_CONNECT: "zoo3:2183"
      KAFKA_BROKER_ID: 3
      KAFKA_LOG4J_LOGGERS: "kafka.controller=INFO,kafka.producer.async.DefaultEventHandler=INFO,state.change.logger=INFO"
    volumes:
      - ./zk-single-kafka-multiple/kafka3/data:/var/lib/kafka/data
    depends_on:
      - zoo3
{% endhighlight %}

<h2>
Info
</h2>

Kafka Broker 당 zookeeper 1개씩 페어 <br/>
각 Kafka는 zookeeper를 바라보고 <br/>
zookeeper 끼리 ZOO_SERVERS 값으로 Cluster 공유

