---
layout: post
title:  "Golang 힙 & 스택 할당 케이스"
date:   2022-01-16 07:01:00 +0900
category: 'golang'
draft: false
---

## Golang 힙 & 스택 할당 케이스

#### 함수내에서 go 루틴 호출 시 매개변수를 넣지 않았을 때에는 힙으로 할당 

```go
package main

import "time"

func main() {
	i := 0

	go func() {
		i = 10
		println(i)
	}()

	time.Sleep(time.Second)
	println(i) // 고루틴 내에서 힙으로 할당되는 i 값을 변경하였기에 10으로 나옴 
}
```
```
10
10
.\main.go:8:5: can inline main.func1
.\main.go:6:2: moved to heap: i
.\main.go:8:5: func literal escapes to heap
```

#### 매개 변수로 전달 시 스택으로 할당되어 사용

```go
package main

import "time"

func main() {
	i := 0

	go func(i int) {
		i = 10
		println(i)
	}(i)

	time.Sleep(time.Second)
	println(i) // 고루틴 내에서 스택으로 할당되는 i 값을 변경하였기 때문에 여기 값에서는 변동없음 
}
```
```
10
0
.\main.go:8:5: can inline main.func1
.\main.go:8:5: func literal escapes to heap
```

#### 흔히하는 실수 케이스
i 값이 힙으로 할당되기 때문에 0~9 까지 정상적으로 출력되지 않으며  
go 루틴 실행 시점에 힙에 할당된 i 주소값의 값이 출력되기 때문에 매번 다른 결과를 출력하게 됨  

```go
package main

import "time"

func main() {
	for i := 0; i < 10; i++ {
		go func() {
			println(i) 
		}()
	}

	time.Sleep(time.Second)
}
```
```
3
10
10
10
10
10
10
10
10
10
.\main.go:7:6: can inline main.func1
.\main.go:6:6: moved to heap: i
.\main.go:7:6: func literal escapes to heap
```

스택으로 할당되도록 수정한다면 정상적으로 0~9 까지의 값이 모두 출력됨  

```go
package main

import "time"

func main() {
	for i := 0; i < 10; i++ {
		go func(i int) {
			println(i) 
		}(i)
	}

	time.Sleep(time.Second)
}
```
```
0
2
6
5
8
3
7
4
9
1
.\main.go:7:6: can inline main.func1
.\main.go:7:6: func literal escapes to heap
```

