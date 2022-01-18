---
layout: post
title:  "Go Module 에서 접근하는 private git repo 접근 에러 시"
date:   2021-06-07 08:08:46 +0900
category: 'git'
draft: false
---

### 1. Https 경로의 private git repo 접근 에러 시

```
git config --global url."git@github.com:".insteadOf "https://github.com/"
```

위 옵션을 사용해서 https://github.com/ -> git@github.com:  으로 변경해서  
ssh 로 사용 가능


### 2. 위의 케이스에서 Dockerfile 을 통한 container 내부에서 Module 접근 시 

```
git config --global url."https://{ACCESS_TOKEN}:x-oauth-basic@github.com/".insteadOf "https://github.com"
```

github 계정에서 Token 발급하여 해당 토큰을 넣는 방법으로 비공개 레포에 접근


