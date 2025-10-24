extends CharacterBody3D

const MOB = "Mob"
@onready var stats = Stats
@onready var hit_box: Area3D = $HitBox
@onready var animation_player: AnimationPlayer = $Sketchfab_Scene/AnimationPlayer


func _ready() -> void:
	animation_player.play("Armature|A Wait")
	hit_box.body_entered.connect(_on_hitbox_body_entered)
	
func _physics_process(delta: float) -> void:
	pass
	
func _on_hitbox_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if QuestManager.has_active_mob_quest(): 
			print("mob died (counted for quest)")
			death()
		else:
			print("mob died (no quest active)")
			queue_free()

func death() -> void:
	stats.increase_kill_count.emit(1, MOB)
	queue_free()
