extends Node3D

var sensitivity : float = 0.2
var rotation_speed : float = 0.01

var zoom_speed : float = 0.5
var max_zoom_distance : float = 40
var camera_zoom : float = 20
var target : Vector3 = Vector3.ZERO

var cameraRigY : Node3D
var cameraRigX : Node3D
var camera : Camera3D
var raycast : RayCast3D

var targetRotationY : float = 0.0
var targetRotationX : float = 0.0
var currentZoom : float = 30.0
var targetZoom : float = 30.0
var zoomInterpolationSpeed : float = 5.0

func _ready():
	cameraRigY = self
	cameraRigX = $CameraRigX
	camera = $CameraRigX/Camera3D
	raycast = $CameraRigX/RayCast3D

func _input(event):
	# Input to rotate camera
	if event is InputEventMouseMotion and Input.is_action_pressed("Move"):
		rotate_camera(event.relative)
	
	# Toggle between render modes in runtime (Debug)
	if event is InputEventKey and Input.is_key_pressed(KEY_P):
		var vp = get_viewport()
		vp.debug_draw = (vp.debug_draw + 1 ) % 5

func rotate_camera(relative: Vector2):
	# Rotate the camera
	var rotation_y = -relative.x * sensitivity * rotation_speed
	var rotation_x = -relative.y * sensitivity * rotation_speed

	targetRotationY += rotation_y
	targetRotationX += rotation_x

func _process(delta: float):
	# Lerp camera rig rotations and zoom
	var interpolationFactor = delta * zoomInterpolationSpeed
	currentZoom = lerp(currentZoom, targetZoom, interpolationFactor)
	
	cameraRigY.rotation.y = lerp(cameraRigY.rotation.y, targetRotationY, interpolationFactor)
	cameraRigX.rotation.x = lerp(cameraRigX.rotation.x, targetRotationX, interpolationFactor)
	camera.position.z = currentZoom
	
	# Input for zooming camera
	if Input.is_action_pressed("zoom_in"):
		zoom_camera(-zoom_speed)
	elif Input.is_action_pressed("zoom_out"):
		zoom_camera(zoom_speed)

func zoom_camera(zoom_amount: float):
	targetZoom = clamp(targetZoom + zoom_amount, 20, max_zoom_distance)
