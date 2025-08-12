1. get bare commands

kubectl get services
kubectl get pods
kubectl get deployments

2. get more details

kubectl get deployments --all-namespaces 
kubectl get nodes --show-labels

2. get deployments formatted

kubectl get deployments -o json
kubectl get depolyments -o yaml
kubectl get deployments --output=custom-columns="KIND:,kind,NAME:.metadata.name,NAMESPACE:.metadata.namespace,IMAGE:.spec.template.spec.containers[*].image"