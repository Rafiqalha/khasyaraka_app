#!/bin/bash
set -e
KEY="/home/rafiqalha/projects/key/rafiq-aws-key.pem"
IP="13.212.174.32"
SSH_CMD="ssh -o StrictHostKeyChecking=no -i $KEY ubuntu@$IP"

echo "Building Linux backend binary locally..."
cd /home/rafiqalha/projects/khasyaraka/backend
CGO_ENABLED=0 GOOS=linux go build -o server ./cmd/server
cd /home/rafiqalha/projects/khasyaraka

echo "Installing Docker on AWS..."
$SSH_CMD "sudo apt-get update && sudo apt-get install -y docker.io && sudo systemctl start docker && sudo usermod -aG docker ubuntu"

echo "Copying backend files to AWS..."
rsync -avz -e "ssh -o StrictHostKeyChecking=no -i $KEY" --exclude='.git' /home/rafiqalha/projects/khasyaraka/backend/ ubuntu@$IP:~/app/

echo "Building and running Docker containers on AWS using docker-compose..."
$SSH_CMD "sudo apt-get install -y docker-compose-v2 docker-compose && cd ~/app && sudo docker rm -f pradigi-server pradigi-db pradigi-redis || true && sudo docker-compose down || true && sudo docker volume rm app_pgdata || true && sudo docker-compose up -d --build"

echo "Deployment complete!"
