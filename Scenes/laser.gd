extends Area2D

class_name Laser

@export var speed = 300

# A laser can only destroy one thing, even if it overlaps two in the same frame.
var spent = false


func _ready():
	area_entered.connect(_on_area_entered)


func _process(delta):
	position.y -= delta * speed


func _on_area_entered(area):
	if spent:
		return
	if area.has_method("hit"):
		spent = true
		area.hit()
		queue_free()
