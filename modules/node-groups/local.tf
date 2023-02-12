locals {
  az_count = length(var.availability_zones)

  placement_group_keys  = distinct(compact([for k, v in var.node_groups : v.placement_group_key if !v.single_group]))
  placement_group_names = flatten([for k in local.placement_group_keys : [for z in var.availability_zones : "${k}${z}"]])

  node_groups_expanded = merge(concat([for k, v in var.node_groups : { for z in var.availability_zones : format("%s%s", k, z) => merge(v, {
    availability_zones = [z]
    az                 = z
    min_capacity       = floor(v.min_capacity / local.az_count)
    max_capacity       = floor(v.max_capacity / local.az_count)
    }) } if !v.single_group],
    [for k, v in var.node_groups : { format("%s0", k) = merge(v, {
      availability_zones = var.availability_zones
      az                 = 0
  }) } if v.single_group])...)

  node_groups = { for k, v in local.node_groups_expanded : k => merge(v, {
    proximity_placement_group_id = v.single_group || v.placement_group_key == null || v.placement_group_key == "" ? null : azurerm_proximity_placement_group.default["${v.placement_group_key}${v.az}"].id
  }) }

  system_node_groups = { for k, v in local.node_groups : k => v if v.system }
  user_node_groups   = { for k, v in local.node_groups : k => v if !v.system }
}
