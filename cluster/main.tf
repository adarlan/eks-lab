module "vpc_network" {
  source = "./vpc-network"

  eks_cluster_name          = var.cluster_name
  vpc_cidr_block            = var.vpc_cidr_block
  max_selected_zones        = 2
  subnet_cidr_block_newbits = 8
  max_nat_gateway_count     = 1
}

module "control_plane" {
  source     = "./control-plane"
  depends_on = [module.vpc_network]

  cluster_name = var.cluster_name
  vpc_id       = module.vpc_network.vpc_id

  subnet_ids = concat(
    module.vpc_network.public_subnet_ids,
    module.vpc_network.private_subnet_ids,
  )
}

# module "node_group_role" {
#   source    = "./node-group-role"
#   role_name = "${var.cluster_name}-node-group-role"
# }

# module "private_node_group" {
#   source              = "./node-group"
#   depends_on          = [module.control_plane, module.subnets, module.node_group_role]
#   cluster_name        = var.cluster_name
#   node_role           = "private"
#   node_group_name     = "${var.cluster_name}-private-node-group"
#   instance_type       = "t3.medium"
#   instance_count      = 1
#   subnet_ids          = module.subnets.private_subnet_ids
#   node_group_role_arn = module.node_group_role.role_arn
# }

# module "core_dns" {
#   source       = "./core-dns"
#   depends_on   = [module.control_plane, module.private_node_group]
#   cluster_name = var.cluster_name
# }

# module "kube_proxy" {
#   source       = "./kube-proxy"
#   depends_on   = [module.control_plane, module.private_node_group]
#   cluster_name = var.cluster_name
# }

# module "vpc_cni_plugin" {
#   source       = "./vpc-cni-plugin"
#   depends_on   = [module.control_plane, module.private_node_group]
#   cluster_name = var.cluster_name
# }

# # module "ebs_csi_driver" {
# #   source       = "./ebs-csi-driver"
# #   depends_on   = [module.control_plane, module.private_node_group]
# #   cluster_name = var.cluster_name
# # }

# module "access_entries" {
#   source                 = "./access-entries"
#   depends_on             = [module.control_plane]
#   cluster_name           = var.cluster_name
#   cluster_administrators = var.cluster_administrators
# }
