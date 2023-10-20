extends Control

@export var gpt: GPTChatRequest
@export var chat_text: RichTextLabel
@export var prompt_input: TextEdit

func _ready():
	gpt.gpt_request_completed.connect(_on_gpt_request_completed)

func _on_gpt_request_completed(response_text: String):
	add_text_to_chat(response_text, "ChatGPT")
	print(gpt.history)

func _on_button_pressed():
	gpt.gpt_chat_request(prompt_input.text)
	add_text_to_chat(prompt_input.text, "Me")
	prompt_input.text = ""

func _on_text_edit_text_changed():
	pass # Replace with function body.

func add_text_to_chat(text: String, from: String) -> void:
	chat_text.text += from + ": " + text
	if not chat_text.text.ends_with("\n"):
		chat_text.text += "\n"
