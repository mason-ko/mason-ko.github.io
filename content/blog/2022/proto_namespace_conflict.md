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

## 임시 조치 

1.25 버전까지는 해당 에러는 warning 으로 발생하였고 아래와 같은 방법으로 임시적으로 대처가 가능하다. 

1. google.golang.org/protobuf 버전을 강제로 1.25로 내리거나  

2. proto file 들을 중앙 집중식 Go 패키지 형태로 변경 하거나 ( model/model.proto 와 같이 동일한 path => proto 파일명을 사용하면 안되고 파일명에 버전명 기입 = 동일한 파일명 x )  

3. 환경변수에 GOLANG_PROTOBUF_REGISTRATION_CONFLICT=warn 을 넣어서 해결  

## 원인 추적 

protoregistry/registry.go 안의  

RegisterFile(file protoreflect.FileDescriptor) 함수 내에서  

file의 path가 동일한지 확인하며, 같을 시 에러를 발생 시킴  

해당 부분의 파일 path 는  

make proto 시 

protoreflect.FileDescriptor 정보가 pb.go 파일내의 file_model_model_proto_rawDesc 안에 []byte 로 담기는것을 확인하였음.

위 bytes 를 사용해서 위에서 정리한 부분을 체크함  

그렇기 때문에 실제로 해당 경로의 proto 파일을 직접적으로 읽지는 않음.
