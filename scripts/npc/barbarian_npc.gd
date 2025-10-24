extends CharacterBody3D

@onready var animation_player: AnimationPlayer = $Barbarian/AnimationPlayer
@onready var interact_label: Label3D = $InteractLabel
@onready var conversation_range: Area3D = $ConversationRange
@onready var quest_ui: Control = $"../QuestUI"


@onready var quest: Quest = preload("res://Questing/Quests/kill_mob_fox.tres")
@export var npc_name: String = "NPC"

@export var interact_distance: float = 3.0


func _ready() -> void:
	animation_player.play("Sit_Floor_Idle")
	interact_label.visible = false
	conversation_range.body_entered.connect(_on_body_entered)
	conversation_range.body_exited.connect(_on_body_exited)
	quest_ui.visible = false

func _process(_delta: float) -> void:
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return

	var in_range = global_position.distance_to(player.global_position) <= interact_distance
	interact_label.visible = in_range 

	if in_range and Input.is_action_just_pressed("interact") :
		pass
		
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player") and is_in_group("npc"):
		quest_ui.show_quest(quest, npc_name)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player") and is_in_group("npc"):
		quest_ui.visible = false
