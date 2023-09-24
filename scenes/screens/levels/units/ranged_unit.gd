extends BattleUnit
class_name RangedUnit
 
var start_ammo = 6
var bullet_scene:PackedScene = preload("res://scenes/screens/levels/projectiles/bullet.tscn")
 
func _ready():
	super._ready()
	attack_range = 300 
	$RangedAttackComp.attack_range = attack_range 
	$RangedAttackComp.max_ammo = start_ammo 
	$RangedAttackComp.ammo = start_ammo 
	unit_name = "ranged_unit"
func attack():
	if super.attack() == "success":
#		print("IS SUCCESS")
		$RangedAttackComp.attack(center)
#		toggle_attack_screen()
func toggle_attack_screen(): 
	var ranged_attack_component = $RangedAttackComp
	if ranged_attack_component.ammo <= 0:
		return
	super.toggle_attack_screen() 
 
func update_stats_bar():
	super.update_stats_bar()
	$UnitStatsBar/VBoxContainer/Ammo.text = "Ammo "+str($RangedAttackComp.ammo)

func _on_ranged_attack_comp_ammo_changed(_ammo):
	update_stats_bar()
