extends Node

signal increase_kill_count(count: int, category: String)

var kills: Dictionary = {}

func _ready() -> void:
	increase_kill_count.connect(_on_increase_kill_count)

func _on_increase_kill_count(count: int, category: String) -> void:
	kills[category] = kills.get(category, 0) + count
	print("Autoload Update")
	print(kills)
