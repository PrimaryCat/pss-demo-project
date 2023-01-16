extends Control

signal layoutUpdate

func setLayout() -> void:
	Style.setStyle($Background, {"color": "background"})
	emit_signal("layoutUpdate")

func _ready() -> void:
	Style.connect("sizeChanged", self, "setLayout")
	setLayout()
