---
layout: post
title:  "golang metadata outgoing context 가 incoming 으로 되는 과정"
date:   2021-03-17 11:08:46 +0900
author:
  name: Mason Ko
  image: /images/author/man.png
menu:
  sidebar:
    name: golang metadata outgoing context 가 incoming 으로 되는 과정
    parent: 2021
    weight: 10
---

## grpc Metadata 

Client 에서 NewOutgoingContext 로 metadata 를 넣은 후      
Server 에서 FromIncomingContext 로 가져오는 부분에 대한 의문점 

https://github.com/grpc/grpc-go/blob/master/Documentation/grpc-metadata.md

### local test

Test Code
```
func TestContext(t *testing.T) {
	ctx := metadata.NewOutgoingContext(context.Background(), metadata.Pairs("user_id", "ABCD"))
	_, ok := metadata.FromOutgoingContext(ctx)
	assert.Equal(t, ok, true)

	ctx = metadata.NewIncomingContext(context.Background(), metadata.Pairs("user_id", "ABCD"))
	_, ok = metadata.FromIncomingContext(ctx)
	assert.Equal(t, ok, true)
}
```

단순 로컬 테스트 시 New From 이 동일 키 사용되는데       

NewOutgoingContext -> FromOutgoingContext       
NewIncomingContext -> FromIncomingContext

실제로 New Context 하는 과정에서 mdIncomingKey, mdOutgoingKey 각각의 키 값으로 가져오기 때문

하지만 Network 를 타게 되는 경우

Outgoing 으로 넣은 후 FromOutgoing 으로 가져올수 없음 ( Incoming 으로 변환 됨 )

### 추적

grpc call 시 http2 protocol 사용 

https://github.com/grpc-ecosystem/go-grpc-middleware/blob/master/tracing/opentracing/server_interceptors.go

transport.Stream 에 ctx  incoming key 값으로 반환이 됨

transport interface 내 HandleStreams(func(*Stream), func(context.Context, string) context.Context)

실행 과정에서 frame -> MetaHeadersFrame -> state.data.mdata 값으로 NewIncomingContext 를 하여 ctx 를 삽입

mdata 값은 프레임 값을 추출하여 넣는데 

http2.HeadersFrame = FrameHeaders: "HEADERS" = 0x1

outgoing context 로 보낸 Custom Metadata 가 헤더 값에 담겨있는것을 확인

-----

### 정리하자면 

grpc server 내 데이터를 추출 하는 과정에서 Header Frame 에 담겨있는 Custom Metadata 를 IncomingContext 에 담은후 

내부 rpc function 이 실행 되기에 서버측에서는 FromIncomingContext 사용하여 Context 를 가져와야함 

### 그렇기 때문에

proto grpc-gateway build 시 생기는 gw.go 을 보면 

client 입장이 되는 (http mux를 grpc Client와 등록) Register***ServiceHandlerClient 에서는 NewOutgoingContext ( runtime.AnnotateContext ) 에 담아 호출하고

client에서 server를 붙여 사용하는 (http mux를 grpc server와 등록) Register***ServiceHandlerServer 에서는 NewIncomingContext ( runtime.AnnotateIncomingContext ) 에 담아 호출하게 된다.
  


