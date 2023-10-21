extends Control

@export var img_gen: ImageRequest
@export var prompt_input: TextEdit

func _ready():
	img_gen = ImageRequest.new()
	add_child(img_gen)
	img_gen.api_key = "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"
	
	img_gen.image_request_completed.connect(_on_image_request_completed)
	
	var image: Image = Image.new()
	image = image.load_from_file("res://addons/godot_gpt/examples/image/test.png")
	var texture: ImageTexture = ImageTexture.new()
	texture = texture.create_from_image(image)
	$TextureRect.texture = texture
	
	prompt("a turbo incredible gamer gaming on his 3000 dollar setup")

func prompt(prompt: String):
	print("Prompting")
	img_gen.image_request(prompt)

func _on_image_request_completed(image: Image):
	print("Image received")
	var texture: ImageTexture = ImageTexture.new()
	texture = texture.create_from_image(image)
	$TextureRect.texture = texture
