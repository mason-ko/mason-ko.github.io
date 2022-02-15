---
layout: post
title:  "Alpine 사용하는 Dockerfile 빌드 dl-cdn 에러시"
date:   2022-01-03 03:46:00 +0900
category: 'golang'
draft: false
---

## 원인

- 간혹 빌드 시 http://dl-cdn.alpinelinux.org/ 해당 이미지 사이트에서 Error 503 Backend is unhealthy 가 발생하여 빌드가 되지 않음
- https://github.com/gliderlabs/docker-alpine/issues/386

## 임시방편 해결방안

Dockerfile 안에서 

```
FROM alpine
```
과

```
RUN apk xxxxxxxxxxx
```
사이에

```
RUN echo -e "http://nl.alpinelinux.org/alpine/v3.15/main\nhttp://nl.alpinelinux.org/alpine/v3.15/community" > /etc/apk/repositories
```
를 넣어서 apk 동작시 타겟이 되는 경로를 변경하여 해결  

dl-cdn 이 정상화 된다면 다시 윗 부분 삭제 필요할듯
