extends KinematicBody

var direction = Vector3()
var velocity = Vector3()

var gravity = -27
var jump_height = 10
var walk_speed = 10

var fpv_camera_angle = 0
var fpv_mouse_sensitivity = 0.3
# == phys
var phys_area_object
onready var phys_area = $head/Area
onready var phys_area_aim = $head/Area/aim


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	$player_mesh.visible = false
	OS.set_window_position(Vector2(0,0))

# == control
func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	if event is InputEventMouseMotion:
			rotate_y(deg2rad(-event.relative.x * fpv_mouse_sensitivity))
			var change = -event.relative.y * fpv_mouse_sensitivity
			if change + fpv_camera_angle < 90 and change + fpv_camera_angle > -90:
				$head.rotate_x(deg2rad(change))
				fpv_camera_angle += change
				
# == phys

	if Input.is_action_just_pressed("left_click"):
		for body in phys_area.get_overlapping_bodies():
			if body is RigidBody:
				phys_area_object = body
				return
	if Input.is_action_just_released("left_click"):
			phys_area_object = null
	if Input.is_action_just_pressed("right_click") and phys_area_object != null and weakref(phys_area_object).get_ref():
		var a = phys_area_aim.get_global_transform().origin
		var b = phys_area_object.get_global_transform().origin
		
		phys_area_object.set_linear_velocity((b-a)*10)
		phys_area_object = null

# == phys

func _physics_process(delta):
	if phys_area_object != null and weakref(phys_area_object).get_ref():
		var a = phys_area.get_global_transform().origin
		var b = phys_area_object.get_global_transform().origin
		phys_area_object.set_linear_velocity((a-b)*10)
		if phys_area_object.get("timer") != null:
			phys_area_object.timer = 0

# == move

func _process(delta):
	direction = Vector3()
	var aim = $head/Camera.get_global_transform().basis
	if Input.is_key_pressed(KEY_W):
		direction -= aim.z
	if Input.is_key_pressed(KEY_S):
		direction += aim.z
	if Input.is_key_pressed(KEY_A):
		direction -= aim.x
	if Input.is_key_pressed(KEY_D):
		direction += aim.x
	direction = direction.normalized()
	velocity.y += gravity * delta
	var tv = velocity
	tv = velocity.linear_interpolate(direction * walk_speed,6 * delta)
	velocity.x = tv.x
	velocity.z = tv.z
	velocity = move_and_slide(velocity,Vector3(0,1,0))
# == jumping
	if is_on_floor() and Input.is_key_pressed(KEY_SPACE):
		velocity.y = jump_height