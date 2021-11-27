---
layout: post
title:  "Cassandra Cluster Docker Compose Yaml"
date:   2019-01-21 11:00:00 +0900
category: 'cassandra'
draft: false
---

## Docker Compose File

docker-compose.yaml

```
version: '2'
services:
  cassandra1:
    image: cassandra
    ports:
      - 7000:7000
      - 7001:7001
      - 9160:9160
      - 9042:9042
    environment:
      CASSANDRA_BROADCAST_ADDRESS: "10.5.0.10"
      CASSANDRA_SEEDS: "10.5.0.10"
      CASSANDRA_CLUSTER_NAME: "Test Cluster"
      CASSANDRA_DC: "DC1"
      CASSANDRA_RACK: "RAC1"
      CASSANDRA_ENDPOINT_SNITCH: "GossipingPropertyFileSnitch"
      CASSANDRA_START_RPC: "true"
    hostname: cassandra1
    container_name: docker_cassandra_1
    logging:
      driver: json-file
      options:
        max-size: 50m
    networks:
      cassnw:
        ipv4_address: 10.5.0.10
  cassandra2:
    image: cassandra
    environment:
      CASSANDRA_BROADCAST_ADDRESS: "10.5.0.10"
      CASSANDRA_SEEDS: "10.5.0.10"
      CASSANDRA_CLUSTER_NAME: "Test Cluster"
      CASSANDRA_DC: "DC1"
      CASSANDRA_RACK: "RAC1"
      CASSANDRA_ENDPOINT_SNITCH: "GossipingPropertyFileSnitch"
      CASSANDRA_START_RPC: "true"
    hostname: cassandra2
    container_name: docker_cassandra_2
    logging:
      driver: json-file
      options:
        max-size: 50m
    networks:
      cassnw:
        ipv4_address: 10.5.0.11
  cassandra3:
    image: cassandra
    environment:
      CASSANDRA_BROADCAST_ADDRESS: "10.5.0.10"
      CASSANDRA_SEEDS: "10.5.0.10"
      CASSANDRA_CLUSTER_NAME: "Test Cluster"
      CASSANDRA_DC: "DC1"
      CASSANDRA_RACK: "RAC1"
      CASSANDRA_ENDPOINT_SNITCH: "GossipingPropertyFileSnitch"
      CASSANDRA_START_RPC: "true"
    hostname: cassandra3
    container_name: docker_cassandra_3
    logging:
      driver: json-file
      options:
        max-size: 50m
    networks:
      cassnw:
        ipv4_address: 10.5.0.12
    
networks:
  cassnw:
    driver: bridge
    ipam:
      config:
        - subnet: 10.5.0.0/16
          gateway: 10.5.0.1
```

## Info

Cluster 사용시 아래 환경변수로 사용시   
docker-compose up -d 이후  
cassandra.yaml 파일의 broadcast_address 부분을 주석처리해야함  

실행 후

```
docker exec -it docker_cassandra_1 sed -i 's/broadcast_address:/#broadcast_address:/' /etc/cassandra/cassandra.yaml
docker exec -it docker_cassandra_2 sed -i 's/broadcast_address:/#broadcast_address:/' /etc/cassandra/cassandra.yaml
docker exec -it docker_cassandra_3 sed -i 's/broadcast_address:/#broadcast_address:/' /etc/cassandra/cassandra.yaml
docker-compose -f docker.yaml restart
```

필요
