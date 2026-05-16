set VER=1.1.2
docker build -t flask-lab:%VER% .

REM aws ecr create-repository --repository-name flask-lab --region us-west-2
REM              ECR Login
REM aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 316336724953.dkr.ecr.us-west-2.amazonaws.com
REM docker tag flask-lab:latest 316336724953.dkr.ecr.us-west-2.amazonaws.com/flask-lab:latest

docker tag flask-lab:%VER% 316336724953.dkr.ecr.us-west-2.amazonaws.com/flask-lab:%VER%
docker push 316336724953.dkr.ecr.us-west-2.amazonaws.com/flask-lab:%VER%
pause
