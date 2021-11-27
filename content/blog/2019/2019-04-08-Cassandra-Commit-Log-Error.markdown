---
layout: post
title:  "Cassandra Commit log 충돌로 인한 Restart 불가 현상"
date:   2019-04-08 17:26:00 +0900
category: 'cassandra'
draft: false
---

## 원인

Cassandra가 비정상 종료됬을때 발생.

## 해결방안

Mount된 Commit log 폴더의 내용을 삭제  

or  

ignorereplayerrors 를 true로 줌   

```
Environment
- JVM_OPTS : "-Dcassandra.commitlog.ignorereplayerrors=true"
```


#### 참고
[cassandra CrashLooping due to invalid commit log]  

[cassandra CrashLooping due to invalid commit log]: https://bugzilla.redhat.com/show_bug.cgi?id=1385427