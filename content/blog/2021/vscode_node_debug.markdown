---
layout: post
title:  "VS Code 로 Node js 실행시 resource maps error"
date:   2021-04-08 08:08:46 +0900
category: 'vscode'
draft: false
---

### 발생 추측

VS Code Version 구버전에서는 별 다른 설정 없이 정상 동작되지만

버전이 올라가면서 resouce check 방식이 .map 파일을 사용하도록 변경

### 해결

.vscode/launch.json 파일 configurations 내용에 아래 내용 추가
```
"resolveSourceMapLocations": [
  "${workspaceFolder}/**",
  "!**/node_modules/**"
],
```
  
### 참고
https://github.com/microsoft/vscode/issues/102042#issuecomment-656402933
