extends Control

@onready var b1 = $VBoxContainer/HBoxContainer/bucket1
@onready var b2 = $VBoxContainer/HBoxContainer/bucket2
@onready var b3 = $VBoxContainer/HBoxContainer/bucket3

var buckets: Array = []

func _ready():
	b1 = $VBoxContainer/HBoxContainer/bucket1
	b2 = $VBoxContainer/HBoxContainer/bucket2
	b3 = $VBoxContainer/HBoxContainer/bucket3
	
	buckets = [b1, b2, b3]
	
	b1.get_node("VBoxContainer/Label").text = "Bucket 1"
	b2.get_node("VBoxContainer/Label").text = "Bucket 2"
	b3.get_node("VBoxContainer/Label").text = "Bucket 3"
	update_buckets()

func get_bucket(n: int) -> Control:
	if n > 3:
		return null
	else:
		return buckets[n-1]

func update_buckets() -> void:
	for b in buckets:
		b.update()

func move_to_from_color(from: int, to: int, amnt: int, color: String) -> String:
	var f = get_bucket(from)
	var t = get_bucket(to)
	if f == null or t == null:
		return "Destination/source not valid"
	if f.data[color] < amnt:
		return "Not enough "+color+" balls in bucket "+str(from)+"."
	
	f.data[color] -= amnt
	t.data[color] += amnt
	
	update_buckets()
	
	return "Moved " + str(amnt) + " "+color+" balls from bucket "+str(from)+" to bucket "+str(to)+"."
