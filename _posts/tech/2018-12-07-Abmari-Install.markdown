---
layout: post
title:  "Ambrai 설치"
date:   2018-12-07 11:08:46 +0900
categories: tech hadoop
permalink: /tech/hadoop/:title
---

<h2>
Install Environment
</h2>

<p>Windows 10 VM 환경</p>

<p>공통</p>
<p>os : centos 7.5.1804</p>

<p>IP</p>
<p>server : 192.168.56.103</p>
<p>agent : 192.168.56.104 </p>

<h2>
방화벽 해제 
</h2>

{% highlight Kconfig %}
sudo systemctl stop firewalld
sudo systemctl disable firewalld 
sudo setenforce 0
{% endhighlight %}

<h2>
Host Name 등록
</h2>

Server
{% highlight Kconfig %}
sudo hostnamectl set-hostname server1.kr
{% endhighlight %}
Agent
{% highlight Kconfig %}
sudo hostnamectl set-hostname agent1.kr
{% endhighlight %}

<h2>
Install Java
</h2>

{% highlight Kconfig %}
sudo yum install -y java-1.8.0-openjdk wget
{% endhighlight %}

<h2>
Install Ambrai Server
</h2>

{% highlight Kconfig %}
sudo wget -nv http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.6.2.2/ambari.repo -O /etc/yum.repos.d/ambari.repo
sudo yum install -y ambari-server
{% endhighlight %}

<h2>
Set FQDN
</h2>

Server와 Agent의 Host 설정

<p>Server</p>

{% highlight Kconfig %}
sudo echo "192.168.56.104   agent1.kr" >> /etc/hosts
{% endhighlight %}

<p>Agent</p>

{% highlight Kconfig %}
sudo echo "192.168.56.103   server1.kr" >> /etc/hosts
{% endhighlight %}

<h2>
Set Password-less SSH
</h2>

Server와 Agent 연결시 바로 접속을 위해 


Agent
{% highlight Kconfig %}
mkdir ~/.ssh
{% endhighlight %}

Server
{% highlight Kconfig %}
ssh-keygen -t dsa -P '' -f ~/.ssh/id_dsa
cat ~/.ssh/id_dsa.pub >> ~/.ssh/authorized_keys
cat ~/.ssh/id_dsa.pub | ssh root@server1.kr 'cat >> ~/.ssh/authorized_keys'
cat ~/.ssh/id_dsa.pub | ssh root@agent1.kr 'cat >> ~/.ssh/authorized_keys';
{% endhighlight %}


<h2>
Check SSH
</h2>

비밀번호 안물어보면 성공

{% highlight Kconfig %}
ssh root@agent1.kr 'ls /'
{% endhighlight %}

<h2>
Install Ambari Server  
</h2>

{% highlight Kconfig %}
ambari-server setup
{% endhighlight %}

<h2>
HTTPS 옵션 사용시  
</h2>

<p>Create SSL Certificate</p>
{% highlight Kconfig %}
sudo mkdir /etc/ssl/private
sudo chmod 700 /etc/ssl/private
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt
sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
{% endhighlight %}

{% highlight Kconfig %}
ambari-server setup-security
{% endhighlight %}


<h2>
시작!  
</h2>

{% highlight Kconfig %}
ambari-server start
{% endhighlight %}

<h2>
Abmari Login  
</h2>

<p>
초기 계정 : admin/admin <br/>
Domain : agent1.kr<br/>
private key : ~/.ssh/id_dsa    // --- 부터 --- 까지 다 포함</p>

<h3>
이제 설치 진행 하다보면 아래 에러가 발생
</h3>

<h2>
EOF occurred in violation of protocol (_ssl.c:579) 발생 시
</h2>

Agent ini 파일 수정

{% highlight Kconfig %}
vi /etc/ambari-agent/conf/ambari-agent.ini
{% endhighlight %}

[security] 항목 아래에 Protocol 추가
{% highlight Kconfig %}
force_https_protocol=PROTOCOL_TLSv1_2
{% endhighlight %}

이후 Retry -> Success

<h3>참고</h3>
[how-to-create-an-ssl-certificate-on-apache-for-centos-7] <br/>
[AMBARI를 이용한 HDP 2.0 설치하기]
[Apache Ambari Security]

[how-to-create-an-ssl-certificate-on-apache-for-centos-7]: https://www.digitalocean.com/community/tutorials/how-to-create-an-ssl-certificate-on-apache-for-centos-7
[AMBARI를 이용한 HDP 2.0 설치하기]: http://guruble.com/ambari/
[Apache Ambari Security]: https://docs.hortonworks.com/HDPDocuments/Ambari-2.6.2.2/bk_ambari-security/content/optional_set_up_ssl_for_ambari.html