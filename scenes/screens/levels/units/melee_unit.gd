extends BattleUnit
class_name MeleeUnit
 
func attack():
	if super.attack() == "success":
		$melee_attack_comp.attack(attack_range, color, Globals.hovered_unit )
 
func _ready():
	super._ready()
	unit_name = "melee_unit"
