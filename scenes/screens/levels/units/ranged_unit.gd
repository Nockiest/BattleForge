extends BattleUnit
class_name RangedUnit
 
var start_ammo = 6
var bullet_scene:PackedScene = preload("res://scenes/screens/levels/projectiles/bullet.tscn")
var ranged_unit_range = 300
func _ready():
	attack_component = $RangedAttackComp
	super._ready()
#	attack_range = 300 
#	$RangedAttackComp.attack_range = attack_range  
	unit_name = "ranged_unit"
	attack_component.max_ammo = start_ammo 
	attack_component.ammo = start_ammo 
	attack_component.attack_range = ranged_unit_range
	attack_component.position = to_local(center)
#func try_attack():
#	if super.try_attack() == "success":
#		$RangedAttackComp.try_attack( )
#		toggle_attack_screen()
#func toggle_attack_screen(): 
#	var ranged_attack_component = $RangedAttackComp
#	if ranged_attack_component.ammo <= 0:
#		return
#	super.toggle_attack_screen() 
 
func update_stats_bar():
	super.update_stats_bar()
	$UnitStatsBar/VBoxContainer/Ammo.text = "Ammo "+str(attack_component.ammo)

func _on_ranged_attack_comp_ammo_changed(_ammo):
	update_stats_bar()
