# AI Agent

AI-Powered Real-Time Application | Next.js + FastAPI + PostgreSQL + AWS

## Overview

AI Agent is a full-stack real-time application built using Next.js, FastAPI, and PostgreSQL.

The application is containerized using Docker and deployed on AWS using ECS Fargate. Terraform is used to manage the AWS infrastructure, and GitHub Actions is used for CI/CD.

### Key Features

* **Authentication**: User login and access management
* **AI Features**: AI-powered application workflows
* **Real-Time Messaging**: Real-time communication
* **Client Management**: Manage clients and customer information
* **Employee Management**: Manage employees and users
* **Document Management**: File upload and OCR
* **Dashboard**: Application statistics and monitoring
* **Notifications**: Application notifications
* **PostgreSQL Database**: Application data storage

## Tech Stack

* **Frontend**: Next.js, React, TypeScript, Tailwind CSS
* **Backend**: FastAPI, Python, SQLModel
* **Database**: PostgreSQL
* **AI**: OpenAI, Google Gemini
* **Containerization**: Docker
* **Cloud**: AWS ECS Fargate, ECR, RDS
* **Load Balancer**: Application Load Balancer
* **Infrastructure**: Terraform
* **CI/CD**: GitHub Actions
* **Logs**: CloudWatch

## AWS Architecture

```text
                    Internet
                       |
                       v
              Application Load Balancer
                       |
              +--------+--------+
              |                 |
              v                 v
        Frontend ECS       Backend ECS
        Port 3000          Port 8000
              |                 |
              |                 v
              |            RDS PostgreSQL
              |
              +--- /api/* ---> Backend
```

The frontend and backend run as separate ECS Fargate services.

The Application Load Balancer provides a single entry point for the application.

## Deployment

Infrastructure is managed using Terraform.

```bash
cd terraform

terraform init
terraform validate
terraform plan
terraform apply
```

Application deployment is automated using GitHub Actions.

```text
Git Push
   |
   v
GitHub Actions
   |
   +---- Build Frontend
   |
   +---- Build Backend
   |
   v
Amazon ECR
   |
   v
Amazon ECS
```

## Frontend API Configuration

The frontend API configuration is maintained in:

```text
frontend/src/config.ts
```

Production API requests use:

```text
/api
```

Local development uses the local FastAPI backend.

## Local Development

### Backend

```bash
python -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn main:app --reload
```

Backend:

```text
http://localhost:8000
```

### Frontend

```bash
cd frontend
npm install
npm run dev
```

Frontend:

```text
http://localhost:3000
```

## API Documentation

FastAPI provides interactive API documentation through Swagger UI:

```text
http://localhost:8000/docs
```

ReDoc:

```text
http://localhost:8000/redoc
```

## Health Check

Backend health endpoint:

```text
/health
```

The application uses health checks to verify that the backend service is running correctly.

## Project Structure

```text
ai-agent/
│
├── frontend/
│   ├── src/
│   ├── Dockerfile
│   ├── package.json
│   └── ...
│
├── backend/
│   ├── main.py
│   ├── Dockerfile
│   ├── requirements.txt
│   └── ...
│
├── terraform/
│   ├── provider.tf
│   ├── backend.tf
│   ├── variables.tf
│   ├── main.tf
│   └── ...
│
├── .github/
│   └── workflows/
│
└── README.md
```

## Security

Sensitive information such as passwords, API keys, credentials, and secret values should not be committed to the GitHub repository.

## License

This project is proprietary. All rights reserved.
