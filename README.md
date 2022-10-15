# aws-eks-image
Terraform AWS demo using EKS


## Table of Contents

* [General Info](#general-information)
* [Technologies Used](#technologies-used)
* [Features](#features)
* [Screenshots](#architectural-diagram)
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

- Terraform - version 1.1.7
- Git       - version 2.37.2
- Docker    - version 20.10.18


## Features

List the ready features here:

- Automatic environments creation using external module.
- VPC and EKS creation using external pinned module.
- [Dynamic creation](/infra-as-code/main.tf) of subnets CIDR based on Availability Zones for that Region.
- Docker custom message creation.
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
docker build . -t nginx-custom
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

