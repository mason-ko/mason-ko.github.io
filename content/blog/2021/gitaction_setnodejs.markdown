---
layout: post
title:  "Git Action 에서 node js version 설정"
date:   2021-12-06 06:02:46 +0900
category: 'git'
draft: false
---

## 상황

현재 사용중인 개츠비 테마에서 node js version dependency 가 12 버전대로 걸려있는 상태라서

deploy 시 에러 발생

## yaml file 에 추가

steps 에 node js version 설정
```yaml
    - name: set nodejs ver
        uses: actions/setup-node@v2
        with:
          node-version: '12'
```

최종 파일

```yaml
name: gatsby deploy

on:
  push:
    branches: gh-pages

jobs:
  deploy:
    name: deploy
    runs-on: ubuntu-latest

    steps:
      - name: checkout code
        uses: actions/checkout@v2
      - name: set nodejs ver
        uses: actions/setup-node@v2
        with:
          node-version: '12'

      - name: packages install
        run: yarn install

      - name: gatsby build
        run: yarn build
        env:
          GH_API_KEY: ${{ secrets.ACTION }}

      - name: deploy
        uses: maxheld83/ghpages@v0.3.0
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          GH_PAT: ${{ secrets.ACTION }}
          BUILD_DIR: 'public/'
```