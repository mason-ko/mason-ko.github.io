---
layout: post
title:  "Golang 할당 효율성"
date:   2022-1-3 03:46:00 +0900
category: 'golang'
draft: false
---

## 최적화

- 조기 최적화는 피한다.
- 프로파일링은 공식 go 블로그 https://go.dev/blog/pprof 를 참조.  

## 이스케이프 분석

- Go는 메모리 할당을 자동으로 관리하며 대부분의 할당은 스택을 사용하며 컴파일러가 똑똑함
- 스택 할당은 저렴 힙 할당은 비싸며 Go 는 스택 합당을 선호

## 힙 할당 확인 

`go build -gcflags '-m'` 으로 확인 가능  
`go build -gcflags '-m -m'` 조금 더 디테일한 확인

##### 포인터를 사용해도 함수 내에서 지역적으로 사용되어 종료된다면 힙 할당이 되지 않는다.

```go
package main

func main() {
	var ii *int
	i := 1
	ii = &i
	print(ii)
}
```
```   
./main.go:3:6: can inline main
```

##### 반대로 함수에서 생성한 포인터 값을 반환하는 함수라면 힙에 할당됨.

```go
package main

func main() {
	print(get())
}

func get() *int {
	i := 1
	return &i
}
```
```   
./main.go:3:6: can inline main
./main.go:7:6: can inline get
./main.go:8:2: moved to heap: i
```

- 채널에 포인터 값 포함 사용 (컴파일 타임에 어떤 고루틴이 채널의 데이터를 받을지 알 방법이 없기때문)
- 슬라이스에 포인터 또는 포인터를 포함하는 값을 저장
- append 용량을 초과 하기 때문에 재할당되는 슬라이스 배열을 지원합니다 .
- 인터페이스 유형에서 메소드 호출. 

## 포인터

대체적으로 값을 복사하는것이 포인터를 사용하는 오버헤드보다 훨씬 저렴


## 출처
[Allocation efficiency in high-performance Go services](https://segment.com/blog/allocation-efficiency-in-high-performance-go-services/) 
