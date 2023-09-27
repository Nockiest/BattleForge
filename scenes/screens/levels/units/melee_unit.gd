extends BattleUnit
class_name MeleeUnit
 
#func try_attack():
#	if super.try_attack() == "success":
#		$melee_attack_comp.try_attack(  )
#
func _ready():
	super._ready()
	unit_name = "melee_unit"
