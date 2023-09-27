class_name RangedAttackComp
extends DefaultAttackComponent
signal ammo_changed(ammo)
@onready var projectile_scene:PackedScene = preload("res://scenes/screens/levels/projectiles/bullet.tscn")
var max_ammo: int
@onready var ammo:int = max_ammo:
	get:
		return ammo
	set(value):
		ammo = min(value, max_ammo)
		ammo_changed.emit(ammo)
 

func _ready():
	super._ready()
	$BlastAnimation.hide()

func toggle_attack_screen():
	print(ammo," AMMO WHEN TOGGLING")
	if ammo <= 0:
		return
 
	super.toggle_attack_screen()
	
func update_for_next_turn():
	super.update_for_next_turn()
	ammo += 1
	
func try_attack():
	print("LAUNCHED XXXXXXXXXXXXXXXXXXXXXXX", ammo)
	if    ammo < 0:
		return false
	if super.try_attack() != "SUCESS":
		print("ATTACK FAILED")
		return false
	return true
	print("PROCEEDING ", ammo)
 
		
func attack():
	Globals.last_attacker = get_parent()
	remain_attacks -=1
	var direction = (Globals.hovered_unit.global_position - global_position).normalized()
	shoot_bullet(get_parent().center, direction)
	ammo-=1
func check_can_attack():
	if ammo <= 0:
		return false
		toggle_attack_screen()
	return super.check_can_attack()

func shoot_bullet(pos, direction):
	var bullet = projectile_scene.instantiate() as Area2D
	# Set the position and direction of the bullet
	bullet.position = pos
	bullet.direction = direction
	bullet.color = get_parent().color
	bullet.attack_range = attack_range
	bullet.shooting_unit = get_parent()
	# Make the bullet face its direction
	var target_pos = pos + direction * 100
	var target_angle = (target_pos - pos).angle() + PI/2
	bullet.rotation = target_angle
 
	# Add the bullet to the projectiles node
	var projectiles = get_tree().get_root().get_node("BattleGround").get_node("Projectiles")
	projectiles.add_child(bullet)
	print("BULLET SHOT", projectiles)
 
	print(direction.angle(), direction)
	$BlastAnimation.show()
	$BlastAnimation.rotation = direction.angle() - PI/2 *3
	$BlastAnimation.play("blast")  # Replace "shoot" with the name of your animation

	# Rotate the AnimatedSprite to face the same direction as the bullet	
