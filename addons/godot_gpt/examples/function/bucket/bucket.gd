extends Control

var id: int = 0

var data: Dictionary = {
	"Red" = 5,
	"Blue" = 5,
	"Green" = 5
}

func set_name(n: String):
	$VBoxContainer/Label.text = n

func get_bucket_name() -> String:
	return $VBoxContainer/Label.text

func to_text(d: Dictionary):
	var r: String = ""
	for k in d.keys():
		r += k + ": " + str(d[k]) + '\n'
	return r

func update():
	$VBoxContainer/dataLabel.text = to_text(data)
