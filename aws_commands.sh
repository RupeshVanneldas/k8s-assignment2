#These commands are only for local development and testing purposes.

# Set up AWS CLI and Docker to push Docker images to ECR
vi ~/.aws/credentials # Add your AWS credentials
vi ~/.aws/config # Add your AWS region

# Test AWS CLI
aws sts get-caller-identity

# Authenticate Docker to ECR
aws ecr get-login-password --region <AWS_REGION> | docker login --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com

# Tag your Docker images
docker tag my_app:latest <AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com/<ECR_REPO_NAME>:my_app_v1
docker tag my_app:latest <AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com/<ECR_REPO_NAME>:my_app_v2
docker tag my_db:latest <AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com/<ECR_REPO_NAME>:my_db_v1

# Push your Docker images
docker push <AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com/<ECR_REPO_NAME>:my_app_v1
docker push <AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com/<ECR_REPO_NAME>:my_app_v2
docker push <AWS_ACCOUNT_ID>.dkr.ecr.<AWS_REGION>.amazonaws.com/<ECR_REPO_NAME>:my_db_v1
