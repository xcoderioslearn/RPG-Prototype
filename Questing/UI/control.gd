extends Control

@onready var title_label: Label = $TitleFrame/QuestTitleBackground/QuestTitleMiddle
@onready var npc_name_label: Label = $IconFrame/IconBackground/NPCName
@onready var description_label: Label = $BodyFrame/DescriptionBackground/DescriptionVBox/Description
@onready var objective_label: Label = $BodyFrame/DescriptionBackground/DescriptionVBox/Objective
@onready var reward_label: Label = $BodyFrame/DescriptionBackground/DescriptionVBox/Reward
@onready var accept_button: TextureButton = $YesFrame/YesButton
@onready var refuse_button: TextureButton = $NoFrame/NoButton
@onready var ok_button: TextureButton = $OK/Ok
@onready var yes_frame: PanelContainer = $YesFrame
@onready var no_frame: PanelContainer = $NoFrame
@onready var ok: PanelContainer = $OK


var current_quest: Quest = null
var npc_name: String = ""

func _ready() -> void:
	visible = false
	Stats.increase_kill_count.connect(_on_mob_killed)

	# Hide buttons initially
	yes_frame.visible = false
	no_frame.visible = false
	ok.visible = false
	



func show_quest(quest: Quest, npc: String) -> void:
	current_quest = quest
	npc_name = npc

	title_label.text = quest.title
	npc_name_label.text = npc
	description_label.text = quest.description
	objective_label.text = "Objective: %s" % quest.objective
	reward_label.text = "Reward: %s gold" % quest.reward

	# Control button visibility based on quest state
	match quest.state:
		Quest.State.AT_NPC:
			yes_frame.visible = true
			no_frame.visible = true
			ok.visible = false
		Quest.State.IN_PROGRESS:
			objective_label.text = str(current_quest.current_count) + " of " +str(current_quest.target_count) + " touched."
			yes_frame.visible = false
			no_frame.visible = false
			ok.visible = false
		Quest.State.OBJECTIVE_MET:
			description_label.text = ""
			objective_label.text = ""
			reward_label.text = "Thank you for your help\nHere is your reward\nFarewell" 
			yes_frame.visible = false
			no_frame.visible = false
			ok.visible = true
		Quest.State.DONE:
			visible = false
			return

	visible = true


func _on_accept_pressed() -> void:
	if current_quest and current_quest.state == Quest.State.AT_NPC:
		current_quest.state = Quest.State.IN_PROGRESS
		QuestManager.active_quest = current_quest
		print("Quest accepted: %s" % current_quest.title)
		visible = false  # hide after accepting


func _on_refuse_pressed() -> void:
	print("Quest refused")
	current_quest = null
	visible = false


func _on_ok_pressed() -> void:
	if current_quest and current_quest.state == Quest.State.OBJECTIVE_MET:
		current_quest.state = Quest.State.DONE
		QuestManager.active_quest = null
		print("Quest '%s' finished! You earned %s gold!" % [current_quest.title, current_quest.reward])
		# TODO: Give player gold, XP, etc.
		visible = false


func _on_mob_killed(count: int, category: String) -> void:
	if current_quest and current_quest.state == Quest.State.IN_PROGRESS and category == "Mob":
		current_quest.current_count += count
		var progress = min(current_quest.current_count, current_quest.target_count)
		objective_label.text = "Objective: Kill %s (%d / %d)" % [
			current_quest.objective, progress, current_quest.target_count
		]
		if current_quest.current_count >= current_quest.target_count:
			current_quest.state = Quest.State.OBJECTIVE_MET
			objective_label.text += " — Done!"
			print("Quest objective complete! Return to %s." % npc_name)
