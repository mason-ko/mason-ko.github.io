---
layout: post
title:  "Redis Cluster"
date:   2019-03-20 10:00:00 +0900
category: 'redis'
draft: false
---

## Docker Compose File

docker-compose.yaml

```
version: "3.1"
services:
  redis-master-1:
    image: redis:5.0.2-alpine
    ports:
      - 7000:7000
    command: sh -c "redis-server --port 7000 --cluster-enabled yes --cluster-config-file nodes.conf --cluster-node-timeout 5000"
    networks:
      redisnet:
        ipv4_address: 10.0.0.2
  redis-master-2:
    image: redis:5.0.2-alpine
    ports:
      - 7001:7001
    command: sh -c "redis-server --port 7001 --cluster-enabled yes --cluster-config-file nodes.conf --cluster-node-timeout 5000"
    networks:
      redisnet:
        ipv4_address: 10.0.0.3
    depends_on:
      - redis-master-1    
  redis-master-3:
    image: redis:5.0.2-alpine
    ports:
      - 7002:7002
    command: sh -c "redis-server --port 7002 --cluster-enabled yes --cluster-config-file nodes.conf --cluster-node-timeout 5000"
    networks:
      redisnet:
        ipv4_address: 10.0.0.4
    depends_on:
      - redis-master-2
  redis-slave-1:
    image: redis:5.0.2-alpine
    ports:
      - 7003:7003
    command: sh -c "redis-server --port 7003 --cluster-enabled yes --cluster-config-file nodes.conf --cluster-node-timeout 5000"
    networks:
      redisnet:
        ipv4_address: 10.0.0.5
    depends_on:
      - redis-master-3
  redis-slave-2:
    image: redis:5.0.2-alpine
    ports:
      - 7004:7004
    command: sh -c "redis-server --port 7004 --cluster-enabled yes --cluster-config-file nodes.conf --cluster-node-timeout 5000"
    networks:
      redisnet:
        ipv4_address: 10.0.0.6
    depends_on:
      - redis-master-3
  redis-slave-3:
    image: redis:5.0.2-alpine
    ports:
      - 7005:7005
    command: sh -c "redis-server --port 7005 --cluster-enabled yes --cluster-config-file nodes.conf --cluster-node-timeout 5000 --daemonize yes && yes yes | redis-cli --cluster create 10.0.0.2:7000 10.0.0.3:7001 10.0.0.4:7002 10.0.0.5:7003 10.0.0.6:7004 10.0.0.7:7005 --cluster-replicas 1 && while sleep 3600; do :; done"
    networks:
      redisnet:
        ipv4_address: 10.0.0.7
    depends_on:
      - redis-master-1
      - redis-master-2
      - redis-master-3
      - redis-slave-1
      - redis-slave-2
networks:
  redisnet:
    driver: bridge
    ipam:
      config:
        - subnet: 10.0.0.0/16
```

## Info

3개 이상의 마스터를 구성  
한쪽 클러스의 영역 ( 마스터, 슬레이브 ) 전부 죽었을 시 Cluster Down으로  
동작되지 않음  CLUSTERDOWN The cluster is down  
그 후 슬레이브만 부활했을 때에 자동적으로 Master가 되지 않고 계속 Master를 찾음 ( 결국 전부 다 죽었을 때는 Master가 살아 난 이후 정상 동작임 )  
Master 가 있을 시 Master로만 사용되며 Master가 죽었을 시 Slave가 마스터가 되어 동작함 ( Active - stand by )  

------------------------------------------------------------------------------------  

Redis Cluster를 사용시 Cluster에 대한 Index 정보 ( Hashslot ) 값이 추가로 저장되어야 하기 때문에  
사용하는 Data (memory)가 증가하고 리다이렉션이 필요하기 때문에  
샤딩이 필요없는 소규모에는 Sentinel 사용이 좋을듯

#### 참고
[Redis Cluster Tutorial]  

[Redis Cluster Tutorial]: https://redis.io/topics/cluster-tutorial