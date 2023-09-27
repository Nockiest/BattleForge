extends Node2D

var range = 100

func _ready():
	visible = true

func _proces():
	queue_redraw() 
func _draw():
	draw_circle(Vector2.ZERO, range, Color("black"))
