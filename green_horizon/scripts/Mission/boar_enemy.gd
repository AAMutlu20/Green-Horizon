extends CharacterBody2D

@export var player: CharacterBody2D
@export var speed: int = 80
@export var chase_speed: int = 180
@export var acl: int = 360

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var ray_cast: RayCast2D = $Sprite/RayCast2D
@onready var timer: Timer = $Timer

var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction: Vector2
var right_bounds: Vector2
var left_bounds: Vector2
var animation_locked: bool = false

enum States{
	WANDER,
	CHASE
}
var current_state = States.WANDER

func _ready():
	left_bounds = self.position + Vector2(-80, 0)
	right_bounds = self.position + Vector2(80, 0)

func _physics_process(delta: float) -> void:
	handle_gravity(delta)
	handle_movement(delta)
	change_direction()
	look_for_player()

func look_for_player():
	if ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		if collider == player:
			chase_player()
		elif current_state == States.CHASE:
			stop_chase()
	elif current_state == States.CHASE:
		stop_chase()

func chase_player() -> void:
	timer.stop()
	current_state = States.CHASE

func stop_chase() -> void:
	if timer.time_left <= 0:
		timer.start()

func handle_movement(delta: float) -> void:
	if current_state == States.WANDER:
		velocity = velocity.move_toward(direction * speed, acl * delta)
	else:
		velocity = velocity.move_toward(direction * chase_speed, acl * delta)
	move_and_slide()

func change_direction() -> void:
	if current_state == States.WANDER: # Wander state
		sprite.play("walk")
		if sprite.flip_h:
			if self.position.x <= right_bounds.x:
				direction = Vector2(1, 0)
			else:
				sprite.flip_h = false
				ray_cast.target_position = Vector2(-80, 0)
		else:
			if self.position.x >= left_bounds.x:
				direction = Vector2(-1, 0)
			else:
				sprite.flip_h = true
				ray_cast.target_position = Vector2(80, 0)
	else:
		sprite.play("chase")
		direction = (player.position - self.position).normalized()
		direction = sign(direction)
		if direction.x == 1:
			sprite.flip_h = true
			ray_cast.target_position = Vector2(80, 0)
		else:
			sprite.flip_h = false
			ray_cast.target_position = Vector2(-80, 0)

func handle_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

func die():
	queue_free()

func _on_timer_timeout() -> void:
	current_state = States.WANDER

func _on_do_damage_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Took 1 damage")
		body.take_damage()

func _on_do_damage_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Took 1 damage")
		body.take_damage()

func _on_recieve_damage_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		die()
