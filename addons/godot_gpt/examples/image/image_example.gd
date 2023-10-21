extends Control

@export var api_key: String

@export_group("internal")
@export var image_request: ImageRequest
@export var texture_rect: TextureRect
@export var prompt_input: Control

var state_ready: bool = true

func _ready():
	image_request.api_key = api_key
	
	#connect signals from image_request object to functions to be used externally
	image_request.image_request_completed.connect(_on_image_request_completed)
	image_request.image_request_failed.connect(_on_image_request_failed)
	
	var image: Image = Image.new()
	image = image.load_from_file("res://addons/godot_gpt/examples/image/test.png")
	var texture: ImageTexture = ImageTexture.new()
	texture = texture.create_from_image(image)
	texture_rect.texture = texture

func prompt(prompt: String):
	image_request.image_request(prompt)

func _on_image_request_completed(image: Image):
	var texture: ImageTexture = ImageTexture.new()
	texture = texture.create_from_image(image)
	texture_rect.texture = texture
	
	state_ready = true
	prompt_input.set_button_state(false)

func _on_image_request_failed():
	prompt_input.set_button_state(false)

func _on_prompt_input_prompt_submitted(prompt: String):
	if !state_ready:
		return
	state_ready = false
	prompt_input.set_button_state(true)
	prompt(prompt)
