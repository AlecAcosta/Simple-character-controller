extends KinematicBody

export(NodePath) var NodePath_ModelAnimPlay
export(NodePath) var NodePath_Model

onready var ModelAnimPlay:= get_node(NodePath_ModelAnimPlay)
onready var Model:= get_node(NodePath_Model)
onready var LookingAt:= $"LookingAt"

enum STATES{
	idle,
	running,
	jumping
}

#var gravity_s:= 9.8
var speed_s:= 3.33
var velocity:= Vector3.ZERO
var state:= 0

func _ready() -> void:
	change_state(STATES.idle)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().reload_current_scene()

func _physics_process(delta: float) -> void:
	var input_direction:= Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	
	match state:
		STATES.idle:
			if input_direction != Vector2.ZERO:
				change_state(STATES.running)
		STATES.running:
			if input_direction == Vector2.ZERO:
				change_state(STATES.idle)
			velocity = Vector3(input_direction.x, 0, input_direction.y)* speed_s
	
	if Input.is_action_pressed("ui_accept"):
		change_state(STATES.jumping)
	
	if input_direction != Vector2.ZERO:
		LookingAt.look_at(Vector3(transform.origin.x - input_direction.x, 0, transform.origin.z - input_direction.y), Vector3.UP)
	
	Model.rotation.y = lerp_angle(Model.rotation.y, LookingAt.rotation.y, delta * 10)
	
	
#	velocity.y = -gravity_s
	velocity = move_and_slide(velocity, Vector3.UP)


func change_state(new_state):
	if state != new_state:
		state = new_state
		print(state)
		
		match state:
			STATES.idle:
				velocity = Vector3.ZERO
				ModelAnimPlay.play("Idle", 0.1)
			STATES.running:
				ModelAnimPlay.play("Run", 0.1)
			STATES.jumping:
				ModelAnimPlay.play("Jump", 0.1)


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	if anim_name == "Jump":
		change_state(STATES.idle)
