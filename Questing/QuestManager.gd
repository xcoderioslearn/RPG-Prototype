extends Node

var active_quest: Quest = null

func has_active_mob_quest() -> bool:
	if active_quest and active_quest.state == Quest.State.IN_PROGRESS and active_quest.objective.contains("Objective"):
		print("active quest, active_quest in progress")
		return true
	return false
