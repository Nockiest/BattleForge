extends StaticBody2D
class_name  BattleUnit
signal unit_selected 
signal unit_deselected 
signal interferes_with_area
signal bought(cost)
signal died(this)
const base_movement:int = 1
const base_movement_range:int = 250  
@onready var action_component = %DefaultAttackComp
var death_image_scene:PackedScene = preload("res://scenes/screens/levels/sprite_with_timer.tscn")
 
var remain_movement:int = base_movement:
	set(new_movement):
		remain_movement = new_movement
		update_stats_bar()
 
var attack_resistances =  {"base_resistance":  0.1  }  
@onready var center = $CollisionArea/CollisionShape2D.global_position +$CollisionArea/CollisionShape2D.shape.extents/2 
@onready var size = $CollisionArea/CollisionShape2D.shape.extents * 2
@onready var start_turn_position :Vector2 = get_global_transform().get_origin() # Vector2((position[0]+round(size[0]/2)),(position[1]+round(size[1]/2)))
@onready var buy_areas = get_tree().get_nodes_in_group("buy_areas")

var cost:int = 20
#var movement_polygon = []    
var color: Color # = Color(str(Globals.cur_player))
var original_position = position  # Store the current position
var unit_name: String = "default"
var start_hp: int = 2
var is_newly_bought = true
 
func _ready():
	$UnitStatsBar.hide()
	$HealthComponent.hide()
#	$DeathSprite.hide() 
	$HealthComponent/HealthBar.value = start_hp
	$HealthComponent.hp = start_hp
	update_stats_bar()
	$MovementRangeArea/MovementRangeArea.shape = CircleShape2D.new()
	$MovementRangeArea/MovementRangeArea.shape.radius = base_movement_range
	$MovementRangeArea/MovementRangeArea.hide()
	emit_signal("bought", cost)
#	action_component.connect() update_stats_bar()
	action_component.center = center
	if  is_newly_bought:
		Globals.placed_unit = self
		print("position not set")


func _on_default_attack_comp_remain_attacks_updated(new_attacks):
	update_stats_bar()
	
func get_boost():
	print("THIS UNIT DOESNT HAVE A BOOST FOR KILLING A UNIT")

func _on_area_2d_area_entered(area): 
	emit_signal("interferes_with_area", area)

func move():
	var mouse_pos = get_global_mouse_position()
	var distance_to_mouse = start_turn_position.distance_to(mouse_pos)
	var new_position = position
	if distance_to_mouse > base_movement_range:
		var direction_to_mouse = (mouse_pos - start_turn_position).normalized()
		new_position = start_turn_position + direction_to_mouse * base_movement_range - size / 2
	else:
		new_position = mouse_pos - size / 2

	# Check for collisions with other units.
	var can_move = true
	for unit in get_tree().get_nodes_in_group("living_units"):
		if unit == self:
			continue  # Skip checking collision with itself.
		if unit.get_node("CollisionArea").get_overlapping_areas().has($CollisionArea):
			can_move = false
			break

	# Update the position if no collisions were detected, else revert to original position.
	if can_move:
		position = new_position
		original_position = new_position
		center =  $CollisionArea.to_global($CollisionArea/CollisionShape2D.position + $CollisionArea/CollisionShape2D.shape.extents/2)
		action_component.center = center
		#MovementPosition CollisionShape
		$MovementRangeArea/MovementRangeArea.position = center - Vector2($MovementRangeArea/MovementRangeArea.shape.radius, $MovementRangeArea/MovementRangeArea.shape.radius)

	else:
		abort_movement()
#		position = start_turn_position  # Revert to original position if collision detected
#		toggle_move()
#		remain_movement+= 1
 
 
func _draw():
	var local_start_turn_pos  = to_local(start_turn_position)
	if Globals.moving_unit == self:
		var fill_color = Utils.lighten_color(color, 0.4)
		# Draw an arc from 0 to PI radians (half a circle).
		draw_arc(local_start_turn_pos, base_movement_range, 0,  PI*2, 100, fill_color, 3)
		# Set the collision shape to match the drawn circle. 

