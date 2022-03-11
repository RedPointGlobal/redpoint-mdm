# Install MongoDB Operator
kubectl apply -f crd/bases/mongodbcommunity.mongodb.com_mongodbcommunity.yaml -n redpoint-mdm
kubectl apply -k rbac/ --namespace redpoint-mdm
kubectl create -f operator/manager.yaml --namespace redpoint-mdm

# Install MongoDB Replica Set

kubectl apply -f replicaset/mongodb.com_v1_mongodbcommunity_cr.yaml --namespace redpoint-mdm

# Extract the connection string
kubectl get secret db-mdm-mongo-admin-redpointops -n redpoint-mdm -o json | jq -r '.data | with_entries(.value |= @base64d)'


