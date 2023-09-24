extends HBoxContainer

var unit_types = ["cannon", "pikeman", "shield", "medic", "knight", "musketeer"]
var unit_images = [preload("res://img/cannon.png"), preload("res://img/pikeman.png"), preload("res://img/shield.png"), preload("res://img/medic.png"), preload("res://img/knight.png"), preload("res://img/musketeer.png")]
var unit_scenes = [
 preload("res://scenes/screens/levels/units/canon.tscn"),
 preload("res://scenes/screens/levels/units/pikeman.tscn"),
 preload("res://scenes/screens/levels/units/shield.tscn"),
 preload("res://scenes/screens/levels/units/medic.tscn"),
 preload("res://scenes/screens/levels/units/knight.tscn"),
 preload("res://scenes/screens/levels/units/musketeer.tscn")
]
 
func _ready():
#	var max_width = 64  # Replace with your desired max width
#	var max_height = 64  # Replace with your desired max height
	for i in range(min(get_child_count(), unit_types.size())):
		var button = get_child(i)
		var texture_rect = button.get_node("%TextureRect")  # Replace with your actual node path
		var unit_label = button.get_node("%UnitTypeLabel")
		button.UnitClass = unit_scenes[i]
		texture_rect.texture = unit_images[i]
		texture_rect.set_size(Vector2(32, 32))
		
		unit_label.text = unit_types[i]

#		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
#		button.size_flags_vertical = Control.SIZE_EXPAND_FILL
#		texture_rect.expand = true
#		var aspect_ratio = texture_rect.texture.get_width() / texture_rect.texture.get_height()
#		texture_rect.scale = Vector2(1/ aspect_ratio, 1 / aspect_ratio)
#		if aspect_ratio > 1:
#			# If width is greater than height, set max width and scale height accordingly
#			texture_rect.rect_min_size = Vector2(max_width, max_width / aspect_ratio)
#		else:
#			# If height is greater than width, set max height and scale width accordingly
#			texture_rect.rect_min_size = Vector2(max_height * aspect_ratio, max_height)
 
 
