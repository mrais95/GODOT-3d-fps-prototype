extends KinematicBody

var speed
var default_move_speed = 35
var walk_move_speed = 20
var crouch_move_speed = 10
var crouch_speed = 20
var acceleration = 20
var gravity = 30
var jump = 15
var jump_num = 0
var blink_dist = 28
var walking = false
var damage = 25
var shoot_available = true

var default_height = 1.5
var crouch_height = 0.5

var mouse_sensitivity = 0.1

var direction = Vector3()
var velocity = Vector3()
var fall = Vector3()

onready var head = $Head
onready var pcap = $CollisionShape
onready var bonker = $Head/HeadBonker
onready var sprint_timer = $SprintTimer
onready var aimcast = $Head/Camera/AimCast
onready var b_decal = preload("res://src/objects/BulletDecal.tscn")

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-90), deg2rad(90))

func _physics_process(delta):
	
	var head_bonked = false
	speed = default_move_speed
	direction = Vector3()
	
	if bonker.is_colliding():
		head_bonked = true
	
	if head_bonked:
		fall.y = -2
	
	if is_on_floor():
		jump_num = 0
	
	if not is_on_floor():
		fall.y -= gravity * delta
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		if jump_num == 0:
			fall.y = jump
			jump_num = 1
	
	if Input.is_action_just_pressed("jump") and not is_on_floor():
		if jump_num == 1:
			fall.y = jump
			jump_num = 2
	
	if Input.is_action_pressed("crouch"):
		pcap.shape.height -= crouch_speed * delta
		speed = crouch_move_speed
	elif not head_bonked:
		pcap.shape.height += crouch_speed * delta
		
	pcap.shape.height = clamp(pcap.shape.height, crouch_height, default_height)
	
	if Input.is_action_pressed("move_forward"):
		direction -= transform.basis.z
	
	elif Input.is_action_pressed("move_backward"):
		direction += transform.basis.z
	
	if Input.is_action_pressed("move_left"):
		direction -= transform.basis.x
	
	elif Input.is_action_pressed("move_right"):
		direction += transform.basis.x
	
	if Input.is_action_just_pressed("ability_1"):
		translate(Vector3(0,0,-blink_dist))
	
	if Input.is_action_pressed("ability_2"):
		gravity = -10
	
	if Input.is_action_just_released("ability_2"):
		gravity = 30
	
	if Input.is_action_pressed("walk"):
		speed = walk_move_speed
	
	if Input.is_action_just_pressed("walk") and not walking:
		walking = true
		sprint_timer.start()
	elif Input.is_action_just_pressed("walk") and walking:
		walking = false
		
	
	if Input.is_action_just_pressed("fire"):
		if shoot_available:
			shoot_available = false
			get_node("AnimationPlayer").play("shooting")
			get_node("Head/DesertEagle/AudioStreamPlayer3D").play()
			if aimcast.is_colliding():
				var target = aimcast.get_collider()
				if target.is_in_group("enemy"):
					target.health -= damage
				if target.is_in_group("wall"):
					var b = b_decal.instance()
					target.add_child(b)
					b.global_transform.origin = aimcast.get_collision_point()
					b.look_at(aimcast.get_collision_point() + aimcast.get_collision_normal(), Vector3.UP)
			yield(get_node("AnimationPlayer"), "animation_finished")
			shoot_available = true
		
	


	direction = direction.normalized()
	velocity = velocity.linear_interpolate(direction * speed, acceleration * delta)
	velocity = move_and_slide(velocity, Vector3.UP)
	move_and_slide(fall, Vector3.UP)


func _on_SprintTimer_timeout() -> void:
	walking = false
