extends CharacterBody3D

@onready var animation_player: AnimationPlayer = $Barbarian/AnimationPlayer
@onready var bubble_marker: Node3D = $BubbleMarker
@onready var interact_label: Label3D = $InteractLabel

@export var interact_distance: float = 3.0


func _ready() -> void:
	animation_player.play("Sit_Floor_Idle")
	interact_label.visible = false

func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	var in_range = global_position.distance_to(player.global_position) <= interact_distance
	interact_label.visible = in_range 

	if in_range and Input.is_action_just_pressed("interact") :
		pass
