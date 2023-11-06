extends Resource
class_name GPTFunctionParam

@export var name: String = ""
enum GPT_PARAM_TYPES {STRING, INTEGER}
@export var type: GPT_PARAM_TYPES = GPT_PARAM_TYPES.STRING
## Allows you to limit the possible values to a provided list. For example, you could pass [code]["Celsius", "Fahrenheit"][/code] if you only want ChatGPT to be able to input "Celsius" or "Fahrenheit." Works with any allowed parameter type.
@export var arg_enum: Array = []
@export_multiline var description: String = ""

func compile() -> Dictionary:
	var type_string: String = "string"
	match type:
		GPT_PARAM_TYPES.STRING:
			type_string = "string"
		GPT_PARAM_TYPES.INTEGER:
			type_string = "integer"
	
	var ret: Dictionary = {
		"type": type_string,
		"description": description
	}
	
	if not arg_enum.is_empty():
		ret["enum"] = arg_enum
	
	return ret
