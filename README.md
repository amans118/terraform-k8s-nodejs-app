# DevOps Engineer Assignment

This reporsiotry includes Terraform code for deploying a nodejs app/server on Kubernetes using a custom docker image hosted on a private ECR registry.

## How to Login and pull an image from ECR

* Go to your AWS ECR repository and click on “view push commands”.
* Run the first command to authenticate to your ECR registry . (Assuming AWS CLI is configured)
* Docker stores its credentials in **.docker/config.json**. We need to base64 encode this file to use in our secret manifest (only if applying k8s manifest manually, not required in case of Terraform)
* Run
```bash
$ cat .docker/config.json | base64
```
* Copy the output of above command and paste it in the secret manifest like this:
```bash
apiVersion: v1
kind: Secret
metadata:
  name: docker-key
data:
  .dockerconfigjson: <base64-encoded-docker-config-here>
type: kubernetes.io/dockerconfigjson
```
* This could also be done in a single command like this,
```bash
$ kubectl create secret generic docker-key \
    --from-file=.dockerconfigjson=.docker/config.json \
    --type=kubernetes.io/dockerconfigjson
```
* In deployment manifest, under the spec section for containers, specify:
```bash
spec:
	  imagePullSecrets:
	  - name: docker-key
```
## Usage

```bash
$ git clone https://github.com/amans118/terraform-k8s-nodejs-app.git
$ cd terraform-k8s-nodejs-app
$ terraform init
$ terraform plan
$ terraform apply --auto-approve
```
## Load Testing and Results
* To increased load. We will start a container, and send an infinite loop of queries to the nodejs-app service.
* Run the following command:
```bash
$ kubectl run -it --rm load-generator --image=busybox /bin/sh
$ while true; do wget -q -O- http://service_name:port; done
```
### output
```bash
osboxes@kubemaster:~/terraform-k8s-nodejs-app$ kubectl get hpa -w

NAME         REFERENCE               TARGETS            MINPODS   MAXPODS   REPLICAS   AGE
nodejs-app   Deployment/nodejs-app   22%/60%, 41%/50%   7         15        10         96m
nodejs-app   Deployment/nodejs-app   22%/60%, 41%/50%   7         15        10         97m
nodejs-app   Deployment/nodejs-app   43%/60%, 88%/50%   7         15        10         97m
nodejs-app   Deployment/nodejs-app   43%/60%, 88%/50%   7         15        15         98m
nodejs-app   Deployment/nodejs-app   41%/60%, 50%/50%   7         15        15         98m
nodejs-app   Deployment/nodejs-app   41%/60%, 58%/50%   7         15        15         99m
nodejs-app   Deployment/nodejs-app   42%/60%, 0%/50%    7         15        15         100m
nodejs-app   Deployment/nodejs-app   40%/60%, 0%/50%    7         15        15         101m
nodejs-app   Deployment/nodejs-app   40%/60%, 0%/50%    7         15        15         105m
nodejs-app   Deployment/nodejs-app   40%/60%, 0%/50%    7         15        11         105m
nodejs-app   Deployment/nodejs-app   42%/60%, 0%/50%    7         15        11         106m
nodejs-app   Deployment/nodejs-app   42%/60%, 0%/50%    7         15        10         106m
nodejs-app   Deployment/nodejs-app   43%/60%, 0%/50%    7         15        10         107m
```

#### Important:
*If testing this on a local cluster (kubeadm on Virtualbox VM's), please make these two changes*:
* in **hpa.tf**
```bash
module "metrics_server" {
  source                                     = "cookielab/metrics-server/kubernetes"
  version                                    = "0.10.0"
  metrics_server_option_kubelet_insecure_tls = "true"
  metrics_server_option_kubelet_preferred_address_types = [ "InternalIP", "ExternalIP", "Hostname", "InternalDNS", "ExternalDNS" ]
}
```
* Also, need to edit metrics-server deployment and add **hostNetwork: true** 
```bash
$ kubectl -n kube-system edit deployment metrics-server
spec:
  hostNetwork: true
  containers:
 ```

#### All the kubernetes manifest for the Project can be found here:
https://github.com/amans118/kubernetes-nodejs-app
