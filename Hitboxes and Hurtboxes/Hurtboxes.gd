extends Area2D

const HitEffect = preload("res://Effects/HitEffect.tscn")
var invincible = false setget set_invincible
onready var timer = $Timer
onready var collisionShape = $CollisionShape2D 

signal invicibility_started
signal invincibility_ended

func set_invincible(value):
	invincible = value
	if invincible:
		emit_signal("invicibility_started")
	else:
		emit_signal("invincibility_ended")
		
func create_Hit_Effect():
	var hitEffect = HitEffect.instance()
	var main = get_tree().current_scene
	main.add_child(hitEffect)
	hitEffect.global_position = global_position 

func start_invincibility(duration):
	self.invincible = true
	timer.start(duration)
	
func _on_Timer_timeout():
	self.invincible = false


func _on_Hurtboxes_invicibility_started():
	collisionShape.set_deferred("disabled",true)
	#monitorable = false


func _on_Hurtboxes_invincibility_ended():
	collisionShape.disabled = false
