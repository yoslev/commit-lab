set VER=1.0.3
docker build -t frontend-lab:%VER% .

REM aws ecr create-repository --repository-name frontend-lab --region us-west-2
REM              ECR Login
REM aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 316336724953.dkr.ecr.us-west-2.amazonaws.com
REM docker tag flask-lab:latest 316336724953.dkr.ecr.us-west-2.amazonaws.com/flask-lab:latest

docker tag frontend-lab:%VER%  316336724953.dkr.ecr.us-west-2.amazonaws.com/frontend-lab:%VER% 

docker push 316336724953.dkr.ecr.us-west-2.amazonaws.com/frontend-lab:%VER%
pause
