kubectl apply -f argocd-ingress.yaml
kubectl annotate ingress argocd-ingress -n argocd force-reconcile="%random%" --overwrite

kubectl describe ingress argocd-ingress -n argocd

pause
