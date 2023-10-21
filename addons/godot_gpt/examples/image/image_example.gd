extends Control

@export var img_gen: ImageRequest
@export var prompt_input: TextEdit

var state_ready: bool = true

func _ready():
	img_gen = ImageRequest.new()
	add_child(img_gen)
	img_gen.api_key = "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"
	
	#connect signals from img_gen object to functions to be used externally
	img_gen.image_request_completed.connect(_on_image_request_completed)
	img_gen.image_request_failed.connect(_on_image_request_failed)

func prompt(prompt: String):
	print("Prompting")
	img_gen.image_request(prompt)

func _on_image_request_completed(image: Image):
	print("Image received")
	var texture: ImageTexture = ImageTexture.new()
	texture = texture.create_from_image(image)
	$TextureRect.texture = texture
	
	state_ready = true
	$prompt_input.set_button_state(false)

func _on_image_request_failed():
	state_ready = true
	$Button.disabled = false
	$Button.text = "Submit, but last thing errored"

func _on_prompt_input_prompt_submitted(prompt):
	if !state_ready:
		return
	state_ready = false
	$prompt_input.set_button_state(true)
	prompt(prompt)
