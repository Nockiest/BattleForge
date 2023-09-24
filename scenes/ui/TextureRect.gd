extends TextureRect

#var viewportWidth = get_viewport().size.x
#var viewportHeight = get_viewport().size.y
#
# Called when the node enters the scene tree for the first time.
func _ready():
	scale = Vector2(0.1,0.1)
	print("SCALE", scale)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
