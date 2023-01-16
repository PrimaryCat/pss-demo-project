extends ColorRect

signal sizeChanged

var style = {
	"height": "70%h", #Set height to 50% of the parent height.
	"width": "70%w", #Set width to 50% of the parent width.
	"position": Control.PRESET_CENTER, #Center the node.
	"color": "accent", #Set color to the stylesheet accent color.
	"signal": "sizeChanged", #Set the signal to be emitted whenever the style is applied.
}

func setLayout() -> void:
	Style.setStyle(self, style)

func _ready() -> void:
	get_parent().connect("sizeChanged", self, "setLayout")
	setLayout()
