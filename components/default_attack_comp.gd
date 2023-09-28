extends Area2D
class_name DefaultAttackComponent
signal remain_actions_updated(new_attacks)
var base_actions:int = 1
var remain_actions: int = base_actions:
	set(new_attacks):
		remain_actions = new_attacks
		emit_signal("remain_actions_updated", new_attacks)

var units_in_action_range:Array= []
var attack_range:int = 100
var attack_range_modifiers = {"base_modifier": 1}
var center


func try_attack( ):
	print("processing", Globals.hovered_unit,Globals.action_taking_unit  )
	if !check_can_attack():
		print("FAILED ",self, self.get_parent(),  check_can_attack() )
		return  "FAILED"
	var distance =  global_position.distance_to(Globals.hovered_unit.global_position) 
	print("CAN ATTACK ", distance)
	if distance > attack_range:
		return "FAILED"
	## I will add this to the try_attack component later too
	toggle_action_screen()
	attack()
	return "SUCESS"

## ranged attack has an overide for this function  
func attack():
	Globals.last_attacker = get_parent()
#	 
#	Globals.hovered_unit.get_node("HealthComponent").hit(1) 
#	remain_actions -=1

func check_can_attack():
	print("GLOBALS ", Globals.action_taking_unit, get_parent(), Globals.action_taking_unit == get_parent()   )
	if  Globals.action_taking_unit != get_parent():
		print_debug(1, Globals.action_taking_unit)
		toggle_action_screen()
		return false
	if not Globals.hovered_unit:
		toggle_action_screen()
		print_debug(2,   Globals.hovered_unit)
		return false
	if Globals.hovered_unit.color == get_parent().color:
		toggle_action_screen()
		print_debug(3,  Globals.hovered_unit.color , get_parent().color)
		return false
	if remain_actions <= 0:
		print_debug(4,  remain_actions)
		return false
	print_debug(5)
	return true

func _ready():
	$AttackRangeShape.shape = CircleShape2D.new()
	$AttackRangeShape.shape.radius = attack_range # * attack_range_modifiers["base_modifier"]
	$AttackRangeShape.hide()

func  update_for_next_turn():
	remain_actions = base_actions

func _process(delta):
	if Globals.action_taking_unit == get_parent():
		$AttackRangeShape.show()
	else:
		$AttackRangeShape.hide()
 
func toggle_action_screen():
	print( Globals.action_taking_unit == get_parent())
	if Globals.action_taking_unit == get_parent():
		Globals.action_taking_unit = null
		Globals.attacking_component = null
		unhighlight_units_in_range()
		print_debug("1 ", self)
		return
	if Globals.hovered_unit != get_parent():
		print ("2 ", self,  Globals.hovered_unit)
		return
	if Globals.action_taking_unit != null:
		print_debug("3 ", self)
		return
	## switch between moving and doing action
	get_parent().deselect_movement()
	if  remain_actions > 0:
		Globals.action_taking_unit = get_parent()
		highlight_units_in_range()
		Globals.attacking_component = self
	print("ACTION TAKING UNIT", Globals.action_taking_unit)
	## I will recreate this in the children components
 
func highlight_units_in_range(): 
	var other_units = get_tree().get_nodes_in_group("living_units")
	print("IN ATTACK RANGE", units_in_action_range)
	for enemy in other_units:
		print(units_in_action_range, units_in_action_range.has(enemy))
		if units_in_action_range.has(enemy):
			print(enemy, units_in_action_range)
			enemy.get_node("ColorRect").modulate = Color("white")
		else:
			enemy.get_node("ColorRect").modulate = enemy.color
func unhighlight_units_in_range():
	for enemy in units_in_action_range:
		enemy.get_node("ColorRect").modulate = enemy.color

func _on_area_entered(area):
	if area.get_parent() == get_parent():
		return
	if area.name == "CollisionArea" and area.get_parent() is BattleUnit and area.get_parent().color != get_parent().color and not units_in_action_range.has(area.get_parent()) :
		units_in_action_range.append(area.get_parent())
	print("IN ATTACK RANGE " , units_in_action_range, self.get_parent())

 


func _on_area_exited(area):
	if area.name == "CollisionArea" and units_in_action_range.has(area.get_parent()):
		units_in_action_range.erase(area.get_parent()) 
	print("IN ATTACK RANGE AFTER EXIT " , units_in_action_range)
		
