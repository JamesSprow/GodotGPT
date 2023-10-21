# This script extends the Control node and manages a simple chat interface for interactions with the GPT API.

extends Control

# Exported variable that references the GPTChatRequest object, which handles interactions with GPT.
@export var gpt: GPTChatRequest
# Exported variable referencing the RichTextLabel where chat messages will be displayed.
@export var chat_text: RichTextLabel
# Exported variable referencing the TextEdit control where users will input their messages.
@export var prompt_input: TextEdit

# Function called when the node is added to the scene. Sets up signal connections.
func _ready():
	# Connect the signal from GPTChatRequest that is emitted when a request is completed.
	gpt.gpt_request_completed.connect(_on_gpt_request_completed)

# Callback function for when a GPT request has been completed.
func _on_gpt_request_completed(response_text: String):
	# Add GPT's response to the chat display.
	add_text_to_chat(response_text, "ChatGPT")
	# Print the entire chat history to the console.
	print(gpt.history)

# Function to handle when the button to send a message is pressed.
func _on_button_pressed():
	# Send the text from the input control to GPT for a response.
	gpt.gpt_chat_request(prompt_input.text)
	# Add the user's message to the chat display.
	add_text_to_chat(prompt_input.text, "Me")
	# Clear the input control after sending the message.
	prompt_input.text = ""

# Placeholder function to handle when the text in the input control changes.
# Currently does nothing, but can be filled in with a function body if needed.
func _on_text_edit_text_changed():
	pass # Replace with function body.

# Function to add a new message to the chat display.
func add_text_to_chat(text: String, from: String) -> void:
	# Append the sender's name and message to the chat display.
	chat_text.text += from + ": " + text
	# Ensure each message ends with a newline for proper formatting.
	if not chat_text.text.ends_with("\n"):
		chat_text.text += "\n"
