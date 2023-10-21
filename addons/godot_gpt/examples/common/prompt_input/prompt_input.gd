# This script extends the HBoxContainer node and is designed to provide a user interface 
# for submitting text prompts. It contains a TextEdit for input and a Button for submission.

extends HBoxContainer

# Exported variable for setting a placeholder text in the TextEdit.
@export_multiline var text_box_placeholder: String

# References to the child nodes: a TextEdit for entering prompts and a Button for submission.
@onready var text_box: TextEdit = $prompt_input_text
@onready var button: Button = $submit_button

# State variable to check if a submission is in progress (e.g., waiting for an API response).
var loading: bool = false

# Signal to notify other nodes when a prompt has been submitted.
signal prompt_submitted(prompt: String)

# Function called when the node is added to the scene. It initializes properties and sets up signal connections.
func _ready() -> void:
	# Set the placeholder text for the TextEdit.
	text_box.placeholder_text = text_box_placeholder
	# Connect the TextEdit's submission signal (e.g., pressing Enter) to our custom submit function.
	text_box.prompt_submitted.connect(submit_prompt)
	# Connect the Button's pressed signal to our custom submit function.
	button.pressed.connect(submit_prompt)

# Function to handle the submission of a prompt.
func submit_prompt() -> void:
	# If a submission is already in progress (loading state), do nothing.
	if loading:
		return
	
	# Extract the entered text from the TextEdit.
	var prompt: String = text_box.text
	# Clear the TextEdit.
	text_box.text = ""
	# Emit the "prompt_submitted" signal with the entered prompt.
	prompt_submitted.emit(prompt)

# Function to update the Button's state based on whether the system is in a loading state.
func set_button_state(_loading: bool) -> void:
	# Update the loading state.
	loading = _loading
	# If in loading state, change the Button's text to "Loading..." and disable it.
	if loading:
		button.text = "Loading..."
		button.disabled = true
	else:
		# If not in loading state, reset the Button's text to "Submit" and enable it.
		button.text = "Submit"
		button.disabled = false
