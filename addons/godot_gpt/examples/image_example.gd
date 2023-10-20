extends Control

@export var img: ImageRequest
@export var prompt_input: TextEdit

func _ready():
	var image: Image = Image.new()
	image = image.load_from_file("res://addons/godot_gpt/examples/test.png")
	var texture: ImageTexture = ImageTexture.new()
	texture = texture.create_from_image(image)
	$TextureRect.texture = texture
