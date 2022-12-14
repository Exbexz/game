extends KinematicBody2D

const PlayerHurtSound = preload("res://Player/PlayerHurtSound.tscn")
export var ACCELERATION = 500
export var FRICTION = 500
export var MAX_SPEED = 90
export var ROLL_SPEED = 110

enum{
	MOVE,
	ROLL,
	ATTACK
}

var velocity = Vector2.ZERO
var state = MOVE
var roll_velocity = Vector2.DOWN
var stats = PlayerStats

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitBox = $HitBoxPivot/SwordHitBoxes
onready var hurtBox = $Hurtboxes
onready var blinkAnimation = $BlinkAnimation

func _ready():
	randomize()
	stats.connect("no_health",self,"queue_free")
	animationTree.active = true
	swordHitBox.knockback_vector = roll_velocity
	
func _process(delta):
	match state:
		MOVE:
			move_state(delta)
			
		ROLL:
			roll_state()
			
		ATTACK:
			attack_state()
	
func move_state(delta):
	var input_vector = Vector2.ZERO
	
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	if input_vector != Vector2.ZERO:
		roll_velocity = input_vector
		swordHitBox.knockback_vector = input_vector
		animationTree.set("parameters/Idle/blend_position",input_vector)
		animationTree.set("parameters/Run/blend_position",input_vector)
		animationTree.set("parameters/Attack/blend_position",input_vector)
		animationTree.set("parameters/Roll/blend_position",input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else :
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO,FRICTION * delta)
		
	move()
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
		
	if Input.is_action_just_pressed("roll"):
		state = ROLL
		

func attack_state():
	velocity = velocity * 0.7
	animationState.travel("Attack")	
	
func roll_state():
	velocity = roll_velocity * ROLL_SPEED
	animationState.travel("Roll")
	move()
	

func attack_animation_finished():
	state = MOVE
	
func roll_animation_finished():
	velocity = Vector2.ZERO
	state = MOVE
	
func move():
	velocity = move_and_slide(velocity)	


func _on_Hurtboxes_area_entered(area):
	hurtBox.start_invincibility(0.6)
	hurtBox.create_Hit_Effect()
	stats.health -= area.damage
	var playerHurtSound = PlayerHurtSound.instance()
	get_tree().current_scene.add_child(playerHurtSound)

func _on_Hurtboxes_invicibility_started():
	blinkAnimation.play("Start")

func _on_Hurtboxes_invincibility_ended():
	blinkAnimation.play("Stop")
