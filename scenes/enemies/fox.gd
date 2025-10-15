extends CharacterBody3D
@onready var animation_player: AnimationPlayer = $Sketchfab_Scene/AnimationPlayer


func _ready() -> void:
	animation_player.play("Armature|A Wait")
