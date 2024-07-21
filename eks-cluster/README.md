# __PLATFORM_NAME__-eks-cluster

## TODO

Join node-group and node-group-role into a new module: node-groups
This new module should have a variable of type 'map' to define the node groups.
But the role is not necessarily the same for every node-group...

Does vpc-cni-plugin need a role?
https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html

Add pod-identity-agent?
https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html

### ebs-csi-driver error

```
╷
│ Error: Invalid for_each argument
│ 
│   on modules/ebs-csi-driver/aws-iam-role-policy-attachment.tf line 13, in data "aws_eks_node_group" "node_group":
│   13:   for_each = data.aws_eks_node_groups.node_groups.names
│     ├────────────────
│     │ data.aws_eks_node_groups.node_groups.names is a set of string, known only after apply
│ 
│ The "for_each" set includes values derived from resource attributes that
│ cannot be determined until apply, and so Terraform cannot determine the
│ full set of keys that will identify the instances of this resource.
│ 
│ When working with unknown values in for_each, it's better to use a map
│ value where the keys are defined statically in your configuration and where
│ only the values contain apply-time results.
│ 
│ Alternatively, you could use the -target planning option to first apply
│ only the resources that the for_each value depends on, and then apply a
│ second time to fully converge.
```
