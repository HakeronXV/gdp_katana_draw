class_name FailedAndVictory
extends Node
signal victory_found()
signal fail_found()

@export var victory_percent01 : float
@export var failed_percent01 : float
@export var victory_percent01_threshold : float = 0.80
@export var failed_percent01_threshold : float = 0.04
@export var victory_found_value : bool
@export var fail_found_value : bool

func set_victory_percent_value(percentage01 : float):
	victory_percent01 = percentage01
	if percentage01 >=  victory_percent01_threshold:
		if victory_found_value == false:
			victory_found_value = true
			victory_found.emit()
func set_failed_percent_value(percentage01 : float):
	failed_percent01 = percentage01
	if percentage01 >=  failed_percent01_threshold:
		if fail_found_value == false:
			fail_found_value = true
			fail_found.emit()
		
func reset_checkers():
	victory_found_value = false
	fail_found_value = false
	
func _ready() -> void:
	reset_checkers()
