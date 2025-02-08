### PLAYER ### CONTROL SCRIPT

extends CharacterBody2D

# Male skeleton parts
@onready var body: Sprite2D = $Skeleton/Body
@onready var hair: Sprite2D = $Skeleton/Hair
@onready var outfit: Sprite2D = $Skeleton/Outfit
@onready var name_label: Label = $Skeleton/Name

# Female skeleton parts
@onready var Fbody: Sprite2D = $FSkeleton/Body
@onready var Fhair: Sprite2D = $FSkeleton/Hair
@onready var Foutfit: Sprite2D = $FSkeleton/Outfit
@onready var Fname_label: Label = $FSkeleton/Name

#Male and Female skeleton nodes
@onready var female_skeleton: Node2D = $FSkeleton
@onready var male_skeleton: Node2D = $Skeleton


const speed = 250
const jump_power = -1250

const acl = 50
const friction = 70

const gravity = 100

const max_jumps = 1
var current_jumps = 0

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

func _physics_process(delta):
	var input_direction: Vector2 = input()
	
	# Only for testing: print(input_direction)
	
	if(input_direction != Vector2.ZERO):
		accelerate(input_direction)
		play_animation() # TODO
	else:
		deccelerate()
		play_animation() # TODO
	jump()
	player_movement()

### MALE ### PLAYER SCRIPT

func input() -> Vector2:
	var input_direction = Vector2.ZERO
	
	input_direction.x = Input.get_axis("p_move_left", "p_move_right")
	input_direction = input_direction.normalized()
	
	return input_direction

func accelerate(direction):
	velocity = velocity.move_toward(speed * direction, acl)

func deccelerate():
	velocity = velocity.move_toward(Vector2.ZERO, friction)
	
func jump():
	if Input.is_action_just_pressed("p_jump"):
		if current_jumps < max_jumps:
			velocity.y = jump_power
			current_jumps += 1

	velocity.y += gravity

	if is_on_floor():
		current_jumps = 0

func initialise_male_player():
	body.texture = Global.male_bodies_collection[Global.selected_body]
	hair.texture = Global.male_hairstyles_collection[Global.selected_hair]
	outfit.texture = Global.male_outfits_collection[Global.selected_outfit]
	name_label.text = Global.player_name

func initialise_female_player():
	Fbody.texture = Global.female_bodies_collection[Global.selected_body]
	Fhair.texture = Global.female_hairstyles_collection[Global.selected_hair]
	Foutfit.texture = Global.female_outfits_collection[Global.selected_outfit]
	Fname_label.text = Global.player_name

func play_animation():
	pass

func player_movement():
	move_and_slide()
