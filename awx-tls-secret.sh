
# install nginx-ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml

kubectl create ns awx

kubectl config set-context --current --namespace=awx

kubectl create secret tls awx-tls-secret   --cert=<(echo "$TENANTS_LB_CRT" | base64 -d)   --key=<(echo "$TENANTS_LB_KEY" | base64 -d)   -n awx

cd awx-operator/

make deploy
kubectl apply -f ../awx-cr.yaml