func add_to_team(team):
	color = Color(team)
	# Add the unit to a group based on its color
	add_to_group(str(color))
	var color_rect = get_node("ColorRect")
	color_rect.modulate = color

func process_action():
	action_component.try_attack()

func process_input():
	if Color(Globals.cur_player)!=  color :
		return
	elif Globals.moving_unit == self and Input.is_action_just_pressed("right_click"): 
		abort_movement()
	elif Globals.hovered_unit == self : 
		if Input.is_action_just_pressed("left_click"): 
			toggle_move()
		if Input.is_action_just_pressed("right_click"):
			print("TOGGLING SCREEN", self)
			action_component.toggle_action_screen()
	elif  Globals.action_taking_unit == self:
		if Input.is_action_just_pressed("right_click") :
			process_action()
#	elif Globals.moving_unit == self:
#		if Input.is_action_just_pressed("right_click") :
#			toggle_move()
func process_unit_placement():
	if Input.is_action_just_pressed("left_click"): 
#		print(Globals.hovered_unit, "PROCESSING UNIT PLACEMENT")
		## check wheter any unit doesnt overlap with this unit
		if Globals.hovered_unit != self:
			print(Globals.hovered_unit, "POSITION CANNOT BE SET")
		var in_valid_buy_area = false
		## check wheter it is being placed inside the buy bar
		for buy_area in buy_areas:
			if Color(buy_area.team) != color:
				continue  
			if self not in buy_area.units_inside:
				continue
			print("Collision detected with ", buy_area)
			in_valid_buy_area = true
		## check wheter it is placed in and of the occupied cities
		for town in get_tree().get_nodes_in_group("towns"):
			if town.team_alligiance == null:
				continue
			if Color(town.team_alligiance)!= color:
				continue
			if self in town.units_inside:
				print("UNIT IS INSIDE OF AN OCCUPIED CITY")
				in_valid_buy_area = true
		if in_valid_buy_area:
			print(Globals.hovered_unit,"CAN PLACE A UNIT")
			is_newly_bought = false
			Globals.placed_unit = null
			return
		print(Globals.hovered_unit, "POSITION CANNOT BE SET")
 

	if Input.is_action_just_pressed("right_click"): 
		print("ABORTING BUYING AND GIVING MONEY BACK")
		queue_free()

func _process(_delta): 
	queue_redraw()
	if  Globals.placed_unit == self:
		position = get_global_mouse_position() - size / 2
		center = get_global_mouse_position() - size / 2
		start_turn_position = get_global_mouse_position() - size / 2
		process_unit_placement()
		return   
	if Globals.placed_unit != null:
		return
	process_input()
#	if Globals.action_taking_unit == self  :
#		var other_units = get_tree().get_nodes_in_group("living_units")
#		var in_attack_range = action_component.units_in_action_range
#		print("IN ATTACK RANGE", in_attack_range)
#		for unit in other_units:
#
#			if in_attack_range.has(unit):
#				print(unit, in_attack_range)
#				unit.get_node("ColorRect").modulate = Color("white")
#			else:
#				unit.get_node("ColorRect").modulate = Color("white")
			
	if Globals.moving_unit == self:
		move() 

#func highlight_units_in_range(): 
func abort_movement():
	position = start_turn_position
	Globals.moving_unit = null
	
func deselect_movement():
	if Globals.moving_unit == self:
		remain_movement -= 1
		Globals.moving_unit = null 
	set_new_start_turn_point()

func toggle_move():
	if Globals.moving_unit == self:
		deselect_movement()
#		print("CASE 1")
		return
	elif Globals.hovered_unit != self:
#		print("CASE 2")
		return  

	elif Globals.action_taking_unit != self and Globals.action_taking_unit != null:
#		print("CASE 3")
		return
	elif Globals.action_taking_unit != null:
#		print("CASE 4")
		return 
	elif remain_movement <= 0:
		return
#	print("CASE 5")
	Globals.moving_unit = self
	Globals.action_taking_unit = null
 
 
