extends Area2D

class_name BunkerPart

# Which corner of the bunker this is: "TopLeft", "TopRight", "BottomLeft" or "BottomRight".
# The 4 damage stages are loaded from Assets/Bunker/Bunker<piece>-<1..4>.png
@export var piece = "TopLeft"

var textures: Array[Texture2D] = []
var damage = 0
var sprite: Sprite2D


func _ready():
	for i in range(1, 5):
		textures.append(load("res://Assets/Bunker/Bunker%s-%d.png" % [piece, i]))
	for child in get_children():
		if child is Sprite2D:
			sprite = child
	area_entered.connect(_on_area_entered)


# Called by player lasers and invader shots.
func hit():
	damage += 1
	if damage >= textures.size():
		queue_free()
	else:
		sprite.texture = textures[damage]


func _on_area_entered(area):
	# Invaders marching into a bunker wipe it out.
	if area is Invader:
		queue_free()
