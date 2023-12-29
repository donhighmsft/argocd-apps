# Bootstrapping an AKS cluster with Terraform, ArgoCD and Helm Operator

## Deploy AKS with Terrafom

```console
terraform init
cp terraform.tfvarsexample terraform.tfvars
terraform apply -auto-approve -var-file=terraform.tfvars
```

The template will install AKS and call the ArgoCD module to install everything that is in this repo under the `/apps` folder, including `cert-manager` and `ingress-nginx`. To allow for the certificates creation, you need to map the ingress public IP to a real wildcard DNS record in a DNS zone (in Azure):

```console
INGRESS_IP=`kubectl get svc -n ingress ingress-nginx-controller --output=jsonpath="{.status.loadBalancer.ingress[0]['ip']}"`
az network dns record-set a delete  -g dns -z donhighthecontainerguy.com -y -n "*.ingress"
az network dns record-set a add-record  -n "*.ingress" -g dns -z donhighthecontainerguy.com --ipv4-address $INGRESS_IP
az network dns record-set a update  -n "*.ingress" -g dns -z donhighthecontainerguy.com --set ttl=10
```

If you already have a cluster, you can install the ArgoCD server with:

```console
kubectl apply -f install.yaml -n argocd --wait=true ; sleep 5
kubectl wait --for condition=Ready -l app.kubernetes.io/name=argocd-server -n argocd pod --timeout=120s
```

(this is the time to patch the `argocd-cm` if you need access to a private repository).

Note that I modify the official template to allow insecure connections (SSL is terminated at the ingress controller) and using the latest image.

- Run:

Create the bootstrap root application (apps-of-apps)

```console
kubectl apply -f apps/root-app.yaml
```

To get the ingress work with the Let's Encrypt certificate, you need to map the ingress IP to a DNS zone. If you have one in Azure, you can use this:

That's it! Argo will install recursively everything that is present in the `/manifests` folder, including cert-manager+ingress, giving Argo itself a TLS-secured endpoint for the its UI. You can retrieve the ArgoCD password (for 1.9+):

```console
kubectl get secret -n argocd  argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -D
```

and use the `argocd` command line:

```console
kubectl port-forward svc/argocd-server 8080:80 --namespace argocd & argocd login localhost:8080  --insecure
```

ToDo

- ingress-nginx [DONE]
- cert-manager [DONE]
- blobfuse-csi-driver [DONE]
- azurefile-csi-driver [DONE]
- azuredisk-csi-driver [DONE]
- secrets-store-csi-driver-provider-azure [DONE]
- falco [DONE]
- sealed-secrets [DONE]
- kyverno [DONE]
- shpod [DONE]
- capsule [DONE]
- Prom operator
- Loki

## Notes

### Ingress

```console
INGRESS_IP=`kubectl get svc -n ingress ingress-ingress-nginx-controller --output=jsonpath="{.status.loadBalancer.ingress[0]['ip']}"`
ZONE=domain.com
DNS_RG=dns

az network dns record-set a delete  -g dns -z $ZONE -y -n "*.ingress"
az network dns record-set a add-record  -n "*.ingress" -g $DNS_RG -z $ZONE --ipv4-address $INGRESS_IP
az network dns record-set a update  -n "*.ingress" -g $DNS_RG -z $ZONE --set ttl=10
```

### Insecure ArgoCD

The ArgoCD `install.yaml` differs from the official one, in that installs the `latest` version and enables ``--insecure` connections (as the
connections is TLS-terminated at the ingress controller).

### Vault

The Vault root token can be retrieved by:

```console
kubectl get secrets -n vault vault-unseal-keys -o jsonpath={.data.vault-root} | base64 --decode|pbcopy
```

### Use private git repository

Create a secret with your Github token (`repo` scope) and patch the `argocd-cm` ConfigMap:

```console
kubectl create secret generic -n argocd argocd-github-secret --from-literal=token=<token> --from-literal=username=<github_username>
kubectl patch cm -n argocd argocd-cm --patch-file patch-private-repos.yaml
```

## Tips

If an app get stuck and cannot be deleted, try:

```console
argocd app terminate-op cert-manager-crd
```
