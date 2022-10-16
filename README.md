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


### Deploy Docker application


### Test


## Project Status
Project is: _Actively working_.


## Room for Improvement
Include areas you believe need improvement / could be improved. Also add TODOs for future development.

- Pin external module


## Acknowledgements
Give credit here.

- The VPC and EKS cluster creation is based [on this article](https://learn.hashicorp.com/tutorials/terraform/eks) from Hashicorp.
- Dockerfile for Nginx customization is inspired on this [article](https://www.docker.com/blog/how-to-use-the-official-nginx-docker-image/).



## Extras


## Contact
Created by [@thaeimos]


