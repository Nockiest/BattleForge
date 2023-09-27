extends BattleUnit
class_name SupportUnit
@onready var support_action = $SupportAction # i will change this variable in the children
#var supporting_state = false
 
func move():
	super.move()
	support_action.supported_entity = null
 
func _on_support_action_invalid_support():
	print("invaliid_action") 
	
func _ready():
	super._ready()
	unit_name = "support_unit"
## override for the supper funcion
func process_action():
	do_supporting_action()
func do_supporting_action():
	if Globals.action_taking_unit == self:
		support_action.choose_supported()
#		toggle_attack_screen()
#func toggle_attack_screen():
#	super.toggle_attack_screen()
#	if Globals.action_taking_unit == self:
#		Globals.action_taking_unit = null
#	elif Globals.hovered_unit != self:
#		return
#	else:
#		Globals.action_taking_unit = self
#
