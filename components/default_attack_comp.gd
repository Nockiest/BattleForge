extends StaticBody2D
class_name DefaultAttackComponent
signal remain_attacks_updated(new_attacks)
var base_attacks:int = 1
var remain_attacks: int = base_attacks:
	set(new_attacks):
		remain_attacks = new_attacks
		emit_signal("remain_attacks_updated", new_attacks)

var units_in_attack_range:Array= []
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
	toggle_attack_screen()
	attack()
	return "SUCESS"

## ranged attack has an overide for this function  
func attack():
	Globals.last_attacker = get_parent()
#	 
#	Globals.hovered_unit.get_node("HealthComponent").hit(1) 
#	remain_attacks -=1

func check_can_attack():
	print("GLOBALS ", Globals.action_taking_unit, get_parent(), Globals.action_taking_unit == get_parent()   )
	if  Globals.action_taking_unit != get_parent():
		print_debug(1, Globals.action_taking_unit)
		toggle_attack_screen()
		return false
	if not Globals.hovered_unit:
		toggle_attack_screen()
		print_debug(2,   Globals.hovered_unit)
		return false
	if Globals.hovered_unit.color == get_parent().color:
		toggle_attack_screen()
		print_debug(3,  Globals.hovered_unit.color , get_parent().color)
		return false
	if remain_attacks <= 0:
		print_debug(4,  remain_attacks)
		return false
	print_debug(5)
	return true

func _ready():
	$AttackRangeShape.shape = CircleShape2D.new()
	$AttackRangeShape.shape.radius = attack_range # * attack_range_modifiers["base_modifier"]
	$AttackRangeShape.hide()

func  update_for_next_turn():
	remain_attacks = base_attacks

func _process(delta):
	if   Globals.action_taking_unit == get_parent():
		$AttackRangeShape.show()
	else:
		$AttackRangeShape.hide()
 
func toggle_attack_screen():
	print( Globals.action_taking_unit == get_parent())
	if Globals.action_taking_unit == get_parent():
		Globals.action_taking_unit = null
		Globals.attacking_component = null
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
	if  remain_attacks > 0:
		Globals.action_taking_unit = get_parent()
		Globals.attacking_component = self
	print("ACTION TAKING UNIT", Globals.action_taking_unit)
	## I will recreate this in the children components
 


func _on_area_entered(area):
#	if area.get_parent() == self:
#		return
#	if Globals.action_taking_unit != self:
#		return
	if area.name == "CollisionArea" and area.get_parent() is BattleUnit and not units_in_attack_range.has(area):
		units_in_attack_range.append(area.get_parent())

 


func _on_area_exited(area):
#	if area.get_parent() == self:
#		return
	if Globals.action_taking_unit!= self:
		return
	if area.name == "CollisionArea" and units_in_attack_range.has(area.get_parent()):
		units_in_attack_range.erase(area.get_parent()) 
		
