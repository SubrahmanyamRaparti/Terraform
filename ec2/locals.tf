locals {
  common_tags = {
    Name = var.istest == true ? var.deployment_region_name["test"] : var.deployment_region_name["prod"]
  }
}