extends Node2D
signal remain_movement_changed(new_movement)
const base_movement:int = 1
const base_movement_range:int = 250  
var remain_movement:int = base_movement:
	set(new_movement):
		remain_movement = new_movement
		emit_signal("remain_movement_changed", new_movement)
 

func _ready():
	$MovementRangeArea/MovementRangeArea.shape = CircleShape2D.new()
	$MovementRangeArea/MovementRangeArea.shape.radius = base_movement_range
	$MovementRangeArea/MovementRangeArea.hide()
