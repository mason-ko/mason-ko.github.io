---
layout: post
title:  "Docker Debug With Rider"
date:   2019-05-17 11:03:00 +0900
category: 'docker'
draft: false
---

## 1. Rider에서 Docker 사용

<h4>
Docker On Windows 사용할때 Check
</h4>

![](../images/20190517/capture1.png)
![](./images/20190517/capture2.png)

<h4>
Create Dockerfile (ConsoleApp1.project)
</h4>

```
FROM microsoft/dotnet:2.1-aspnetcore-runtime as base

FROM microsoft/dotnet:2.1-sdk as build
WORKDIR /src

COPY ConsoleApp1/ConsoleApp1.csproj ConsoleApp1/

RUN dotnet restore ConsoleApp1/ConsoleApp1.csproj

COPY . .
WORKDIR /src/ConsoleApp1

RUN dotnet build ConsoleApp1.csproj -c Release -o /app

FROM build as publish
RUN dotnet publish ConsoleApp1.csproj -c Release -o /app

FROM base AS final
WORKDIR /app
COPY --from=publish /app .

ENTRYPOINT ["dotnet", "ConsoleApp1.dll"]
```

추가 설정  
![](./images/20190517/capture3.png)
![](./images/20190517/capture4.png)

## 2. Mono Debugging

![](./images/20190517/capture5.png)

<h4>
가끔 dll 이 출력폴더에 복사되지 않을때
</h4>

![](./images/20190517/capture6.png)

#### 참조 Mono Debugging 문서

[Creating and Editing Run/Debug Configurations]  
[Remote Debugging with Mono]  

[Creating and Editing Run/Debug Configurations]: https://www.jetbrains.com/help/rider/Creating_and_Editing_Run_Debug_Configurations.html
[Remote Debugging with Mono]: https://www.jetbrains.com/help/rider/Remote_Debugging_with_Mono.html#debugging-options

