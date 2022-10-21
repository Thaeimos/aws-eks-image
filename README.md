# aws-eks-image
Terraform AWS demo using EKS


## Table of Contents

* [General Info](#general-information)
* [Technologies Used](#technologies-used)
* [Features](#features)
* [Architecture](#architectural-diagram)
* [Requirements](#requirements)
* [Installation](#installation)
* [Usage](#usage)
* [Project Status](#project-status)
* [Room for Improvement](#room-for-improvement)
* [Acknowledgements](#acknowledgements)
* [Extras](#extras)
* [Contact](#contact)


## General Information

This is for my own practice and trainning.

The idea is to create a docker image that will get deployed on EKS, after passing all the CI/CD phases.


## Technologies Used

- Terraform         - version 1.1.7
- Git               - version 2.37.2
- Docker            - version 20.10.18
- Docker-compose    - version 1.29.2


## Features

List the ready features here:

- Automatic environments creation using external module.
- VPC and EKS creation using external pinned module.
- [Dynamic creation](/infra-as-code/main.tf) of subnets CIDR based on Availability Zones for that Region.
- Docker:
    - Dockerfile with pinned Nginx image that displays custom message.
    - Runs with normal docker commands, as explained in the [run locally](#run-locally-the-docker-application) section.
    - Prints logs to the console.
    - Passes [security scans and linters](https://github.com/Thaeimos/aws-eks-image/actions/runs/3260212935/jobs/5353610420).
- Kubernetes:
    - Manifests to create a Namespace, Statefulset and Service.
        - Custom Namespace.
        - Persistent Volume Claim for the folder /var/www/mytest.
        - Resource limits and requests.
        - Added livenessProbe and readinessProbe.
        - Dynamic repo and SHA substitution for better pinned image deployment.
        - LoadBalancer service to have access from the exterior.
- Pipeline based on Github actions:
    - Pull requests validator with linter, security scanner, password detector, placeholder for Sonar and Docker image scanner. You can check the definitions [here](/.github/workflows/pr-verify.yaml).
    - Infrastructure as code [deployment](./.github/workflows/iac-deploy.yaml).
    - Image publishing on private container repository [pipeline](./.github/workflows/app-publish-image.yaml) and deploy based on Kubernetes manifests.
- Documentation.


## Architectural Diagram


## Requirements
N/A


## Installation
N/A


## Usage


### Deploy infrastructure
First we need to deploy the infrastructure. There is one environment created for this project called [testing](/infra-as-code/environments/testing/). We move into that folder and we fill up the necessary information to connect to the remote bucket that will contain our state:
```bash
cat backend.tfvars.example
    bucket              = "sre-challenge-test"
    dynamodb_table      = "test-dqwdw"
    encrypt             = false
    region              = "us-west-2"
    key                 = "sre"
```

The file that we should put our information should be called "backend.tfvars".
Once that's done, we can initialize our environment to connect to the remote state:
```bash
terraform init -backend-config backend.tfvars
```

Moving forward, we should fill up a "terraform.tfvars" file similar to the example provided, so we can add the values needed to our variables in the manifests:
```bash
cat terraform.tfvars.example
    region          = "us-west-1"
    main_cidr_block = "10.0.0.0/8"
    environment     = "prod"
```

And the config should be done, we just need to apply it with:
```bash
terraform apply # -auto-approve # Only for the brave
```

Then we connect to the Kubernetes cluster using the following:
```bash
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name)
```

Test we connected OK to the cluster:
```bash
kubectl get nodes
    NAME                                       STATUS   ROLES    AGE   VERSION
    ip-10-0-1-107.eu-west-1.compute.internal   Ready    <none>   14h   v1.22.12-eks-ba74326
    ip-10-0-1-108.eu-west-1.compute.internal   Ready    <none>   14h   v1.22.12-eks-ba74326
    ip-10-0-2-38.eu-west-1.compute.internal    Ready    <none>   14h   v1.22.12-eks-ba74326
```

### Run locally the Docker application
We need to move into the "nginx-application" folder. Once there, we will need to build the image:

```bash
docker build . -t nginx-custom:latest
```

And then we will need to run it:
```bash
docker run -it --rm -d -p 8081:80 --name web nginx-custom
```

Verify it works properly:

```bash
curl localhost:8081
    <!doctype html>
    ...
    <h2>Hello World Yougov!</h2>
    </body>
    </html> 
docker logs web 
    /docker-entrypoint.sh: /docker-entrypoint.d/ is not empty, will attempt to perform configuration
    ...
    2022/10/15 07:29:09 [notice] 1#1: start worker process 38
    172.17.0.1 - - [15/Oct/2022:07:30:06 +0000] "GET / HTTP/1.1" 200 156 "-" "curl/7.82.0" "-"
```

Check if it passes a security scanner, Anchore in this case:

```bash
# Deprecated, need to use Grype
curl -s https://ci-tools.anchore.io/inline_scan-latest | bash -s -- -r nginx-custom:latest

# Grype NOK - nginx:1.23.1 
docker run --rm --volume /var/run/docker.sock:/var/run/docker.sock --name Grype anchore/grype:latest nginx-custom:latest
    NAME              INSTALLED                FIXED-IN     TYPE  VULNERABILITY     SEVERITY   
    apt               2.2.4                                 deb   CVE-2011-3374     Negligible  
    bsdutils          1:2.36.1-8+deb11u1                    deb   CVE-2022-0563     Negligible  
    coreutils         8.32-4+b1                             deb   CVE-2017-18018    Negligible  
    coreutils         8.32-4+b1                (won't fix)  deb   CVE-2016-2781     Low         
    curl              7.74.0-1.3+deb11u3                    deb   CVE-2021-22922    Negligible  
    curl              7.74.0-1.3+deb11u3                    deb   CVE-2021-22923    Negligible  
    e2fsprogs         1.46.2-2                 (won't fix)  deb   CVE-2022-1304     High        
    ...

# Grype OK - nginx:1.23.1-alpine
docker run --rm --volume /var/run/docker.sock:/var/run/docker.sock --name Grype anchore/grype:latest nginx-custom:latest
    No vulnerabilities found

```

### Deploy the application into out EKS cluster
We just need to do a change inside the "nginx-application" folder. Once the commit is pushed, it should automatically deploy into our Kubernetes cluster in AWS.

### Test as Statefulset
We can start by checking if we have any resource in the namespace we created:
```bash
kubectl -n nginx-app get all 
    NAME              READY   STATUS    RESTARTS   AGE
    pod/nginx-app-0   1/1     Running   0          54m
    ...
    NAME                         READY   AGE
    statefulset.apps/nginx-app   1/1     54m
```

We can see if we get any pods using the label we selected to represent our application:
```bash
kubectl -n nginx-app get pods -l app=nginx-app
    NAME          READY   STATUS    RESTARTS   AGE
    nginx-app-0   1/1     Running   0          145m
```

Check if our headless service is created:
```bash
kubectl -n nginx-app get service nginx-service-stateful 
    NAME                     TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
    nginx-service-stateful   ClusterIP   None         <none>        80/TCP    3m32s
```

Get hostname from the pod itself:
```bash
kubectl -n nginx-app exec nginx-app-0 -- sh -c 'hostname -f'
    nginx-app-0.nginx-app.nginx-app.svc.cluster.local
```

Verify that internally our custom Nginx pod is giving us the correct message. For that we will spin an additional image that can do nslookups and curls onto our pod DNS name:
```bash
kubectl run -n nginx-app -i --tty --image busybox:1.28 dns-test --restart=Never --rm

# Get IP for service
nslookup nginx-service-stateful
    Server:    172.20.0.10
    Address 1: 172.20.0.10 kube-dns.kube-system.svc.cluster.local

    Name:      nginx-service-stateful
    Address 1: 10.0.1.131 10-0-1-131.nginx-service-stateful.nginx-app.svc.cluster.local

```

### Test as Deployment
Let's do an end-to-end test to see if this works:
```bash
curl $(kubectl -n nginx-app get service nginx-service-deploy-lb -o jsonpath='{.status.ancer.ingress[].hostname}')
    <!doctype html>
    <html lang="en">
    <head>
        <meta charset="utf-8">
        <title>Docker Nginx</title>
    </head>
    <body>
        <h2>Hello World Yougov!</h2>
    </body>
    </html>
```


## Project Status
Project is: _Actively working_.


## Room for Improvement
Include areas you believe need improvement / could be improved. Also add TODOs for future development.

- Pin external module.
- Create namespace for app "nginx-app".


## Acknowledgements
Give credit here.

- The VPC and EKS cluster creation is based [on this article](https://learn.hashicorp.com/tutorials/terraform/eks) from Hashicorp.
- Dockerfile for Nginx customization is inspired on this [article](https://www.docker.com/blog/how-to-use-the-official-nginx-docker-image/).
- Liveness and Readiness probes information was taken from [here](https://developers.redhat.com/blog/2020/11/10/you-probably-need-liveness-and-readiness-probes#example_3__a_server_side_rendered_application_with_an_api).
- Used tons of info from the [official documentation](https://kubernetes.io/docs/tutorials/stateful-application/basic-stateful-set/).



## Extras


## Contact
Created by [@thaeimos]

