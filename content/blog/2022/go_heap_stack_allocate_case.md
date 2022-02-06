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


#### 배열을 매개변수로 전달 시 

힙으로 할당되어졌기 때문에 매개변수로 전달받은 배열 내부의 값을 변경 시 변경됨

```go
package main

import (
	"fmt"
)

func T1(x []int) {
	x[0] = 33
}

func main() {
	x := make([]int, 3, 3)
	x[0] = 1
	x[1] = 2
	x[2] = 3
	fmt.Println(x)
	T1(x)
	fmt.Println(x)
}
```
```
[1 2 3]
[33 2 3]
```

함수 내부에서 배열을 append 했을 때에는 cap size 가 늘어나며  
다른 힙 주소에 할당 되기 때문에 추가된 값이 반영되지 않음


```go
package main

import (
	"fmt"
)

func T1(x []int) {
	x[0] = 33
	println(x)
	x = append(x, 99)
	println(x)
}

func main() {
	x := make([]int, 3, 3)
	x[0] = 1
	x[1] = 2
	x[2] = 3
	fmt.Println(x)
	T1(x)
	fmt.Println(x)
}
```
```
[1 2 3]
[3/3]0xc00000c120
[4/6]0xc00000a420
[33 2 3] 
```

cap size 가 하나 더 할당이 되어있다면 동일한 힙 주소가 사용되어져  
함수 내부에서 append 를 하였더라도 힙 주소가 변경되어지지 않음  
하지만, 내부에서 추가한 값은 함수 바깥에는 적용되지 않음

```go
package main

import (
	"fmt"
)

func T1(x []int) {
	x[0] = 33
	println(x) // 2
	x = append(x, 99)
	println(x) // 3
	fmt.Println(x) // 4
}

func main() {
	x := make([]int, 3, 4)
	x[0] = 1
	x[1] = 2
	x[2] = 3
	fmt.Println(x) // 1
	T1(x)
	fmt.Println(x) // 5
}
```
```
[1 2 3]
[3/4]0xc00000e200
[4/4]0xc00000e200
[33 2 3 99]      
[33 2 3] 
```