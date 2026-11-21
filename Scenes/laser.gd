extends Area2D

class_name Laser

@export var speed = 900

# Lasers that miss everything are removed here (just above the UFO lane). Without this a laser
# could skip past the thin BulletCatcher on a slow frame and fly forever, and since only one
# laser may exist at a time, the player could never shoot again.
const CEILING_Y = -420

# A laser can only destroy one thing, even if it overlaps two in the same frame.
var spent = false


func _ready():
	area_entered.connect(_on_area_entered)


# Moving in fixed physics steps (15px each at 900px/s) keeps hits reliable even when the
# frame rate drops on slower phones.
func _physics_process(delta):
	position.y -= delta * speed
	if position.y < CEILING_Y:
		queue_free()


func _on_area_entered(area):
	if spent:
		return
	if area.has_method("hit"):
		spent = true
		area.hit()
		queue_free()