func set_new_start_turn_point():
	center =$CollisionArea/CollisionShape2D.global_position +$CollisionArea/CollisionShape2D.shape.extents/2 
	print("CENTER", center)
	start_turn_position = Vector2(center) 

func update_for_next_turn():
	remain_movement =  base_movement 
#	remain_actions = action_component.base_actions
	if has_node("RangedAttackComp"):
		$RangedAttackComp.ammo += 1
	action_component.update_for_next_turn()	
#	if  has_node("HealthComponent"):
#		$HealthComponent.heal(1)

func _on_health_component_hp_changed(hp, prev_hp):
	update_stats_bar()
	if color and $ColorRect.is_inside_tree():
		var tween = get_tree().create_tween()
		if hp < prev_hp:
			tween.tween_property($ColorRect, "modulate", Color(0,0,0), 0.2)
		else:
			tween.tween_property($ColorRect, "modulate", Color(1,1,1), 0.2)
		
		tween.tween_property($ColorRect, "modulate",   color, 0.2)
	if hp <= 0:
		queue_free()

func _on_collision_area_mouse_entered():
	Globals.hovered_unit = self
	toggle_show_information()
 
func _on_collision_area_mouse_exited():
	Globals.hovered_unit = null
	toggle_show_information()
 
func toggle_show_information():
	$UnitStatsBar.visible = !$UnitStatsBar.visible
	$HealthComponent.visible = !$HealthComponent.visible

func update_stats_bar():
	$UnitStatsBar/VBoxContainer/Health.text = "Health "+str($HealthComponent.hp)
	$UnitStatsBar/VBoxContainer/Actions.text = "Moves "+str(remain_movement)
#	$UnitStatsBar/VBoxContainer/Attacks.text = "Attacks "+str(action_component.remain_actions)

func _on_movement_range_area_area_entered(_area):
	pass
#	if area == self:
#		return
#	if Globals.moving_unit != self:
#		return
#	units_in_action_range.add(area)
#	print("area is inside ", area, self)
#	print("THESE ARE UNITS IN RANGE NOW")

func _on_movement_range_area_area_exited(_area):
	pass
#	if area == self:
#		return
#	if Globals.moving_unit != self:
#		return
#
#	units_in_action_range.remove(area)
#	print("area is outside ", area,self)
#

func _on_tree_exiting():
	# remove_from_group("living_units")
	var other_units = get_tree().get_nodes_in_group("living_units")
	for unit in other_units:
		if unit == Globals.last_attacker:
			print(unit, " will get a boost")

	var death_image = death_image_scene.instantiate() as Sprite2D
	death_image.global_position = center
	get_tree().get_root().add_child(death_image)
 
 
#
#func _on_attack_range_area_area_entered(area):
##	print (area.get_parent()," ",  area.get_parent() == self, " ", Globals.action_taking_unit != self, " ", self)
#	if area.get_parent() == self:
#		return
#	if Globals.action_taking_unit != self:
#		return
#	if area.name == "CollisionArea" and area.get_parent() is BattleUnit and not units_in_action_range.has(area):
#		units_in_action_range.append(area.get_parent())
##	print("THESE ARE UNITS IN RANGE NOW", units_in_action_range)
#func _on_attack_range_area_area_exited(area):
#	if area.get_parent() == self:
#		return
#	if Globals.action_taking_unit!= self:
#		return
#	if area.name == "CollisionArea" and units_in_action_range.has(area.get_parent()):
#		units_in_action_range.erase(area.get_parent()) 

 
#    def try_attack(self, click_pos, attacked_unit):
#        ####!!!RANGED UNITS ARNET CONNECTED O THIS FUNCTION!!!#####
#        if attacked_unit in self.enemies_in_range:
#            self.try_attack()
#            hit_result = attacked_unit.check_if_hit()  # 80% hit chance
#            # num_attacks += 1
#            if hit_result:
#                remaining_hp = attacked_unit.take_damage(self)
#                print("remaining enemy hp", remaining_hp)
#
#                return "UNIT ATTACKS"
#            else:
#                return "UNIT MISSED"
#        return "Attack not possible"

