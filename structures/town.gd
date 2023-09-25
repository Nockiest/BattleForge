extends Area2D
var house_scene:PackedScene = preload("res://structures/house.tscn")  # get the house.tscn
var num_houses:int = 5
@onready var rect_shape =  $CollisionShape2D.shape as RectangleShape2D  # Access the RectangleShape2D
# Called when the node enters the scene tree for the first time.
var occupying_units: Array
var team_alligiance
func _ready():
#	place_house()
	pass
	## make sure that collision shape in house scene is stil on index 0 otherwise it wont work
func place_house():
	for house in range(num_houses):
		var house_instance = house_scene.instantiate() as Area2D
		get_random_house_position(house_instance)
		add_child(house_instance)
		house_instance.connect("house_interferes", get_random_house_position ) 
func get_random_house_position(house):
	var house_collision_shape = house.get_child(0).shape as RectangleShape2D  # Access the house's RectangleShape2D
	var min_x = house_collision_shape.extents.x  
	var max_x = (rect_shape.extents.x - min_x)*2
	var min_y = house_collision_shape.extents.y  
	var max_y = (rect_shape.extents.y - min_y)*2
  
	var random_x = randi_range(min_x, max_x)
	var random_y = randi_range(min_y, max_y)
 
	house.position = Vector2(random_x, random_y)
	

func is_area_occupied(area):
	for child in $Houses.get_children():
		print_debug(child is Area2D ,child != area ,child.intersects_area(area))
		if child is Area2D and child != area and child.intersects_area(area):
			return true
	return false
 
 
func _on_area_entered(area):
	print(area, " ",area is UnitMainCollisionArea)
	if not(area is UnitMainCollisionArea):
		return
	if not (area.get_parent() is BattleUnit):
		return
	print("UNIT ENTERED TOWN ",  area.get_parent())
	occupying_units.append(area.get_parent())
#	occuping_units[parent_color] 
	print(occupying_units)

func _on_area_exited(area):
#	if area.get_parent() is BattleUnit:
#	if occuping_units[area.get_parent().color]:
	if not (area is UnitMainCollisionArea):
		return
	if area.get_parent() not in occupying_units:
		return
	print("UNIT EXITED TOWN ",  area.get_parent(), area,  occupying_units )
	occupying_units.erase(area.get_parent())
		
func check_who_occupied():
	var blue_count = 0
	var red_count = 0
	for unit in occupying_units:
		if unit.color == Color("red"):
			red_count += 1
		elif unit.color == Color("blue"):
			blue_count += 1
		else:
			print("I DONT NOW THIS TEAM", unit.color)
	if blue_count > red_count:
		team_alligiance = "blue"
	elif red_count > blue_count:
		team_alligiance = "red"
	
	print("TEAM ALIGIENCE", team_alligiance)
	var edge = $Edge
	if team_alligiance == "blue":
		edge.color = Color("blue")
	elif team_alligiance == "red":
		edge.color = Color("red")	
