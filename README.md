# Avrae Terraform

This code allows you to modify the infrastructure for the Avrae bot, service and database.

## Overview

The following services are needed:
- 3 ECR repositories (service/bot/taine)
- 3 ECS Fargate stacks (service/bot/taine)
- Amazon DocumentDB (MongoDB)
- ElastiCache (Redis)

## Initialize

Run:

`terraform init`

## Plan

Run:

`terraform plan -out plan.out`

## Run

Run:

`terraform apply plan.out`
