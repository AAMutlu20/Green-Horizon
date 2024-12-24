extends Camera2D

@export var zoomSpeed : float = 5;
@export var moveSpeed : float = 5;

var zoomTarget :Vector2
var dragStartMousePos = Vector2.ZERO
var dragStartCameraPos = Vector2.ZERO
var isDragging : bool = false

func _ready():
	zoomTarget = zoom

func _process(delta):
	Zoom(delta)
	SimplePan(delta)
	ClickAndDrag()
	
func Zoom(delta):
	if Input.is_action_just_pressed("cam_zoom_in"):
		zoomTarget *= 1.1
	if Input.is_action_just_pressed("cam_zoom_out"):
		zoomTarget /= 1.1
	
	zoom = zoom.slerp(zoomTarget, zoomSpeed * delta)

func SimplePan(delta):
	var panAmount = Vector2.ZERO
	
	if Input.is_action_pressed("cam_move_up"):
		panAmount.y -= moveSpeed
	if Input.is_action_pressed("cam_move_down"):
		panAmount.y += moveSpeed
	if Input.is_action_pressed("cam_move_left"):
		panAmount.x -= moveSpeed
	if Input.is_action_pressed("cam_move_right"):
		panAmount.x += moveSpeed

	panAmount = panAmount.normalized()
	position += panAmount * delta * 500 * (1/zoom.x)

func ClickAndDrag():
	if !isDragging and Input.is_action_just_pressed("cam_pan"):
		dragStartMousePos = get_viewport().get_mouse_position()
		dragStartCameraPos = position
		isDragging = true
	
	if isDragging and Input.is_action_just_released("cam_pan"):
		isDragging = false

	if isDragging:
		var moveVector = get_viewport().get_mouse_position() - dragStartMousePos
		position = dragStartCameraPos - moveVector * (1/zoom.x)
