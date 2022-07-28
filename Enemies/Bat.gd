extends KinematicBody2D

onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone
onready var sprite = $AnimatedSprite
onready var hurtBox = $Hurtboxes
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var animationPlayer = $AnimationPlayer

export var ACCELERATION = 300
export var MAX_SPEED = 60
export var FRICTION = 170
var KNOCKBACK_EFFECT = 125
var SOFT_COLLISION_EFFECT = 400
const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

var knockback = Vector2.ZERO
var velocity = Vector2.ZERO

enum{
	IDLE,
	WANDER,
	CHASE
}
var state = CHASE

func _ready():
	state = pick_random_state([IDLE, WANDER])

func _physics_process(delta):
	
	knockback = knockback.move_toward(Vector2.ZERO,FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO,FRICTION * delta)
			seek_player()
			if wanderController.get_time_left() == 0:
				update_state()
				
		WANDER:
			seek_player()
			if wanderController.get_time_left() == 0:
				update_state()
			move_to(wanderController.target_position,delta)
			
			
			if global_position.distance_to(wanderController.target_position) <= 4:
				update_state()
				
			sprite.flip_h = velocity.x < 0	
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				move_to(player.global_position, delta)
			else:
				state = IDLE	
			sprite.flip_h = velocity.x < 0	
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * SOFT_COLLISION_EFFECT * delta	
	velocity = move_and_slide(velocity)

func update_state():
	state = pick_random_state([IDLE, WANDER])
	wanderController.start_wander_timer(rand_range(1,3))
	
func move_to(target, delta):
	var distance = global_position.direction_to(target)
	velocity = velocity.move_toward(distance * MAX_SPEED, ACCELERATION * delta)	
	 
func seek_player():
	if playerDetectionZone.can_see_player():
		state = CHASE
		
func pick_random_state(state_list):
	state_list.shuffle()
	return state_list.pop_front()
	
func _on_Hurtboxes_area_entered(area):
	hurtBox.create_Hit_Effect()
	stats.health -= area.damage
	knockback = area.knockback_vector * KNOCKBACK_EFFECT
	hurtBox.start_invincibility(0.2)

func _on_Stats_no_health():
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
	queue_free()


func _on_Hurtboxes_invicibility_started():
	animationPlayer.play("Start")

func _on_Hurtboxes_invincibility_ended():
	animationPlayer.play("Stop")
