extends Resource
class_name Quest

enum State { AT_NPC, IN_PROGRESS, OBJECTIVE_MET, DONE }

@export var id: int
@export var title: String
@export var description: String
@export var objective: String
@export var reward: float
@export var target_count: int = 0
var current_count: int = 0
var state: State = State.AT_NPC