#    def get_attackable_units(self):
#        self.enemies_in_range = []
#        self.lines_to_enemies_in_range = []
#        total_attack_range_modifier = sum(self.attack_range_modifiers.values())
#        # for every living unit
#        for enemy in game_state.living_units.array:
#            if enemy.color == self.color:
#                continue
#            center_x, center_y = self.center
#            enemy_center_x, enemy_center_y = enemy.center
#            distance = math.sqrt((enemy_center_x - center_x)
#                                 ** 2 + (enemy_center_y - center_y)**2)
#            line_points = bresenham_line(
#                center_x, center_y, enemy_center_x, enemy_center_y)
#            if distance - enemy.size//2 < self.attack_range  * total_attack_range_modifier:
#                blocked = self.find_obstacles_in_line_to_enemies(
#                    enemy, line_points)
#
#                if not blocked:
#                    self.enemies_in_range.append(enemy)
#
#        print("in try_attack range are", self.enemies_in_range)
#
 
 
#    def move_in_game_field(self, click_pos):
#
#        new_center_x, new_center_y = click_pos
#        point1 = shapely.geometry.Point(new_center_x, new_center_y)
#        movement_polygon = shapely.geometry.Polygon(
#            self.valid_movement_positions_edges)
#
#        # Check if the clicked position is a valid movement position
#
#        if point1.within(movement_polygon):
#            self.x = new_center_x - self.size // 2
#            self.y = new_center_y - self.size // 2
#
#        else:
#            # Create a line between the click position and starting position
#            movement_line = bresenham_line(
#                new_center_x, new_center_y, self.start_turn_position[0], self.start_turn_position[1])
#
#            # Find the first valid movement position along the line
#            for pos in movement_line:
#                point = shapely.geometry.Point(pos[0], pos[1])
#                if point.within(movement_polygon):
#                    self.x, self.y = pos[0] - \
#                        self.size // 2, pos[1] - self.size // 2
#                    break
#
#        self.rect = pygame.Rect(
#            self.x, self.y, self.size, self.size)
#        self.center = (self.x + self.size//2, self.y + self.size//2)
#        self.apply_modifiers( )
#
#
#
#    def apply_modifiers(self):
#        self.attack_resistances =  {"base_resistance":  1 }  
#        new_pos_color = game_state.pixel_colors[self.center[0]][self.center[1]]
#        if new_pos_color == FORREST_GREEN:
#            self.attack_resistances["IN FORREST" ] = 0.3
#
#
#        for town in game_state.battle_ground.towns:
#            if town.rect.collidepoint(self.center):
#                print("IN TOWN RECT", self)
#                self.attack_resistances["IN TOWN" ] = 0.1
#                break
#
#        for commander in game_state.living_units.dict["Commanders"]:
#            if commander.color == self.color and commander != self:
#                commander.give_deffense_boost(self)
#
#    def get_units_movement_area(self):
#        num_samples = 180
#        center_x, center_y = self.start_turn_position[0], self.start_turn_position[1]
#        self.valid_movement_positions = []
#        self.valid_movement_positions_edges = []
#
#
#        ## create a large circle around the unit
#        def get_circle_points(center_x, center_y, radius, num_samples):
#            points = []
#            for i in range(num_samples):
#                angle = math.radians(i * (360 / num_samples))
#                x = int(center_x + radius * math.cos(angle))
#                y = int(center_y + radius * math.sin(angle))
#                points.append((x, y))
#            return points
#
#        ## take out all of the unique points the circle crosses
#        far_points = get_circle_points(center_x, center_y, self.base_movement_range*2.1, 180)
#        ## for each point get a path from that point to the unit center
#        movement_outline = []
#        for edge in far_points:
#            # Check if edge coordinates are within bounds
#            edge_x = max(0, min(edge[0], WIDTH - 1))
#            edge_y = max(UPPER_BAR_HEIGHT, min(edge[1], HEIGHT - 1))
#
#            line_to_center = bresenham_line(center_x, center_y, edge_x, edge_y)
#            points_in_reach = []
#            cost = 0
#            for point in line_to_center:
#                if cost > self.base_movement_range:
#                    break
#                # get the background movement cost
#                # add it to cost
#                try:
#                    cost += game_state.movement_costs[point[0]][point[1]]
#                except Exception as e:
#                    print(f"An error occurred: {e}", point[0], point[1])
#
#
#
#                ## append it to the points in reach 
#                points_in_reach.append(point)
#
#            farthest_valid_point =  points_in_reach[-1] 
#            other_units = [
#                unit for unit in game_state.living_units.array if unit.color != self.color]
#
#            for unit in other_units:
#                point_x, point_y, interferes = check_precalculated_line_square_interference(unit, points_in_reach)
#                if interferes:
#
#                    if points_in_reach.index((point_x,point_y)) <  points_in_reach.index(farthest_valid_point):
#                        farthest_valid_point = (point_x,point_y)
#
#
#            points_in_reach = points_in_reach[:points_in_reach.index(farthest_valid_point)   ]
#
#
#            if len(points_in_reach) > 0:
#                movement_outline.append(points_in_reach[-1])
#                self.valid_movement_positions.append(points_in_reach)
#                self.valid_movement_positions_edges.append(points_in_reach[-1])
#
#        def check_for_obstacles(point1, point2, i):
#            line = bresenham_line(point1[0], point1[1], point2[0], point2[1])
#            if len(line) <= 2:
#                return
#            line_is_without_obstacles = True
#
#            for point in line:       
#                color = game_state.pixel_colors[point[0]][point[1]]
#
#                if color == RIVER_BLUE:
#                    line_is_without_obstacles = False
#                    break
#
#
#            if not line_is_without_obstacles:
#                mid_point = line[len(line)//2]
#                check_for_obstacles(point1, mid_point, i)
#                check_for_obstacles(mid_point, point2, i+1)
#
#                line_to_center = bresenham_line(center_x, center_y, mid_point[0], mid_point[1])
#                cost = 0
#                farthest_valid_point = (center_x, center_y)
#                for point in line_to_center:
#                    if cost > self.base_movement:
#                        break
#
#                    try:
#                        cost += game_state.movement_costs[point[0]][point[1]]
#                        farthest_valid_point = point
#                    except Exception as e:
#                        print(f"An error occurred: {e}", point[0], point[1])
#
#                self.valid_movement_positions_edges.insert(i , farthest_valid_point)
#
#        for i in range(len(movement_outline)):
#            point1 = movement_outline[i]
#            point2 = movement_outline[(i + 1) % len(movement_outline)]
#
#            check_for_obstacles(point1, point2, i)     
#
#        #         self.valid_movement_positions_edges.insert(i, farthest_valid_point)
#            ## make a calcuation from the units center to this point and find the farthest point on this vertecy
#            ## insert the point into the movement outline
#            ## from the farthest point you found, create a line to point i and i+1
#            ## if the line is without obstacles do nothing
#            ## otherwise take the middle of the new line, and do the same calculation
#            ## repeat until condition is fullfilled
#
#
#    def draw_possible_movement_area(self):
#        farthest_points = []
#        for angle in self.valid_movement_positions:
#            if len(angle) >= 2:
#                farthest_points.append(angle[-1])
#
#        if len(self.valid_movement_positions) > 2:
#
#            farthest_points.append(self.valid_movement_positions[0][-1])
#            # farthest_points.append(angle[-2])
#
#        # Draw the connected path using lines
#        if len(farthest_points) > 1:
#            pygame.draw.lines(screen, self.color, False, farthest_points, 2)
#
#    def find_obstacles_in_line_to_enemies(self, enemy, line_points):
#        # I could only reset the line to that specific unit instead of deleting the whole array
#        ######################### x FIND BLOCKING UNITS ##############
#        blocked = False
#        for unit in game_state.living_units.array:
#            if unit == enemy:
#                continue
#            elif unit.color == self.color:
#                continue
#            point_x, point_y, interferes = check_precalculated_line_square_interference(
#                unit, line_points)
#            distance_between_units = get_two_units_center_distance(unit  , enemy )
#
#            if interferes and abs(distance_between_units )> max(enemy.size//2, unit.size//2):
#                print("this unit is blocking the way", unit, enemy)
#                blocked = True
#                self.lines_to_enemies_in_range.append({
#                    "enemy": enemy,
#                    "start": self.center,
#                    "interference_point": (point_x, point_y),
#                    "end": enemy.center})
#
#                break
#        if not blocked:
#            self.lines_to_enemies_in_range.append({
#                "enemy": enemy,
#                "start": self.center,
#                "interference_point": None,
#                "end": enemy.center})
#
#        return blocked
#
 
 
#    def try_attack(self):
#        self.remain_actions -= 1
#        if self.ammo != None:
#            self.ammo -= 1
#
#    def try_attack(self, click_pos, attacked_unit):
#        ####!!!RANGED UNITS ARNET CONNECTED O THIS FUNCTION!!!#####
#        if attacked_unit in self.enemies_in_range:
#            self.try_attack()
#            hit_result = attacked_unit.check_if_hit()  # 80% hit chance
#            # num_attacks += 1
#            if hit_result:
#                remaining_hp = attacked_unit.take_damage(self)
#                print("remaining enemy hp", remaining_hp)
#
#                return "UNIT ATTACKS"
#            else:
#                return "UNIT MISSED"
#        return "Attack not possible"
#
#    def check_if_hit(self):
#        attack_resistance =   sum(self.attack_resistances.values())
#
#
#        final_hit_probability = 1 - attack_resistance
#
#        # Generate a random float between 0 and 1
#        hit_treshold_value = random.random()
#
#        # Calculate the actual hit chance considering the base_hit_chance and random factor
#
#        print("comparing", final_hit_probability,  hit_treshold_value,
#              final_hit_probability >= hit_treshold_value)
#
#        if final_hit_probability >= hit_treshold_value:
#            print("UNIT WAS HIT")
#            return True  # Unit is hit
#        else:
#            # Unit is not hit
#            print("UNIT WASNT HIT")
#            game_state.animations.append(MISSEDAnimation(
#                x=self.x - self.size//2, y=self.y - self.size//2, resize=(self.size * 2, self.size*2)))
#
#            return False
#
#    def take_damage(self, attacker):
#
#        self.hp -= 1
#        if self.hp <= 0:
#            game_state.living_units.array.remove(self)
#            # players[cur_player].remove_from_game(self)
#            attacker.get_boost_for_destroying_unit()
#            game_state.killed_units += 1
#            update_players_unit()
#            print("Removing unit:", self)
#            print("Units in living_units:", game_state.living_units.array)
#
#            return self.hp
#            del self
#
#        return self.hp
#
#
#    def reset_for_next_turn(self):
#
#        self.start_turn_position = (
#            self.x + self.size//2, self.y + self.size//2)
#        self.remain_actions = self.base_actions
#        self.get_units_movement_area()
#        self.apply_modifiers()
#
#    def draw_lines_to_enemies_in_range(self):
#        for line in self.lines_to_enemies_in_range:
#            start = line["start"]
#            end = line["end"]
#            interference_point = line["interference_point"]
#
#            if interference_point is not None:
#                pygame.draw.line(screen, DARK_RED, start,
#                                 interference_point, 3)
#                pygame.draw.line(screen, (HOUSE_PURPLE),
#                                 interference_point, end, 3)
#            else:
#                pygame.draw.line(screen, DARK_RED, start, end, 3)
#                midpoint = ((start[0] + end[0]) // 2,
#                            (start[1] + end[1]) // 2)
#                distance = math.sqrt(
#                    (start[0] - end[0]) ** 2 + (start[1] - end[1]) ** 2)
#                font = pygame.font.Font(None, 20)
#                text_surface = font.render(
#                    f"{int(distance)} meters", True, WHITE)
#                text_rect = text_surface.get_rect(center=midpoint)
#                screen.blit(text_surface, text_rect)
#
#    def highlight_attackable_units(self):
#        for unit in self.enemies_in_range:
#            # Calculate the center coordinates of self and the target unit
#            self_center = self.center
#            target_center = unit.center
#            # Draw a line from self's center to the target unit's center
#            unit.draw_as_active()
#
#    def render_hovered_state(self):
#        padding = 2  # Adjust the padding size as needed
#        font = pygame.font.Font(None, 20)
#        text_color = (255, 255, 255)  # White color
#
#        # Determine the width of the rectangle based on the longest text line
#        text_lines = [
#            f"Attacks: {self.remain_actions}",
#            f"Ammo: {self.ammo}",
#            f"Hp: {self.hp}"
#        ]
#        max_line_width = max(font.size(line)[0] for line in text_lines)
#        rect_width = max_line_width + 2 * padding
#
#        # Create a transparent background for the text with the adjusted width
#        text_surface = pygame.Surface((rect_width, 80), pygame.SRCALPHA)
#        pygame.draw.rect(text_surface, (0, 0, 0, 100), (0, 0,
#                         text_surface.get_width(), text_surface.get_height()))
#
#        # Render remaining attacks, ammo, and HP in the formatted rectangle
#        for i, line in enumerate(text_lines):
#            text_rendered = font.render(line, True, text_color)
#            text_surface.blit(text_rendered, (padding, i * 20 + padding))
#
#        # Position the rectangle below the unit
#        text_pos = (self.x, self.y + self.size + padding)
#
#        # Blit the formatted rectangle onto the screen
#        screen.blit(text_surface, text_pos)
#
#    def render(self):
#        padding = 2  # Adjust the padding size as needed
#
#        warrior_img = pygame.image.load(f"img/{self.icon}")
#        # Scale down the image to fit within the allocated space with padding
#        max_image_size = self.size - padding * 2
#        warrior_img = pygame.transform.scale(
#            warrior_img, (max_image_size, max_image_size))
#
#        warrior_img_rect = warrior_img.get_rect()
#        # Center the image within the allocated space with padding
#        warrior_img_rect.center = (
#            self.x + self.size // 2, self.y + self.size // 2)
#
#        # Determine the outline color based on the unit's team color
#        outline_color = BLACK  # self.outline_color  # Use the unit's color for the outline
#
#        # Draw the filled rectangle for the unit
#        pygame.draw.rect(screen, self.color, self.rect)
#        pygame.draw.rect(screen, outline_color, self.rect, 1)  # Outline
#
#        # Draw the unit image
#        screen.blit(warrior_img, warrior_img_rect)
#
#    def get_boost_for_destroying_unit(self):
#        print("unit killed an enemy, and could get a boost now")
#
#    def draw_as_active(self):
#        # Try to execute the following block of code
#        try:
#            # Check if the attack_range_modifiers attribute contains "in_observers_range"
#
#            if "in_observer_range" in self.attack_range_modifiers   :
#                if self.attack_range_modifiers[ "in_observer_range"] > 0:
#                    outline_rect = pygame.Rect(
#                    self.x+self.size//2, self.y-10  , 20 , 20)
#                    pygame.draw.rect(screen,  GRAY, outline_rect, 0)
#
#                    render_image("img/observer.png", (15, 15), (self.x+self.size//2, self.y-10 ), screen)
#
#            # Create a rectangle outline around the unit
#            outline_rect = pygame.Rect(
#                int(self.x) - 2, int(self.y) - 2, self.size + 4, self.size + 4)
#            # Draw the rectangle outline on the screen in black color with a width of 2 pixels
#            pygame.draw.rect(screen, BLACK, outline_rect, 2)
#
#            # Calculate the center coordinates of the unit
#
#            center_x = self.center[0]
#            center_y = self.center[1]
#            # Draw a line from the start_turn_position attribute to the center of the unit in red color with a width of 2 pixels
#            pygame.draw.line(screen, self.color, self.start_turn_position,
#                            (center_x, center_y), 2)
#        # If an exception occurs
#        except Exception as e:
#            # Print an error message with the exception details
#            print("An error occurred in draw as active:", e)



 


 
 




 
 
