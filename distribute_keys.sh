#!/bin/bash
# -------------------------------------------------------------------------
# PC5(Ops) -> 모든 서버(PC1~PC6) SSH 무암호 접속 자동화 스크립트
# -------------------------------------------------------------------------

# 1. sshpass 설치 (비밀번호 자동 입력을 위해 필요)
echo "[1/3] sshpass 설치 중..."
sudo dnf install -y sshpass

# 2. SSH 키가 없으면 생성
if [ ! -f ~/.ssh/id_rsa ]; then
    echo "[2/3] SSH 키 생성 중..."
    ssh-keygen -t rsa -b 2048 -N "" -f ~/.ssh/id_rsa
else
    echo "[2/3] 기존 SSH 키를 사용합니다."
fi

# 3. 배포할 서버 리스트와 비밀번호 설정
# 주의: PASSWORD 부분에 실제 root 비밀번호를 입력하세요.
PASSWORD="centos"
SERVERS=("172.16.6.61" "172.16.6.62" "172.16.6.63" "172.16.6.64" "172.16.6.66")

echo "[3/3] 키 배포 시작..."
for ip in "${SERVERS[@]}"; do
    echo ">> 서버($ip)로 키 복사 중..."
    # 처음 접속 시 물어보는 Yes/No 확인 절차 무시 및 비밀번호 자동 입력
    sshpass -p "$PASSWORD" ssh-copy-id -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa.pub root@$ip
done

echo "----------------------------------------------------"
echo "모든 서버에 키 배포가 완료되었습니다!"
echo "이제 비밀번호 없이 'ssh root@IP' 접속이 가능합니다."
echo "----------------------------------------------------"
