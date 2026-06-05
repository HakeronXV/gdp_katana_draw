class_name KatanaRaycastToPoint
extends Node3D

@export var raycast_line : Array[RayCast3D] = []
@export var debug_point:Node3D
@export var debug_point_vector3:Vector3 
@export var is_touching : bool

signal katana_is_touching(is_touching : bool)
signal katana_collision_point(global_point : Vector3)

func get_collision_point() -> Vector3:
	if is_touching:
		return debug_point_vector3
	return Vector3.ZERO

func is_collision_touching() -> bool:
	return is_touching

func raycast_check() -> void:
	for r in raycast_line:
		if r.is_colliding():
			var collider = r.get_collider()
			var touch := r.get_collision_point()
			debug_point_vector3 = touch
			if debug_point:
				debug_point.global_position = touch
				katana_collision_point.emit(touch)
				katana_is_touching.emit(true)
				is_touching = true
			return 
	katana_collision_point.emit(Vector3.ZERO)
	katana_is_touching.emit(false)
	is_touching = false
	

func _physics_process(delta):
	raycast_check()
