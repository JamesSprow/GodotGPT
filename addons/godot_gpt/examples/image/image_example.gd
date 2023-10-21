extends Control

@export var img_gen: ImageRequest
@export var prompt_input: TextEdit

var state_ready: bool = true

func _ready():
	img_gen = ImageRequest.new()
	add_child(img_gen)
	img_gen.api_key = "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"
	
	img_gen.image_request_completed.connect(_on_image_request_completed)
	img_gen.image_request_failed.connect(_on_image_request_failed)
	
	var image: Image = Image.new()
	image = image.load_from_file("res://addons/godot_gpt/examples/image/test.png")
	var texture: ImageTexture = ImageTexture.new()
	texture = texture.create_from_image(image)
	$TextureRect.texture = texture

func prompt(prompt: String):
	print("Prompting")
	img_gen.image_request(prompt)

func _on_image_request_completed(image: Image):
	print("Image received")
	var texture: ImageTexture = ImageTexture.new()
	texture = texture.create_from_image(image)
	$TextureRect.texture = texture
	
	state_ready = true
	$Button.disabled = false
	$Button.text = "Submit"

func _on_image_request_failed():
	state_ready = true
	$Button.disabled = false
	$Button.text = "Submit, but last thing errored"

func _on_prompt_input_prompt_submitted():
	if !state_ready:
		return
	state_ready = false
	$Button.disabled = true
	$Button.text = "Loading"
	var p: String = $prompt_input.text
	prompt(p)


func _on_button_pressed():
	_on_prompt_input_prompt_submitted()
