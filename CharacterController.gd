extends CharacterBody3D
@onready var Hitbox = preload("res://HitBoxTest.tscn")

@export_group("Camera")
@export_range(0.1,1.0) var mouse_sens := 0.25

@export_group("Movement")
@export var Move_speed := 8.0
@export var Acceleration := 20.0
@export var rotation_speed = 12

@export_group("Stats")
@export var health := 100
@export var energy := 100
@export var level := 0
@export var experience := 0
@export var MeleeDmg := 1
@export var FruitDmg := 1
@export var SwordDmg := 1
@export var GunDmg := 1
@export var SelectedTool = "Melee"

@export_group("SelectedWeapons")
@export var FightingStyle = "Basic"
@export var Fruit = "None"
@export var Sword = "None"
@export var Gun = "None"

@export_group("StatBolean")
@export var Attacking = false
@export var Dashing = false
@export var Stunned = false
@export var MovementLock = false
@export var Menu = false




var _camera_input_direction := Vector2.ZERO
var _last_movement_direction := Vector3.BACK

@onready var Pivot: Node3D = %CamOrigin
@onready var Camera: Camera3D = %Camera3D
@onready var body: MeshInstance3D = %Body

func _input(event: InputEvent):
	if event.is_action_pressed("LeftClick"):
		if !Attacking and !Stunned and !Menu:
			var damage
			if SelectedTool == "Melee":
				damage = MeleeDmg
			if SelectedTool == "Fruit":
				damage = FruitDmg
			if SelectedTool == "Gun":
				damage = GunDmg
			if SelectedTool == "Sword":
				damage = SwordDmg
			CreateHitbox()
	if event.is_action_pressed("ui_cancel"):
		Menu = !Menu
		
	
func _unhandled_input(event: InputEvent) -> void:
	var is_camera_motion := (
		event is InputEventMouseMotion and
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if is_camera_motion:
		_camera_input_direction = event.screen_relative * mouse_sens
		
func _physics_process(delta: float) -> void:
	if Menu:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if !Menu:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if Input.is_action_just_pressed("Dash"):
		if energy >= 0 and !Attacking and !Dashing and !Stunned and !MovementLock:
			Dashing = true
			Move_speed += 10
			await get_tree().create_timer(0.2).timeout
			Move_speed -= 10
			Dashing = false
			
	Pivot.rotation.x -= _camera_input_direction.y * delta
	Pivot.rotation.x = clamp(Pivot.rotation.x,-PI / 6.0, PI /3.0)
	Pivot.rotation.y -= _camera_input_direction.x * delta
	_camera_input_direction = Vector2.ZERO
	
	var raw_input := Input.get_vector("Left","Right","Forward","Back")
	var forward := Camera.global_basis.z
	var right := Camera.global_basis.x
	
	var move_direction := forward * raw_input.y + right * raw_input.x
	move_direction.y = 0.0
	move_direction = move_direction.normalized()
	
	velocity = velocity.move_toward(move_direction * Move_speed, Acceleration * delta)
	move_and_slide()
	
	if move_direction.length() > 0.2:
		_last_movement_direction = move_direction
	var target_angle := Vector3.BACK.signed_angle_to(_last_movement_direction, Vector3.UP)
	body.global_rotation.y = lerp(body.rotation.y, target_angle, rotation_speed*delta)

func CreateHitbox():
	var AttackHitbox = Hitbox.instantiate()
	add_child(AttackHitbox)
