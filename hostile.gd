extends CharacterBody3D


@onready var player: CharacterBody3D = $"../Player"

@onready var Self: CharacterBody3D = $"."
@onready var timer: Timer = $Timer

var attacking : bool = false
var foward_speed : int = 0
var direction : bool = false
var Side_Speed : int = 0
var health = 100
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Self.look_at(player.global_position)
	position += transform.basis * Vector3(Side_Speed,0,-foward_speed) * delta

	if direction and !attacking: 
		Side_Speed = 2
	if !direction and !attacking: 
		Side_Speed = -2
		


func _on_timer_timeout() -> void:
	attacking = true
	Side_Speed = 0
	await get_tree().create_timer(0.5).timeout
	foward_speed = 5
	await get_tree().create_timer(2.0).timeout
	foward_speed = -5
	await get_tree().create_timer(0.5).timeout
	foward_speed = 0
	attacking = false
	direction = !direction
	timer.start()
	
func _take_damage(damage):
	health -= damage
