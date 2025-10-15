extends CharacterBody3D

@onready var animation_player: AnimationPlayer = $Sketchfab_Scene/AnimationPlayer

@export var speed: float = 2.0

func _ready() -> void:
	animation_player.play("Armature|A Wait")
	
func _physics_process(delta: float) -> void:
	move_and_slide()
