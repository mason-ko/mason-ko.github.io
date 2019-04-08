---
layout: post
title:  "Cassandra Commit log 충돌로 인한 Restart 불가 현상"
date:   2019-04-08 17:26:00 +0900
categories: tech docker
permalink: /tech/docker/:title
---

<h2>
원인
</h2>

Cassandra가 비정상 종료됬을때 발생.

<h2>
해결방안
</h2>

Mount된 Commit log 폴더의 내용을 삭제 <br/>

or <br/>

ignorereplayerrors 를 true로 줌 <br/> 

{% highlight Kconfig %}
Environment
- JVM_OPTS : "-Dcassandra.commitlog.ignorereplayerrors=true"
{% endhighlight %}


<h3>참고</h3>
[cassandra CrashLooping due to invalid commit log] <br/>

[cassandra CrashLooping due to invalid commit log]: https://bugzilla.redhat.com/show_bug.cgi?id=1385427