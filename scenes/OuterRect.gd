extends ColorRect

signal sizeChanged

var style = {
	"height": "70%H", #Set height to 70% of the screen height.
	"width": "70%H", #Set width to 70% of the screen height.
	"position": Control.PRESET_CENTER, #Center the node.
	"color": "foreground", #Set color to the stylesheet foreground color.
	"signal": "sizeChanged", #Set the signal to be emitted whenever the style is applied.
	"dynamic_rule": "a<0.8", #If the aspect ratio of the window is smaller than 0.8, apply the dynamic style.
	"dynamic_style": {
		"height": "80%W", #Set height to 80% of the screen width.
		"width": "80%W", #Set width to 80% of the screen width.
		"position": Control.PRESET_CENTER, #Center the node.
		"signal": "sizeChanged" #Set the signal to be emitted whenever the style is applied.
	}
}

func setLayout() -> void:
	Style.setStyle(self, style)

func _ready() -> void:
	get_parent().connect("layoutUpdate", self, "setLayout")
	setLayout()
