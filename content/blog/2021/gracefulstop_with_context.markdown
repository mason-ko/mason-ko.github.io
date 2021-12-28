---
layout: post
title:  "Golang 으로 단일 프로세스에서 여러개의 서버를 띄웠을 시 정상 종료 시키기"
date:   2021-12-27 19:27:46 +0900
category: 'golang'
draft: false
---

## 개요

단일 프로세스에서, 동기적으로 대기가 필요한 여러개의 서버를 띄운 상태에서 (grpc, subscriber 등)

각 서버 역할을 하는 부분에 정상적으로 종료가 되도록 하기 위함 

ex) 쿠버네티스 Pod의 교체가 실행이 될 때, subscriber message 가 처리 되기 이전에 process 가 종료되어 메시지의 유실이 발생 가능성 존재

## 처리형태


#### 1.

하위 파생된 모든 컨텍스트에게 정지 요청을 보낼 수 있도록 최상단에서 캔슬이 가능한 컨텍스트, 그룹 컨텍스트, 정지 요청을 보낼 수 있도록 doneChan 생성

```go
parent, pCancel := context.WithCancel(context.Background())
eg, _ := errgroup.WithContext(parent)
doneChan := make(chan struct{}, 3)
```
  
#### 2. 

Listen 이 필요한 부분이 A,B,C 가 있다고 할 시

각 부분을 고루틴으로 동시에 띄워 동시에 Listen 함

#### 3. 

각 Server 를 errgroup 을 사용하여 그룹화 된 고루틴을 사용 하며, 사용중인 모듈의 아래 코드와 같이 

그룹 수 만큼 대기하며, 모든 그룹이 종료될때 까지 wait 

```go
import "golang.org/x/sync/errgroup"

// Wait blocks until all function calls from the Go method have returned, then
// returns the first non-nil error (if any) from them.
func (g *Group) Wait() error {
	g.wg.Wait()
	if g.cancel != nil {
		g.cancel()
	}
	return g.err
}

// Go calls the given function in a new goroutine.
//
// The first call to return a non-nil error cancels the group; its error will be
// returned by Wait.
func (g *Group) Go(f func() error) {
	g.wg.Add(1)

	go func() {
		defer g.wg.Done()

		if err := f(); err != nil {
			g.errOnce.Do(func() {
				g.err = err
				if g.cancel != nil {
					g.cancel()
				}
			})
		}
	}()
}
```

#### 4. 

리슨 중인 여러 고루틴 중 하나라도 문제가 생겨 서버 종료를 알리기 위해

doneChan 에 알리며 doneChan 으로 종료됨을 요청 받을 시 최상단에서 생성한 cancel function 을 호출


```go
eg.Go(func() error {
	fmt.Println("Server C Start")
	<-parent.Done() 
	fmt.Println("Server C End")
	doneChan <- struct{}{} // <<
	return nil
})

select {
case <-doneChan:
	pCancel()
}
```

#### 5.

그룹화 된 고루틴에서의 종료가 아닌, os interrupt 로 인한 정상 정지 프로세스에서도 

cancel function 을 호출 

```go
interrupt := make(chan os.Signal, 1)
signal.Notify(interrupt, os.Interrupt, syscall.SIGTERM)
defer close(interrupt)

select {
case <-interrupt:
	pCancel()
}
```

#### 6.

그룹화 된 고루틴에서 모든 서버들이 정상적으로 모두 종료될 수 있도록 

하단에서 wait

```go
if err := eg.Wait(); err != nil {
	log.Println(err)
}
```

## 전체코드

```go
package main

import (
	"context"
	"fmt"
	"golang.org/x/sync/errgroup"
	"log"
	"os"
	"os/signal"
	"syscall"
	"time"
)

func main() {
	parent, pCancel := context.WithCancel(context.Background())
	eg, _ := errgroup.WithContext(parent)
	doneChan := make(chan struct{}, 3)

	eg.Go(func() error {
		fmt.Println("Server A Start")
		<-parent.Done() // listen
		fmt.Println("Server A End")
		doneChan <- struct{}{}
		return nil
	})

	eg.Go(func() error {
		fmt.Println("Server B Start")
		<-parent.Done() // listen
		fmt.Println("Server B End")
		doneChan <- struct{}{}
		return nil
	})

	eg.Go(func() error {
		fmt.Println("Server C Start")
		<-parent.Done() // listen
		fmt.Println("Server C End")
		doneChan <- struct{}{}
		return nil
	})

	interrupt := make(chan os.Signal, 1)
	signal.Notify(interrupt, os.Interrupt, syscall.SIGTERM)
	defer close(interrupt)

	select {
	case <-doneChan:
		pCancel()
	case <-interrupt:
		pCancel()
	}

	if err := eg.Wait(); err != nil {
		log.Println(err)
	}

	fmt.Println("---END---")
}
```
---
```
Server B Start
Server A Start
Server C Start
Server B End
Server C End
Server A End
---END---
```