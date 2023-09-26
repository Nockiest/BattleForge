extends BattleUnit
class_name MeleeUnit
 
func attack():
	if super.attack() == "success":
		$melee_attack_comp.attack(  )
 
func _ready():
	super._ready()
	unit_name = "melee_unit"
