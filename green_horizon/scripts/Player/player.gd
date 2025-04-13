### PLAYER ### CONTROL SCRIPT
### TODO
### FIX THE PROBLEM WHERE THE PLAYER INIFITELY PLAYS THE PICK UP OR CLIMB ANIMATION
### FIX THE PROBLEM WEHRE THE PLAYER CANT ATTACK
### IMPLEMENT JUMPING

extends CharacterBody2D

signal player_died

# Male skeleton parts
@onready var body: Node2D = $Skeleton/Body
@onready var hair: Sprite2D = $Skeleton/Hair
@onready var outfit: Sprite2D = $Skeleton/Outfit

# Female skeleton parts
@onready var f_body: Sprite2D = $FSkeleton/FBody
@onready var f_outfit: Sprite2D = $FSkeleton/FOutfit
@onready var f_hair: Sprite2D = $FSkeleton/FHair

#Male and Female skeleton nodes
@onready var female_skeleton: Node2D = $FSkeleton
@onready var male_skeleton: Node2D = $Skeleton

#Animation player nodes
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var transition: AnimationPlayer = $"../CanvasLayer/Control/AnimationPlayer"


#Player Health
@onready var hearts_parent: HBoxContainer = $"../CanvasLayer/HBoxContainer"

var hearts_list : Array[TextureRect]
var health : int = 2

var speed = 180
const jump_power = -700

const acl = 50
const friction = 70

const gravity = 50

const max_jumps = 2
var current_jumps = 1

var is_jumping : bool = false
var was_jumping : bool = false

var is_falling : bool = false
var was_falling : bool = false

var animation_locked : bool = false
var can_move : bool = true

func initialise_male_player():
	body.texture = Global.male_bodies_collection[Global.selected_body]
	hair.texture = Global.male_hairstyles_collection[Global.selected_hair]
	outfit.texture = Global.male_outfits_collection[Global.selected_outfit]

func initialise_female_player():
	f_body.texture = Global.female_bodies_collection[Global.selected_body]
	f_hair.texture = Global.female_hairstyles_collection[Global.selected_hair]
	f_outfit.texture = Global.female_outfits_collection[Global.selected_outfit]

func _ready():
	if Global.is_female:
		male_skeleton.visible = false
		male_skeleton.set_process(false)
		female_skeleton.visible = true
		female_skeleton.set_process(true)
		initialise_female_player()
	else:
		male_skeleton.visible = true
		male_skeleton.set_process(true)
		female_skeleton.visible = false
		female_skeleton.set_process(false)
		initialise_male_player()
	
	for child in hearts_parent.get_children():
		hearts_list.append(child)
	print(hearts_list)

func _physics_process(delta):
	var input_direction: Vector2 = input()
	
	if(input_direction != Vector2.ZERO):
		accelerate(input_direction)
		play_animation()
	else:
		deccelerate()
		play_animation()
	jump(delta)
	player_movement()

func input() -> Vector2:
	var input_direction = Vector2.ZERO
	if can_move:
		input_direction.x = Input.get_axis("p_move_left", "p_move_right")
	
	if input_direction.x < 0:
		if Global.is_female:
			f_body.flip_h = true
			f_hair.flip_h = true
			f_outfit.flip_h = true
		else:
			body.flip_h = true
			hair.flip_h = true
			outfit.flip_h = true
	else:
		if Global.is_female:
			f_body.flip_h = false
			f_hair.flip_h = false
			f_outfit.flip_h = false
		else:
			body.flip_h = false
			hair.flip_h = false
			outfit.flip_h = false
	
	return input_direction

func accelerate(direction):
	velocity = velocity.move_toward(speed * direction, acl)

func deccelerate():
	velocity = velocity.move_toward(Vector2.ZERO, friction)

func jump(delta):
	velocity.y += gravity * (delta * 90)
	if can_move:
		if Input.is_action_just_pressed("p_jump") and current_jumps < max_jumps:
			velocity.y = jump_power / (delta * 45)
			current_jumps += 1
			is_jumping = true
			is_falling = false
			animation_locked = true
			animation_player.play("jump_start")

	if is_jumping and velocity.y > 0:
		speed = 10000
	else:
		speed = 180

	if is_jumping and velocity.y > 0:
		is_jumping = false
		is_falling = true
		animation_player.play("fall_idle")

	elif velocity.y > 0 and not is_jumping and not is_on_floor():
		if not was_falling:
			animation_player.play("fall_idle")
			animation_locked = true
		is_falling = true
		was_falling = true

	if is_on_floor():
		if is_falling:
			animation_player.play("land_from_fall")
			speed = 90
			animation_locked = true
			await animation_player.animation_finished
			speed = 180
		current_jumps = 1
		is_jumping = false
		is_falling = false
		was_falling = false
		animation_locked = false

func play_animation():
	var input_direction: Vector2 = input()
	if not animation_locked:
		if input_direction != Vector2.ZERO and can_move == true:
			animation_player.play("walk")
		else:
			animation_player.play("idle")

func take_damage():
	if health > 0:
		health -= 1
		animation_player.play("get_hit")
		await animation_player.animation_finished
		position = %RespawnPoint.position
		update_heart_display()
	else:
		kill_player()
		

func update_heart_display():
	for i in range(hearts_list.size()):
		hearts_list[i].visible = i <= health

func kill_player():
	if health == 0:
		animation_player.play("get_hit")
		transition.play("transition")
		player_died.emit()

func player_movement():
	move_and_slide()

func _on_killzone_area_2_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("player"):
		take_damage()
	else:
		pass
func _on_killzone_area_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("player"):
		take_damage()
	else:
		pass
func _on_killzone_area_3_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("player"):
		take_damage()
	else:
		pass
