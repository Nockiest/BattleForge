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
	connect("bullet_shot", _on_bullet_shot)   

func attack( ):
	super.attack( )
	## ten check na hovered unit asi nepotřebujiu
	if Globals.hovered_unit   and ammo > 0:
		var direction = (Globals.hovered_unit.global_position - global_position).normalized()
#		bullet_shot.emit(start, direction) 
		_on_bullet_shot(get_parent().center, direction)
		ammo-=1

func _on_bullet_shot(pos, direction):
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
# Assuming $AnimatedSprite is the path to your AnimatedSprite node
	print(direction.angle(), direction)
	$BlastAnimation.show()
	$BlastAnimation.rotation = direction.angle() - PI/2 *3
	$BlastAnimation.play("blast")  # Replace "shoot" with the name of your animation

	# Rotate the AnimatedSprite to face the same direction as the bullet	
