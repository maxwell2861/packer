# Create Image Resources

 > 신규 프로젝트 구축 간 사용되는 Master Image 를 생성합니다.


### Release NOTE
```

# 2019-12-04
    > Azure Image Build Release
       mgmt / db-mgmt / sysgate / linux_base / windows_base

# 2019-11-01
    > Linux1/2 iptables / firewalld disable

# 2019-10-18
    > TCP Bottleneck Bandwidth and RTT 설정 
       https://aws.amazon.com/ko/amazon-linux-ami/2017.09-release-notes/
    > DBMGMT Package Install Script 누락내역 업데이트

# 2019-09-16
    > sysgate sudo 권한 조정
    > DB MGMT 전용 Image 추가
      - gitlab.maxwell.com/mit/dba_script 로부터 전용 Script Download
    > DB MGMT Image 개발자 계정 삭제

# 2019-08-30
    > Qcon Query 변경
        - 기존 tag "service" -> "Env"
    > Linux Vim ColorSet 추가

# 2019-08-26
    > Only Base Image Build Job 추가 
        - AWS_Linux_Base_Build_Job
        - AWS_Windows_Base_Build_Job

# 2019-08-23
    > OS Version Choice 기능 추가 (Windows , Linux )

# 2019-08-22

    > Amazon linux 2 Upload
    > Rundeck Plugin 설치 추가
        - py-winrm-plugin-1.0.12
        - rundeck-ec2-nodes-plugin-1.5.11 
    > haproxy config Download location 변경 (git -> fon-ha)


```

### Pre-requirements

```

2. OPS Bucket 생성 (maxwell-"prefix"-ops)
```

### Create  IMAGE  Resources
```

# OS Version    
    > Amazon linux 2 
    > 2016 / 2019

# Image Type    
    > MGMT 
    > Sysgate
    > OS Base

```
## 설치 Package
 
```
   
- bastion
    - qcon
    
- Common
    - Chef-client v14
    - awscli
    - chocolatey (for windows)
    
```