helm upgrade frontend-app .\frontend-chart --force

REM *** INGRESS *** helm upgrade frontend-app .\frontend-chart   --set ingress.annotations."alb\.ingress\.kubernetes\.io/certificate-arn"="arn:aws:acm:us-west-2:316336724953:certificate/4b12f103-f06f-4659-8981-c0c325df5710"

REM helm upgrade frontend-app --dry-run --debug .\frontend-chart
kubectl get po
pause
