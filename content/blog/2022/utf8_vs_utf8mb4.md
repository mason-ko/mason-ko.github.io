---
layout: post
title:  "utf8 vs utf8mb4 차이"
date:   2022-01-28 12:46:00 +0900
category: 'golang'
draft: false
---

## 개요

- mysql database init 시 database format 설정시

## 차이 

- utf8 의 경우 3바이트 까지 허용
- utf8mb4 의 경우 4바이트 까지 허용

## 확인

```go
func main() {
	//utf8
	a := []byte("a")
	println(len(a))
	a = []byte("한")
	println(len(a))
	a = []byte("𒉲")
	println(len(a))
}
```
```
1
3
4
```
a = 1바이트
한 = 3바이트
𒉲 = 4바이트

## 결론
4바이트까지 허용가능한 데이터가 INPUT 가능할 시 utf8mb4 로 사용하는게 맞고  
3바이트까지 허용하는 기존 데이터의 경우 utf8 로 사용 가능함
