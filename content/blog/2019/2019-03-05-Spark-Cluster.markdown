---
layout: post
title:  "Spark Cluster Docker Compose Yaml"
date:   2019-03-05 14:00:00 +0900
category: 'spark'
draft: false
---

## Docker Compose File

docker-compose.yaml

```
version: "3.0"
services:
  spark-master:
    image: bde2020/spark-master:2.3.2-hadoop2.7
    container_name: spark-master
    ports:
      - "8083:8083"
      - "7077:7077"
    environment:
      - INIT_DAEMON_STEP=setup_spark
      - "constraint:node==<yourmasternode>"
  spark-worker-1:
    image: bde2020/spark-worker:2.3.2-hadoop2.7
    container_name: spark-worker-1
    depends_on:
      - spark-master
    ports:
      - "8081:8081"
    environment:
      - "SPARK_MASTER=spark://spark-master:7077"
      - "constraint:node==<yourmasternode>"
  spark-worker-2:
    image: bde2020/spark-worker:2.3.2-hadoop2.7
    container_name: spark-worker-2
    depends_on:
      - spark-master
    ports:
      - "8082:8082"
    environment:
      - "SPARK_MASTER=spark://spark-master:7077"
      - "constraint:node==<yourworkernode>"
```

## Info

Spark Master - Worker  
