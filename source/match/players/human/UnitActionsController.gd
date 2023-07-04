extends Node

const Structure = preload("res://source/match/units/Structure.gd")


class Actions:
	const Moving = preload("res://source/match/units/actions/Moving.gd")
	const MovingToUnit = preload("res://source/match/units/actions/MovingToUnit.gd")
	const Following = preload("res://source/match/units/actions/Following.gd")
	const CollectingResourcesSequentially = preload(
		"res://source/match/units/actions/CollectingResourcesSequentially.gd"
	)
	const AutoAttacking = preload("res://source/match/units/actions/AutoAttacking.gd")
	const Constructing = preload("res://source/match/units/actions/Constructing.gd")


func _ready():
	MatchSignals.terrain_targeted.connect(_on_terrain_targeted)
	MatchSignals.unit_targeted.connect(_on_unit_targeted)
	MatchSignals.unit_spawned.connect(_on_unit_spawned)


func _try_navigating_selected_units_towards_position(target_point):
	var terrain_units_to_move = get_tree().get_nodes_in_group("selected_units").filter(
		func(unit): return (
			unit.is_in_group("controlled_units")
			and unit.movement_domain == Constants.Match.Navigation.Domain.TERRAIN
			and Actions.Moving.is_applicable(unit)
		)
	)
	var air_units_to_move = get_tree().get_nodes_in_group("selected_units").filter(
		func(unit): return (
			unit.is_in_group("controlled_units")
			and unit.movement_domain == Constants.Match.Navigation.Domain.AIR
			and Actions.Moving.is_applicable(unit)
		)
	)
	var new_unit_targets = Utils.Match.Unit.Movement.crowd_moved_to_new_pivot(
		terrain_units_to_move, target_point
	)
	new_unit_targets += Utils.Match.Unit.Movement.crowd_moved_to_new_pivot(
		air_units_to_move, target_point
	)
	for tuple in new_unit_targets:
		var unit = tuple[0]
		var new_target = tuple[1]
		unit.action = Actions.Moving.new(new_target)


func _try_setting_rally_points(target_point: Vector3):
	var controlled_structures = get_tree().get_nodes_in_group("selected_units").filter(
		func(unit): return (
			unit.is_in_group("controlled_units") and unit.find_child("RallyPoint") != null
		)
	)
	for structure in controlled_structures:
		var rally_point = structure.find_child("RallyPoint")
		if rally_point != null:
			rally_point.global_position = target_point


func _try_ordering_selected_workers_to_construct_structure(potential_structure):
	if not potential_structure is Structure or potential_structure.is_constructed():
		return
	var structure = potential_structure
	var selected_constructors = get_tree().get_nodes_in_group("selected_units").filter(
		func(unit): return (
			unit.is_in_group("controlled_units")
			and Actions.Constructing.is_applicable(unit, structure)
		)
	)
	for unit in selected_constructors:
		unit.action = Actions.Constructing.new(structure)


func _navigate_selected_units_towards_unit(target_unit):
	var units_navigated = 0
	for unit in get_tree().get_nodes_in_group("selected_units"):
		if not unit.is_in_group("controlled_units"):
			continue
		if Actions.CollectingResourcesSequentially.is_applicable(unit, target_unit):
			unit.action = Actions.CollectingResourcesSequentially.new(target_unit)
			units_navigated += 1
		elif Actions.AutoAttacking.is_applicable(unit, target_unit):
			unit.action = Actions.AutoAttacking.new(target_unit)
			units_navigated += 1
		elif Actions.Constructing.is_applicable(unit, target_unit):
			unit.action = Actions.Constructing.new(target_unit)
			units_navigated += 1
		elif (
			(
				target_unit.is_in_group("adversary_units")
				or target_unit.is_in_group("controlled_units")
			)
			and Actions.Following.is_applicable(unit)
		):
			unit.action = Actions.Following.new(target_unit)
			units_navigated += 1
		elif Actions.MovingToUnit.is_applicable(unit):
			unit.action = Actions.MovingToUnit.new(target_unit)
			units_navigated += 1
	return units_navigated > 0


func _on_terrain_targeted(position):
	_try_navigating_selected_units_towards_position(position)
	_try_setting_rally_points(position)


func _on_unit_targeted(unit):
	if _navigate_selected_units_towards_unit(unit):
		var targetability = unit.find_child("Targetability")
		if targetability != null:
			targetability.animate()


func _on_unit_spawned(unit):
	_try_ordering_selected_workers_to_construct_structure(unit)
