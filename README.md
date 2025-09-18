# Devops-Project
End-to-end CI/CD on AWS with Terraform — a cloud-native DevOps project to automate, provision, and deploy infrastructure at scale.

## Deployment Flow
    A[Push code to GitHub] --> B[GitHub Actions]

    B --> C[Terraform Apply<br/>Provision/Update EC2 + Infra]
    C --> D[Output EC2 Public IP]

    B --> E[Build & Push Docker Image to AWS ECR]

    E --> F[SSH into EC2<br/>Pull latest Docker image]
    D --> F
    F --> G[Run Container on EC2<br/>Expose app on port 80]

    G --> H[Access App via EC2 Public IP]



That produces a clean flow: push → infra → image → deploy → app running.
