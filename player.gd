extends CharacterBody3D

const MOTION_SPEED = 90.0

@export
var synced_position := Vector3()

@onready
var inputs = $Inputs
var current_anim = ""

func _ready():
	position = synced_position
	if str(name).is_valid_int():
		get_node("Inputs/InputsSync").set_multiplayer_authority(str(name).to_int())
		print("Local authority is ", str(multiplayer.get_unique_id()), " and this node is ", str(name))
		if str(multiplayer.get_unique_id()) == str(name):
			print("Therefore, adding camera to this node (", str(name), ")")
			# Add camera
			var camera_node = Camera3D.new()
			camera_node.current = true
			camera_node.fov = 85.0
			$Head.add_child(camera_node)


func _physics_process(delta):
	if multiplayer.multiplayer_peer == null or str(multiplayer.get_unique_id()) == str(name):
		# The client which this player represent will update the controls state, and notify it to everyone.
		inputs.update()

	if multiplayer.multiplayer_peer == null or is_multiplayer_authority():
		# The server updates the position that will be notified to the clients.
		synced_position = position
		# And increase the bomb cooldown spawning one if the client wants to.
	else:
		# The client simply updates the position to the last known one.
		position = synced_position

	# Everybody runs physics. I.e. clients tries to predict where they will be during the next frame.
	velocity = Vector3(inputs.motion.x, 0.0, inputs.motion.y) * MOTION_SPEED
	move_and_slide()

	# Also update the animation based on the last known player input state

func set_player_name(value):
	$PlayerName.text = value


@rpc("call_local")
func exploded(_by_who):
	get_node("anim").play("stunned")
