---
layout: post
title:  "gatsby-starter-bee 테마 사용 중, git action 에서 gatsby build 에러시"
date:   2022-02-06 16:46:00 +0900
category: 'gatsby'
draft: false
---

## 개요

gatsby-starter-bee 테마 사용, git action 으로 자동 빌드 & 배포 연결한 상태에서  
최근 빌드에러가 발생

## 원인 츠작

gatsby-starter-bee 테마의 경우 node 12x 버전이 강제되는데
> 14x, 16x 는 현재 미지원(https://github.com/JaeYeopHan/gatsby-starter-bee/issues/283)

최근 업데이트 된 gatsby-plugin-robots-txt npm module 이 1.7.0이 되면서

promises 모듈을 require 하는 부분의 문법에서 'fs/promises' << 를 사용하게 되었음

하지만 해당 문법은 node 12.x 에서는 미지원하기 때문에 발생하게 됨

## 해결

해당 테마를 사용하는 관계로 node version 을 올릴 수 없기 때문에  

package.json 내부에서 사용중인 해당 모듈의 버전을

> "gatsby-plugin-robots-txt": "v1.6.14"

에서

> "gatsby-plugin-robots-txt": "1.6.14"

로 변경