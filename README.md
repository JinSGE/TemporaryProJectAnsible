# TemporaryProJectAnsible

# 전체 코드에 대한 주석 추가 + 좀 더 구조적인 설계 완료
# (단, 중복해서 돌렸을 시에 동작 오류나는 파트는 수정해야함.)

# PC6-헬름+프로메테우스+그라파나 연동 약간 수정해야함
------------------------------------------
# 1. Helm 설치 및 저장소 설정
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh && ./get_helm.sh
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# 2. 프로메테우스 단독 설치 (Standalone)
helm upgrade --install prometheus prometheus-community/prometheus \
--namespace monitoring --create-namespace \
--set alertmanager.enabled=false \
--set pushgateway.enabled=false \
--set server.persistentVolume.enabled=false

# 3. 그라파나 단독 설치 (NodePort: 30432 / PW: admin123!)
helm upgrade --install grafana grafana/grafana \
--namespace monitoring \
--set adminPassword=admin123! \
--set service.type=NodePort \
--set service.nodePort=30432

# 4. Flannel 네트워크 복구 (사용자 대역 10.244.0.0/24 반영)
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml
mkdir -p /run/flannel
cat <<EOF > /run/flannel/subnet.env
FLANNEL_NETWORK=10.244.0.0/24
FLANNEL_SUBNET=10.244.0.1/24
FLANNEL_MTU=1450
FLANNEL_IPMASQ=true
EOF
kubectl delete pods -n kube-flannel --all

# 5. 상태 확인 (모든 포드가 Running 1/1이 될 때까지 대기)
kubectl get nodes
kubectl get pods -n kube-system -l k8s-app=kube-dns
kubectl get pods -n monitoring
kubectl get svc -n monitoring

# 6. 접속 정보 요약
# [Grafana Web] http://172.16.6.66:30432 (admin / admin123!)
# [Prometheus URL] http://10.100.176.220:80 (그라파나 내부 연동용)
--------------------------------------------------------------
