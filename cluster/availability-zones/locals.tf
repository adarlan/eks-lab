locals {

  eligible_zone_names = [
    for x in var.eligible_zones : format("%s%s", data.aws_region.region.name, x)
  ]

  available_zone_names = data.aws_availability_zones.available_zones.names

  eligible_zones_available = length(local.eligible_zone_names) == 0 ? local.available_zone_names : setintersection(
    local.eligible_zone_names,
    local.available_zone_names
  )

  selected_zones = (
    (var.max_selected_zones > 0) && (length(local.eligible_zones_available) > var.max_selected_zones)
  ) ? slice(local.eligible_zones_available, 0, var.max_selected_zones) : local.eligible_zones_available
}
