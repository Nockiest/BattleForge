extends Node2D
class_name DefaultAttackComponent
var remain_attacks:int = 1
var units_in_attack_range:Array= []
var attack_range:int = 100
func attack( ):
	pass

func _ready():
	$AttackRangeArea/AttackRangeShape.shape = CircleShape2D.new()
	$AttackRangeArea/AttackRangeShape.shape.radius = attack_range # * attack_range_modifiers["base_modifier"]
	$AttackRangeArea/AttackRangeShape.hide()


func _on_attack_range_area_area_entered(area):
	if area.get_parent() == self:
		return
#	if Globals.action_taking_unit != self:
#		return
	if area.name == "CollisionArea" and area.get_parent() is BattleUnit and not units_in_attack_range.has(area):
		units_in_attack_range.append(area.get_parent())

func _on_attack_range_area_area_exited(area):
	if area.get_parent() == self:
		return
	if Globals.action_taking_unit!= self:
		return
	if area.name == "CollisionArea" and units_in_attack_range.has(area.get_parent()):
		units_in_attack_range.erase(area.get_parent()) 
