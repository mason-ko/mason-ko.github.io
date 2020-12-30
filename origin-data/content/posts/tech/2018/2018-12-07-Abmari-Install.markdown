---
layout: post
title:  "Ambrai 설치"
date:   2018-12-07 11:08:46 +0900
author:
  name: Mason Ko
  image: /images/author/man.png
menu:
  sidebar:
    name: Ambrai 설치
    parent: 2018
    weight: 10
---

## Install Environment


##### Windows 10 VM 환경

###### 공통
- os : centos 7.5.1804

###### IP
- server : 192.168.56.103
- agent : 192.168.56.104

## 방화벽 해제 

```
sudo systemctl stop firewalld
sudo systemctl disable firewalld 
sudo setenforce 0
```

## Host Name 등록

Server
```
sudo hostnamectl set-hostname server1.kr
```
Agent
```
sudo hostnamectl set-hostname agent1.kr
```

## Install Java

```
sudo yum install -y java-1.8.0-openjdk wget
```

## Install Ambrai Server

```
sudo wget -nv http://public-repo-1.hortonworks.com/ambari/centos7/2.x/updates/2.6.2.2/ambari.repo -O /etc/yum.repos.d/ambari.repo
sudo yum install -y ambari-server
```

## Set FQDN

Server와 Agent의 Host 설정

###### Server

```
sudo echo "192.168.56.104   agent1.kr" >> /etc/hosts
```

###### Agent

```
sudo echo "192.168.56.103   server1.kr" >> /etc/hosts
```

## Set Password-less SSH

Server와 Agent 연결시 바로 접속을 위해 


Agent
```
mkdir ~/.ssh
```

Server
```
ssh-keygen -t dsa -P '' -f ~/.ssh/id_dsa
cat ~/.ssh/id_dsa.pub >> ~/.ssh/authorized_keys
cat ~/.ssh/id_dsa.pub | ssh root@server1.kr 'cat >> ~/.ssh/authorized_keys'
cat ~/.ssh/id_dsa.pub | ssh root@agent1.kr 'cat >> ~/.ssh/authorized_keys';
```


## Check SSH

비밀번호 안물어보면 성공

```
ssh root@agent1.kr 'ls /'
```

## Install Ambari Server  

```
ambari-server setup
```

## HTTPS 옵션 사용시  

###### Create SSL Certificate
```
sudo mkdir /etc/ssl/private
sudo chmod 700 /etc/ssl/private
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt
sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048
```

```
ambari-server setup-security
```


## 시작!  

```
ambari-server start
```

## Abmari Login  

###### 
초기 계정 : admin/admin  
Domain : agent1.kr  
private key : ~/.ssh/id_dsa    // --- 부터 --- 까지 다 포함

#### 이제 설치 진행 하다보면 아래 에러가 발생

## EOF occurred in violation of protocol (_ssl.c:579) 발생 시

Agent ini 파일 수정

```
vi /etc/ambari-agent/conf/ambari-agent.ini
```

[security] 항목 아래에 Protocol 추가
```
force_https_protocol=PROTOCOL_TLSv1_2
```

이후 Retry -> Success

#### 참고
[how-to-create-an-ssl-certificate-on-apache-for-centos-7]   
[AMBARI를 이용한 HDP 2.0 설치하기]   
[Apache Ambari Security]  

[how-to-create-an-ssl-certificate-on-apache-for-centos-7]: https://www.digitalocean.com/community/tutorials/how-to-create-an-ssl-certificate-on-apache-for-centos-7
[AMBARI를 이용한 HDP 2.0 설치하기]: http://guruble.com/ambari/
[Apache Ambari Security]: https://docs.hortonworks.com/HDPDocuments/Ambari-2.6.2.2/bk_ambari-security/content/optional_set_up_ssl_for_ambari.html