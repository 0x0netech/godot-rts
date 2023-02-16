class Unit:
	const Movement = preload("res://source/match/utils/UnitMovementUtils.gd")


const BuildingPlacement = preload("res://source/match/utils/BuildingPlacementUtils.gd")


static func traverse_node_tree_and_replace_materials_matching_albedo(
	starting_node, albedo_to_match, epsilon, material_to_set
):
	if starting_node == null:
		return
	for child in starting_node.find_children("*"):
		if not "mesh" in child:
			continue
		for surface_id in range(child.mesh.get_surface_count()):
			var surface_material = child.mesh.get("surface_{0}/material".format([surface_id]))
			if (
				surface_material != null
				and Utils.Colour.is_equal_approx_with_epsilon(
					surface_material.albedo_color, albedo_to_match, epsilon
				)
			):
				child.set("surface_material_override/{0}".format([surface_id]), material_to_set)
