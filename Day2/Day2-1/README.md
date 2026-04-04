
EFS 마운트 헬퍼 설치
```
sudo dnf install -y amazon-efs-utils
```

마운트 포인트 생성
```
sudo mkdir /<file path>

sudo mount -t efs <file-system-id>:/ /<file-path>
```

EFS 자동 마운트 설정
```
echo '<file-system-id>:/ /<file path> efs defaults,_netdev 0 0' | sudo tee -a /etc/fstab
```

