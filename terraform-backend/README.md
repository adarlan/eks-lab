# terraform-backend

Add retention policy and enable versioning for production setups:

```yaml
Resources:
  S3Bucket:
    Properties:
      VersioningConfiguration:
        Status: Enabled
    DeletionPolicy: Retain
```
