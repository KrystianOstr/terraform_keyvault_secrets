locals {
  prefix  = "${lower(var.environment)}-${lower(random_id.prefix.hex)}"
  kv_name = "${local.prefix}-kv"

  tags = {
    "environment" = var.environment
    "owner"       = var.owner
  }
}