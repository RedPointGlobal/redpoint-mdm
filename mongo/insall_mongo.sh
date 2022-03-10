# Install MongoDB Operator
kubectl apply -f crd/bases/mongodbcommunity.mongodb.com_mongodbcommunity.yaml -n rp-mdm-demo
kubectl apply -k rbac/ --namespace rp-mdm-demo
kubectl create -f operator/manager.yaml --namespace rp-mdm-demo

# Install MongoDB Replica Set

kubectl apply -f replicaset/mongodb.com_v1_mongodbcommunity_cr.yaml --namespace rp-mdm-demo

# Extract the connection string
kubectl get secret db-mdm-mongo-admin-redpointops -n rp-mdm-demo -o json | jq -r '.data | with_entries(.value |= @base64d)'


