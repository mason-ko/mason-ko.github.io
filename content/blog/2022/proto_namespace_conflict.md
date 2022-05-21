---
layout: post
title:  "proto build namespace conflict 대비 및 역추적"
date:   2022-05-20 04:46:00 +0900
category: 'protobuf'
draft: false
---

## 문제 원인

프로토 파일 명이 동일한 파일이 있는 상태에서 실행시 panic 발생 

## 문제 원인 

프로토 파일명이 동일 했을 시 패닉 발생  

https://developers.google.com/protocol-buffers/docs/reference/go/faq#namespace-conflict

## 조치 

1.25 버전까지는 해당 에러는 warning 으로 발생하였기 때문에 패닉에러가 발생하지 않았지만 1.26 부터 패닉에러로 변경이 되어져  
아래와 같은 방법으로 임시적으로 대처가 가능하다. 

1. google.golang.org/protobuf 버전을 강제로 1.25로 내림 (go.mod 안에서 replace)

2. 환경변수에 GOLANG_PROTOBUF_REGISTRATION_CONFLICT=warn 을 넣어서 해결  

위 방법은 임시적인 조치이고  

proto file 들을 중앙 집중식 Go 패키지 형태로 변경 하는 방법이 근본적인 문제 해결 방안임. 
( model/model.proto 와 같이 동일한 path => proto 파일명을 사용하면 안되고 파일명에 버전명 기입 = 동일한 파일명 x )  

## 원인 추적 

실제로 go process 안에서 proto file을 read 하지 않는데 proto file 명 중복을 확인하는 부분이 궁금하여 추적해본결과  

--- 

protoregistry/registry.go 파일의 

RegisterFile(file protoreflect.FileDescriptor) 함수 내에서  

file의 path가 동일한지 확인하며, 같을 시 에러를 발생 시킴  

해당 부분의 파일 path (proto file path) 는 

make proto 시 

protoreflect.FileDescriptor 정보가 pb.go 파일의 file_model_model_proto_rawDesc 안에 []byte 로 담기는것을 확인하였음.

+ 그렇기 때문에 실제로 해당 경로의 proto 파일을 스태틱하게 읽지는 않음.
