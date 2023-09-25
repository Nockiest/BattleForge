extends Control

var team:String  
var prev_units = null
var sorted_units:Dictionary = {}

func _ready():
	var index = get_index()
	if index == 0:
		$ColorRect.color = Color("red")
		team = "red"
	elif index == 1:
		$ColorRect.color = Color("blue")
		team = "blue"
	else:
		print("This node is not the first or second child of its parent.")
 

func _process(_delta):
	update_tender()
	
func sort_units(units):
	var sorted_units = {}
	for unit in units:
		var unit_type = get_class_name(unit)#unit.get_class()
		#print(unit_type)
		if sorted_units ==  {}:
			print("1")
		#	sorted_units[unit_type] = 1
		elif unit_type in sorted_units:
			sorted_units[unit_type] += 1
		#	print("2")
		else:
			sorted_units[unit_type] = 1
		#	print("3")
func get_class_name(node):
	var path = node.get_script().get_path()
	var parts = path.split("/")
	return parts[parts.size() - 1].replace(".gd", "")

func update_tender():
#	var units = get_tree().get_nodes_in_group("living_units")
	var same_color_units = get_tree().get_nodes_in_group(str(Color(team)))
	if prev_units == same_color_units:
		prev_units = same_color_units
		return
	prev_units = same_color_units
#	print("called")
	if team == "blue":
		$ColorRect/VScrollBar/VBoxContainer/Money/Label.text = str(Globals.blue_player_money)
	elif team =="red":
		$ColorRect/VScrollBar/VBoxContainer/Money/Label.text = str(Globals.red_player_money)
	else:
		print_debug("something wrong with rendering money ", team)
 
	print(same_color_units, "Smw color unitS")
#	var sorted_units = {}
	if same_color_units:
#		print(same_color_units)
		sort_units(same_color_units)

	var vbox = $ColorRect/VScrollBar/VBoxContainer
	for child in vbox.get_children():
	# If the child's name begins with "UnitCount", delete it
		if not child.name.begins_with("Money"):
			child.queue_free()

# For each count in unit_counts, create a new Label and add it to the VBoxContainer
	print(sorted_units.keys(), sorted_units)
	for key in sorted_units.keys():
		print(key, "key")
		var label = Label.new()
		label.name = "UnitCount" + key
		label.text = key + ": " + str(sorted_units[key])
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.add_child(label)
