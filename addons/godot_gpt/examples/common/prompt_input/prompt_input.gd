extends HBoxContainer

@export_multiline var text_box_placeholder: String

@onready var text_box: TextEdit = $prompt_input_text
@onready var button: Button = $submit_button

var loading: bool = false

signal prompt_submitted(prompt: String)

func _ready() -> void:
	text_box.prompt_submitted.connect(submit_prompt)
	button.pressed.connect(submit_prompt)

func submit_prompt() -> void:
	if loading:
		return
	
	var prompt: String = text_box.text
	text_box.text = ""
	prompt_submitted.emit(prompt)

func set_button_state(_loading: bool) -> void:
	loading = _loading
	if loading:
		button.text = "Loading..."
		button.disabled = true
	else:
		button.text = "Submit"
		button.disabled = false
	
