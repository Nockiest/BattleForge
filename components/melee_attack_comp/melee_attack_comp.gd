class_name MeleeAttackComp
extends DefaultAttackComponent
signal attack_failed
signal attack_suceeded

func _ready():
	super._ready()
	$SlashAnimation.hide()
	
func attack(    ):
	super.attack(   )
	if not Globals.hovered_unit or Globals.hovered_unit.color == get_parent().color:
		attack_failed.emit()
		return "failed"	
#	print( self.get_parent().global_position.distance_to(Globals.hovered_unit.global_position), attack_range)
	var distance = self.get_parent().global_position.distance_to(Globals.hovered_unit.global_position) 
	if distance > attack_range:
		attack_failed.emit()
		return "failed"
	Globals.hovered_unit.get_node("HealthComponent").hit(1) 
	var collision_shape = Globals.hovered_unit.get_node("CollisionArea/CollisionShape2D")  # Replace with your actual node path
	var shape_size = collision_shape.shape.extents * 2  # For RectangleShape2D and CapsuleShape2D
	var pos = Globals.hovered_unit.global_position + shape_size / 2
	Utils.play_animation_at_position($SlashAnimation,"slash",pos) 
#	play_attack_animation(attacked_entity)
	return "success"
	
# toggle_attack_screen()
#func play_attack_animation(attacked_entity):
#	$SlashAnimation.z_index = 1000
#	#	slash_animation.position = Globals.hovered_unit.position #.ZERO  # Center of the unit
#	var collision_shape = attacked_entity.get_node("CollisionArea/CollisionShape2D")  # Replace with your actual node path
#	var shape_size = collision_shape.shape.extents * 2  # For RectangleShape2D and CapsuleShape2D
#	$SlashAnimation.global_position = Globals.hovered_unit.global_position + shape_size / 2
#	# Calculate the angle to face Globals.hovered_unit
#	if Globals.hovered_unit:
#		var dir_to_hovered = (Globals.hovered_unit.position - position).normalized()
#		var angle_to_hovered = dir_to_hovered.angle()
#		$SlashAnimation.rotation = angle_to_hovered
#
#	$SlashAnimation.play("slash")
