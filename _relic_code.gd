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

#	Engine.time_scale = 0.5


# The unit's collision shape is overlapping with the ResupplyAction's collision shape
			# Provide buffs here
#	super.provide_buffs()
#	if supported_entity:
#		Utils.play_animation_at_position($AnimatedSprite2D,"resupply_animation", supported_entity.global_position) 
 
#	var shape = RectangleShape2D.new()
#	shape.extents = Vector2(48, 48)
##	$CollisionShape2D.shape = shape

#	var same_color_units = []
#	for unit in units:
#		if unit.color != Color(team):
#			continue
#		same_color_units.append(unit)

# scale = Vector2(test_scale,test_scale )
