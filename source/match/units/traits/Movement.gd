extends NavigationAgent3D

@onready var _unit = get_parent()

@export var speed: float = 4.0

var _interim_speed: float = 0.0


func _physics_process(delta):
	_interim_speed = speed * delta
	var next_path_position: Vector3 = get_next_location()
	var current_agent_position: Vector3 = _unit.global_transform.origin
	var new_velocity: Vector3 = (
		(next_path_position - current_agent_position).normalized() * _interim_speed
	)
	set_velocity(new_velocity)


func _ready():
	velocity_computed.connect(_on_velocity_computed)
	navigation_finished.connect(_on_navigation_finished)
	_align_unit_position_to_navigation()


func move(movement_target: Vector3):
	set_target_location(movement_target)


func _align_unit_position_to_navigation():
	await get_tree().process_frame  # wait for navigation to be operational
	# TODO: use new API once available
	_unit.global_transform.origin = NavigationServer3D.map_get_closest_point(
		get_navigation_map(), get_parent().global_transform.origin
	)


func _on_velocity_computed(safe_velocity: Vector3):
	_unit.global_transform.origin = _unit.global_transform.origin.move_toward(
		_unit.global_transform.origin + safe_velocity, _interim_speed
	)


func _on_navigation_finished():
	set_target_location(Vector3(INF, INF, INF))
