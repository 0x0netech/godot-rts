extends Node3D

@onready var navigation_map_rid = get_world_3d().navigation_map

@onready var _navigation_region = find_child("NavigationRegion3D")


func _ready():
	NavigationServer3D.map_force_update(navigation_map_rid)


func rebake():
	_navigation_region.bake_navigation_mesh(false)
