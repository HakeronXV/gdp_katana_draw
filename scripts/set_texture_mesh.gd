class_name TextureToMaterial
extends Node

@export var material: StandardMaterial3D
func set_with_texture(texture:Texture2D):
	material.albedo_texture =texture
	
