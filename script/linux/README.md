# Script [Windows]

 > Image Build 시 수행되는 Linux Script 목록을 정의합니다 (For AWS)


### Release NOTE
```
2020.01.16
    1. init
    > Packer 로부터 접속할 SSH 유저명 Rename 
        - ec2-user -> Cayenne 제거

2019.08.23
    - Update

```

### Script 실행 순서

```
1. init
    > Packer 로부터 접속할 SSH 유저명 Rename 
        - ec2-user -> Cayenne

2. Common
    > User 생성
    > Default Directory 생성
    > NSOS Script 실행 
    > Micolony OS User API Job 등록
    > 미사용 Daemon Service OFF

3. Package
    > Default Yum Package
    > NOW
    > NSMON
    > Chef-client 14

```

