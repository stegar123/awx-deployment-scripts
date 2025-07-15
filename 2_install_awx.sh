
# install nginx-ingress
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.1/deploy/static/provider/cloud/deploy.yaml

# install nfs csi drivers


curl -skSL https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/refs/heads/master/deploy/install-driver.sh | bash -s v4.9.0 --

kubectl create ns awx

kubectl config set-context --current --namespace=awx

# create secret for 
kubectl create secret tls awx-tls-secret   --cert=<(echo "$TENANTS_LB_CRT" | base64 -d)   --key=<(echo "$TENANTS_LB_KEY" | base64 -d)   -n awx

# create nfs server
kubectl apply -f nfs-server.yml 

kubectl  apply -f linode-nfs-storage.yml

cd awx-operator/

make deploy

kubectl apply -f ../awx-cr.yaml
