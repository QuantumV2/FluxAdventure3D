extends CharacterBody3D


const SPEED = 5.0
const RUN_SPEED = 7.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var mouse_sens = 0.3
var accel = 0.8
var frict = .15
var camera_anglev=0
var zoomintensivity = 0
var shadow  = null
var jumpbuffer = null
var coyotetimer = null
var camorigin = null
var shadowraycast = null
var prev_jumping = true
var Dust = preload("res://Prefabs/Dust.tscn")
var rng = RandomNumberGenerator.new()

var animplayer = null

func custom_is_on_floor():
	return (jumpbuffer.time_left and is_on_floor())
	
func _ready():
	Global.CoinSound = $CoinSound
	camorigin = $CamOrigin
	shadowraycast = $RaycastDown
	shadow = get_parent().get_node("Shadow")
	jumpbuffer = get_parent().get_node("JumpBuffer")
	coyotetimer = get_parent().get_node("CoyoteTimer")
	animplayer = get_node("Model/PlayerModel/AnimationPlayer")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
var camroty = 0
var camrotx = 0

var continousCam = false

func _move_cam():
	camorigin.rotate_y(deg_to_rad(camroty*mouse_sens))
	var changev=camrotx*mouse_sens
	if camera_anglev+changev>-50 and camera_anglev+changev<50:
		camera_anglev+=changev
		camorigin.rotate_object_local(Vector3(1,0,0), deg_to_rad(changev))

func _input(event):      

	if (event is InputEventJoypadMotion):
		camroty = Input.get_axis("camright", "camleft") * 8
		camrotx = Input.get_axis("camdown", "camup") * 8
		continousCam = true
	if(event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED):
		camroty = -event.relative.x
		camrotx = -event.relative.y
		continousCam = false

	if event.is_action_pressed("zoomin") and zoomintensivity > -6:
		zoomintensivity -= 1
		camorigin.scale += Vector3(-.1, -.1, -.1)
	if event.is_action_pressed("zoomout") and zoomintensivity < 7:
		zoomintensivity += 1
		camorigin.scale += Vector3(.1, .1, .1)
	if event.is_action_pressed("click"):
		if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED    
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if(not continousCam):
		_move_cam()


func _physics_process(delta):

	if shadowraycast.is_colliding():
		if(!shadow.visible):
			shadow.visible = true
		var collision_point = $RaycastDown.get_collision_point()
		shadow.global_transform.origin = collision_point + Vector3(0, 0.002, 0) #account for z fighting
	if !shadowraycast.is_colliding():
		shadow.visible = false
	var is_walking = false
	var is_jumping = false
	if(continousCam):
		_move_cam()
	# Handle jump.
	if (Input.is_action_just_pressed("jump") and is_on_floor()) or custom_is_on_floor():
		$JumpSound.play()
		velocity.y = JUMP_VELOCITY + (abs(velocity.x) + abs(velocity.z)) / 9
		is_jumping = true
	if Input.is_action_just_released("jump") and is_jumping:
		velocity.y /= 7
	if Input.is_action_just_pressed("jump") and !is_on_floor():
		jumpbuffer.wait_time = 0.2
		jumpbuffer.start()
		

		
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		is_jumping = true
		
	if prev_jumping == true and is_jumping == false:
		for i in range(4):
			var dust = Dust.instantiate()
			add_child(dust)
			dust.position = Vector3(rng.randf_range(-.4, .4), 0.3, rng.randf_range(-.4, .4))
			 
		$LandSound.play()

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var cam_forward = camorigin.global_transform.basis.z
	var cam_right = camorigin.global_transform.basis.x
	var direction = (cam_forward * input_dir.y + cam_right * input_dir.x).normalized()

	if direction != Vector3(0,0,0):
		$Model.rotation.y = lerp_angle($Model.rotation.y, atan2(-direction.x, -direction.z), delta * 10)
		# Play walk animation if moving, otherwise play idle

	if direction:
		is_walking = true
		velocity.x = lerp(velocity.x, direction.x * (SPEED if !Input.is_action_pressed("run") else RUN_SPEED), accel)
		velocity.z = lerp(velocity.z, direction.z * (SPEED if !Input.is_action_pressed("run") else RUN_SPEED), accel)
	else:
		is_walking = false
		velocity.x = lerp(velocity.x, 0.0, frict)
		velocity.z = lerp(velocity.z, 0.0, frict)
	
	var blend_time = 0.3

	if is_walking and !is_jumping:
		animplayer.play("metarig|Walk", blend_time, (abs(velocity.x) + abs(velocity.z)) / 2)
	elif !is_walking and !is_jumping:
		animplayer.play("metarig|Idle", blend_time)
	elif is_jumping and animplayer.current_animation != "metarig|Jump":
		animplayer.play("metarig|Jump", blend_time)
		
	move_and_slide()
	prev_jumping = is_jumping

