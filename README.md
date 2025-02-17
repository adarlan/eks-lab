# EKS Lab

## Create cluster

```
terraform apply -chdir=cluster
```

## Deploy extensions

```
terraform apply -chdir=extensions
```

## Restore TLS secrets

```
./tls-secrets.sh restore
```

## Deploy apps

```
./deploy-apps.sh
```

if you deploy multiple apps in different hosts, each host will have its own certificate

## Backup TLS secrets

need to wait until all tls secrets have the certificate (2 datas, not only 1)
if the secret has a random suffix, it's still not ready

```
# check secrets with random suffix (without certificate)
kubectl get secrets -A --no-headers -o custom-columns="NAMESPACE:.metadata.namespace,NAME:.metadata.name" | grep '\-tls\-.*$'

# check secrets with certificate
kubectl get secrets -A --no-headers -o custom-columns="NAMESPACE:.metadata.namespace,NAME:.metadata.name" | grep '\-tls$'
```

```
./tls-secrets.sh backup
```

## Open app in browser

once the certificate is ready (successfully issued), you can open the app in your browser.

When you hit the app in the browser, the browser will say that "your connection is not private"
"This server could not prove that it is example.com; its security certificate is not trusted by your computer's operating system. This may be caused by a misconfiguration or an attacker intercepting your connection."
But this is because letsencrypt ACME staging...
Staging certificates are not trusted by browsers because they use a test root certificate (Fake LE Root X1).
But they are useful when testing new configurations/setups before requesting real certificates.

just click on Proceed to example.com (unsafe)
