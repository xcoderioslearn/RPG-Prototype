extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5


var _look := Vector2.ZERO
var _attack_direction := Vector3.ZERO

@export var mouse_sensitivity: float = 0.00075
@export var controller_sensitivity: float = 2.0
@export var min_boundry: float = -60
@export var max_boundry: float = 10
@export var animation_decay: float = 20.0
@export var attack_move_speed: float = 3.0

@onready var horizontal_pivot: Node3D = $HorizontalPivot
@onready var vertical_pivot: Node3D = $HorizontalPivot/VerticalPivot
@onready var rig_pivot: Node3D = $RigPivot
@onready var rig: Node3D = $RigPivot/Rig
@onready var label: Label = $Label



func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	update_camera(delta)
	handle_movement(delta)
	handle_physics_frame_slashing(delta)
	move_and_slide()
	label.text = str(Engine.get_frames_per_second())


func _unhandled_input(event: InputEvent) -> void:
	# handle cursor
	if event.is_action_pressed("esc"):
		Input.mouse_mode = (
			Input.MOUSE_MODE_VISIBLE
			if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
			else Input.MOUSE_MODE_CAPTURED
		)

	# Mouse look
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and event is InputEventMouseMotion:
		_look += -event.relative * mouse_sensitivity


func update_camera(delta: float) -> void:
	var look_x := Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
	var look_y := Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)

	# Deadzone for analog stick
	if abs(look_x) > 0.15 or abs(look_y) > 0.15:
		look_y = -look_y
		_look += Vector2(look_x, look_y) * controller_sensitivity * delta

	
	horizontal_pivot.rotate_y(_look.x)
	vertical_pivot.rotate_x(_look.y)

	# Clamp vertical rotation
	vertical_pivot.rotation.x = clampf(
		vertical_pivot.rotation.x,
		deg_to_rad(min_boundry),
		deg_to_rad(max_boundry)
	)

	# Reset _look for next frame
	_look = Vector2.ZERO


func handle_movement(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jump()
	if Input.is_action_just_pressed("attack") :
		slash()

	var direction = get_movement_direction()
	rig.update_animation_tree(direction)

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
		look_toward_direction(direction, delta)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)


func get_movement_direction() -> Vector3:
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var input_vector := Vector3(input_dir.x, 0, input_dir.y).normalized()
	return horizontal_pivot.global_transform.basis * input_vector


func look_toward_direction(direction: Vector3, delta: float) -> void:
	var target_transform := rig_pivot.global_transform.looking_at(
		rig_pivot.global_position + direction, Vector3.UP, true
	)
	rig_pivot.global_transform = rig_pivot.global_transform.interpolate_with(
		target_transform,
		1.0 - exp(-animation_decay * delta)
	)

func jump() -> void :
	rig.replay_animation("Jump_Full_Short")
	
func slash() -> void:
	rig.replay_animation("1H_Melee_Attack_Stab")
	_attack_direction = get_movement_direction()
	if _attack_direction.is_zero_approx():
		_attack_direction = rig.global_basis * Vector3(0 ,0, 1)
		
func handle_physics_frame_slashing(delta: float)  -> void:
	if not rig.is_slashing():
		return
	velocity = _attack_direction * attack_move_speed
	look_toward_direction(_attack_direction, delta)
