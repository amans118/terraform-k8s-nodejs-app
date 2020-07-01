# DevOps Engineer Assignment

This reporsiotry includes Terraform code for deploying a nodejs app/server on Kubernetes using a custom docker image hosted on a private ECR registry.

## How to Login and pull an image from ECR

* Go to your AWS ECR repository and click on “view push commands”.
* Run the first command to authenticate to your ECR registry . (Assuming AWS CLI is configured)
* Docker stores its credentials in **.docker/config.json**. We need to base64 encode this file to use in our secret manifest (only if applying k8s manifest manually, not required in case of Terraform)
* Run
```bash
cat .docker/config.json | base64
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
kubectl create secret generic docker-key \
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
git clone https://github.com/amans118/terraform-k8s-nodejs-app.git
cd terraform-k8s-nodejs-app
terraform init
terraform plan
terraform apply --auto-approve
```
#### All the kubernetes manifest for the Project can be found here:
https://github.com/amans118/kubernetes-nodejs-app
