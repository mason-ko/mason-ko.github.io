---
layout: post
title:  "Redis Warning 해결"
date:   2019-04-08 11:26:00 +0900
categories: tech docker
permalink: /tech/docker/:title
---

<h2>
1. overcommit_memory
</h2>

Host PC에서 실행

{% highlight Kconfig %}
sudo sysctl vm.overcommit_memory=1

#재부팅시 적용되려면
vi /etc/sysctl.conf
# 추가
net.core.somaxconn=1024
{% endhighlight %}



<h2>
2. THP Disable
</h2>

Host PC에서 실행

{% highlight Kconfig %}
echo never > /sys/kernel/mm/transparent_hugepage/enabled

#재부팅시 적용되려면
vi /etc/rc.local
# 추가
echo never > /sys/kernel/mm/transparent_hugepage/enabled
exit 0
{% endhighlight %}


<h2>
3. TCP Backlog
</h2>

Docker Compose yaml에 내용 추가 ( 65535 까지 가능 ) <br/>
sysctls 은 docker compose version 2.1 이상부터 가능함을 확인

{% highlight Kconfig %}
sysctls:
  - net.core.somaxconn=1024
{% endhighlight %}


<h3>참고</h3>
[Redis 설치 후 Warning 제거하기] <br/>
[Docker Docs] <br/>

[Redis 설치 후 Warning 제거하기]: https://www.tutorialbook.co.kr/entry/Redis-%EC%84%A4%EC%B9%98-%ED%9B%84-Warning-%EC%A0%9C%EA%B1%B0%ED%95%98%EA%B8%B0
[Docker Docs]: https://docs.docker.com/compose/compose-file/#sysctls