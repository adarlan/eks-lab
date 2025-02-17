## Ingress configuration

You can rout traffic to host only (`example.com`)
or to host+path (`example.com/foo/bar`).

To route traffic to a host without path (`example.com`):

```
metadata:
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$1
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /(.*)
```

To route traffic to a host with path (`example.com/foo/bar`):

```
metadata:
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /foo/bar(/|$)(.*)
```

To enable TLS for an ingress, add one of the following annotations to the ingress manifest:

```
metadata:
  annotations:
    cert-manager.io/cluster-issuer: default-cluster-issuer
    cert-manager.io/issuer: {namespaced_issuer_name}
```
