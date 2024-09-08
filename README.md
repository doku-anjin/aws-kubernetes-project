
## Getting Started

### Dependencies
#### Local Environment
1. Python Environment - run Python 3.6+ applications and install Python dependencies via `pip`
2. Docker CLI - build and run Docker images locally
3. `kubectl` - run commands against a Kubernetes cluster
4. `helm` - apply Helm Charts to a Kubernetes cluster

#### Remote Resources
1. AWS CodeBuild - build Docker images remotely
2. AWS ECR - host Docker images
3. Kubernetes Environment with AWS EKS - run applications in k8s
4. AWS CloudWatch - monitor activity and logs in EKS
5. GitHub - pull and clone code

### Setup
 1. Configure a cluster: (Using command line) 

_This could be done through guided steps in EKS AWS service_

Check AWS CLI configured correctly:
````
aws sts get-caller-identity
```` 
Create cluster command by eksctl: 
````
eksctl create cluster --name my-cluster --region us-east-1 --nodegroup-name my-nodes --node-type t3.small --nodes 1 --nodes-min 1 --nodes-max 2
````
Update config:
````
aws eks --region us-east-1 update-kubeconfig --name my-cluster
````
2. Configure database

Build 
pvc.yaml, 
pv.yaml,
postgresql-deployment.yaml,
postgresql-service.yaml
config file 

and then build these files

```
kubectl apply -f pvc.yaml
kubectl apply -f pv.yaml
kubectl apply -f postgresql-deployment.yaml
kubectl apply -f postgresql-service.yaml
```

For local connection, connect through Port Forwarding:
```
kubectl port-forward service/postgresql-service 5433:5432 &
```
Insert data to postgres database:
````
PGPASSWORD="$DB_PASSWORD" psql --host 127.0.0.1 -U coworking -d coworking -p 5433 < 1_create_tables.sql
PGPASSWORD="$DB_PASSWORD" psql --host 127.0.0.1 -U coworking -d coworking -p 5433 < 2_seed_users.sql
PGPASSWORD="$DB_PASSWORD" psql --host 127.0.0.1 -U coworking -d coworking -p 5433 < 3_seed_tokens.sql
````
3. Build Application Locally:

Install Dependencies
````
pip install -r requirements.txt
````
Set environment variables for app.py
````
export DB_USERNAME=myuser
export DB_PASSWORD=${POSTGRES_PASSWORD}
export DB_HOST=127.0.0.1
export DB_PORT=5433
export DB_NAME=mydatabase
````
Set up port forwarding before run this
````
python app.py
````
Verify Application with <BASE_URL> is 127.0.0.1:5153
````
curl <BASE_URL>/api/reports/daily_usage
curl <BASE_URL>/api/reports/user_visits
````

4.Deloy Application:

Local: 
Buid docker image
````
docker build -t test-coworking-analytics .
````
Run docker image
````
docker run --network="host" test-coworking-analytics
````

CodeBuild:
Setup through buildspec.yaml with github repo include pre-build, build, post-build

And then verify in ECR to check docker image created from CodeBuild

For sensitive info it is needed to store in Secret file and referenced environment variables in ConfigMap 

Create a config yaml file to deploy docker image from ECR to Kubernetes network: coworking.yaml

And then verify with
```
kubectl get svc
```

And use CURL to check: Replace <BASE_URL> with External-IP from above command
````
curl <BASE_URL>/api/reports/daily_usage
curl <BASE_URL>/api/reports/user_visits
````

5. CloudWatch:

Setup CloudWatch to store logs for containers logs.
Get IAM from cluster and add policy to setup addon for log groups
```
aws iam attach-role-policy \
--role-name my-worker-node-role \
--policy-arn arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy

//Add-on
ws eks create-addon --addon-name amazon-cloudwatch-observability --cluster-name my-cluster-name
```

Access Log groups in Cloud Watch to see log stream show the heath of application


## Project Instructions
1. Set up a Postgres database with a Helm Chart
2. Create a `Dockerfile` for the Python application. Use a base image that is Python-based.
3. Write a simple build pipeline with AWS CodeBuild to build and push a Docker image into AWS ECR
4. Create a service and deployment using Kubernetes configuration files to deploy the application
5. Check AWS CloudWatch for application logs

