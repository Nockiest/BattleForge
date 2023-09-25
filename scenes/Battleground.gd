extends Node2D

var hovered_element = null
var selected_move_unit = null
var selected_attacking_unit = null
var unit_placement_mode = false
var loaded = false
var teams = ["red", "blue"]
var town: PackedScene = preload("res://structures/town.tscn")
var player_scene: PackedScene = preload("res://player.tscn")
var supply_depo: PackedScene = preload("res://structures/supply_depo.tscn")
#this could cause potential problems in the future
@onready var tenders = get_tree().get_nodes_in_group("player_tenders")
@onready var players = get_tree().get_nodes_in_group("players")

func put_unit_into_teams():
	var units = get_tree().get_nodes_in_group("living_units") 
	for i in range(len(units)):
		var unit = units[i]
		var team = teams[i % len(teams)]
#		unit.remain_movement = unit.base_actions
		print(unit, "UNIT")
		unit.add_to_team(team)

func _ready():
	LoadingScreen.render_loading_screen()
	set_process_input(true)
	put_unit_into_teams()
#	for i in len(teams):
#		var player_instance = player_scene.instantiate() as Node2D
#		player_instance.color =  Color(teams[i])
#		player_instance.text_name = teams[i] 
##		var tender = $canvas/Tenders.get_child(i)
#		$Players.add_child(player_instance)
#		tenders[i].team = teams[i]
	for i in range(1):
		var town_instance = town.instantiate() as Area2D
		town_instance.global_position = Vector2(randf_range(0, get_viewport().size.x), randf_range(0, get_viewport().size.y))
		$Structures.add_child(town_instance)
#		town_instance.connect()
	for i in range(2):
		var supply_depo_instance = supply_depo.instantiate() as Area2D
		supply_depo_instance.global_position = Vector2(randf_range(0, get_viewport().size.x), randf_range(0, get_viewport().size.y))
		$Structures.add_child(supply_depo_instance)
 
func _on_blue_buy_area_buy_unit(cost):
#	for player in players:# get_tree().get_nodes_in_group("players"):  
#		if player.color ==  "blue":
#			player.money-= cost
	print("buying unit", cost)
	print(Globals.cur_player)
 
	
func _on_red_buy_area_buy_unit(cost):
#	for player in players: 
#		if player.color == "red":
#			player.money-= cost
	print("buying unit", cost)
	print(Globals.cur_player)
 
func _input(event):
	if event is InputEventMouseMotion:
		$VBoxContainer/DebugLabel.text = "Global Coors: " + str(event.position)
	$VBoxContainer/HoveredUnit.text = str(Globals.hovered_unit)

func _on_canvas_next_turn_pressed():
	Globals.cur_player_index += 1  
	var Supply_depos =  get_tree().get_nodes_in_group("supply_depos") 
#	print (support_actions)
	for depo in Supply_depos:
		var resupply_action = depo.get_node("AreaResupplyAction")
		resupply_action.provide_buffs()
	Globals.action_taking_unit = null
	Globals.moving_unit = null
	## not currently used
	var units = get_tree().get_nodes_in_group("living_units")
	var support_actions = get_tree().get_nodes_in_group("support_actions")
	var towns = get_tree().get_nodes_in_group("towns")
	for unit in units:
		unit.update_for_next_turn()
	for support_action in support_actions:
#		print (support_action, " supportaction ", support_action.get_parent())
		support_action.provide_buffs()
	for town in towns:
		print("STRUCTURE ", town )
		town.check_who_occupied()

#	var support_actions = get_tree().get_nodes_in_group("support_actions")
 
func update_tender(new_value, color):
	print("UPDATING TENDER TO ", new_value, color) 
	
	
 
#	for unit in get_tree().get_nodes_in_group("living_units"):
##		unit.connect("interferes_with_area", _on_unit_interferes_with_object) 
#		unit.remain_actions = unit.base_actions
#func _on_unit_interferes_with_object(unit):
 
#	print(unit.name + " interfered ")

# DOESNT WORK ANYMORE		
 
#var towns = place_towns()
#func place_towns( ):
#	var towns = []
#	var min_distance = 300
#	var max_attempts = 10
#	var num_towns = 5
#
#	for town_index in range( num_towns):
#		for try in range(max_attempts):
#			var x = randi(0, self.width - 60)
#			var y = randi(0, self.height - 60)
#			var town_coors = Vector2(x, y)
#
#			if Utils.is_town_far_enough(town_coors, min_distance,  towns):
#				var town_size = Vector2(randi() % 21 + 40, randi() % 21 + 40)
#				var town_topleft = Vector2(x, y)
##				house_rectangles = []
##				num_houses = random.randint(3, 6)
##				new_town = Town(x, y, town_size, TOWN_RED, num_houses)
##
##				new_town.place_houses(self.rivers)
##				towns.append(new_town)
#			else:
#				print( "Failed to place town")
#
#func get_town_distances(all_towns, town_center, town_rect, town_index):
#	var distances = []
#	for i in range(all_towns.size()):
#		if i == town_index:
#			continue
#		var other_town = all_towns[i]
#		var distance = town_center.distance_to(other_town.center)
#		distances.append([distance, i])
#	return distances
#
#


#func check_river_collision(new_house, rivers, screen):
#    for river in rivers:
#
#        for i in range(len(river.points) - 1):
#            segment_start = river.points[i]
#            segment_end = river.points[i + 1]
#
#
#            # Create a rectangle representing the river segment
#            segment_rect = pygame.Rect(segment_start, (segment_end[0] - segment_start[0], segment_end[1] - segment_start[1]))
#
#            if pygame.draw.line(screen, (0, 0, 0, 0), segment_start, segment_end).colliderect(new_house):
#
#                return True  # House collides with river segment
#    return False  # No collision with any river segment
#
#class Town(Structure):
#    def __init__(self, x, y, size, color, num_houses):
#        super().__init__(x, y, size, color)
#        self.num_houses = num_houses
#        self.houses = []
#        self.rect = pygame.Rect(self.x, self.y, self.size[0], self.size[1])
#        self.center = (self.x + self.size[0] // 2, self.y +  self.size[1] // 2)
#        self.occupied_by = None  # value of color
#
#    def place_houses(self, rivers):
#        for _ in range(self.num_houses):
#            placed_house = False
#            for _ in range(50):  # Attempt at most 50 times to place a house
#                house_x = random.randint(self.x, self.x + self.size[0] - square_size)
#                house_y = random.randint(self.y, self.y + self.size[1] - square_size)
#                new_house = House(house_x, house_y, 'img/house.png', square_size) # square size is the default size of a square
#
#                # Check for interference with other town rectangles
#                interferes_with_town = any(house.rect.colliderect(new_house.rect) for house in self.houses)
#
#                if not interferes_with_town:
#                    interferes_with_river = check_river_collision(new_house.rect, rivers, screen)
#                    if not interferes_with_river:
#                        self.houses.append(new_house)
#                        placed_house = True
#                        break
#
#            if not placed_house:
#                break  # If failed to place a house 50 times or if it interferes with rivers, break the loop
#
#    def draw_self(self, screen):
#        pygame.draw.rect(screen, TOWN_RED , self.rect)  # Red rectangle for town center with reduced opacity
#
#        if self.occupied_by is   None:
#
#            pygame.draw.rect(screen, BLACK, self.rect, 1)
#        else:
#             pygame.draw.rect(screen, self.occupied_by , self.rect, 2)
#
#    def draw_houses(self, screen):
#        for house in self.houses:
#            house.draw(screen)
#

 

 


 
 
