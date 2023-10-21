extends PanelContainer

@export var label_node: Label
@export var text_node: RichTextLabel

func configure(label: String, text: String) -> void:
	label_node.text = label
	text_node.text = text
