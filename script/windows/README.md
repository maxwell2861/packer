# Script [Windows]

 > Image Build 시 수행되는 Windows Script 목록을 정의합니다 (For AWS)


### Release NOTE
```
2019-12-02
    Azure Windows Base Image Build Job 생성
    
2019.08.23
    Update

```

### Script 실행 순서

```
1. init
    > Packer 로 부터 접속하기 위한 Winrm Default 세팅
    > Administrator , Guest Rename 

2. Common
    > Default User 생성 (Only nkman)
    > Default Directory 생성
    > NSOS 실행
    > Time Server Setting
    > Micolony OS User API Scheduler 등록

3. Package
    > NOW
    > NSMON
    > telnet-client
    > Chocolatey
    > AWSCLI (from chocolatey)
    > Chef-client 14 (from chocolatey)

4. sysprep
    > Windows 2012R2 
    > Windows 2016 / 2019
        - Initialize Instance
    > Cayenne Password 변경


```

