extends ColorRect

var style = {
	"height": "100px", #Set height to 100px.
	"width": "100px", #Set width to 100px.
	"position": Control.PRESET_TOP_RIGHT, #Position the node top right.
	"margin": "10%h 10px 0px 0px", #Add 10% of parent height top margin and 10px right margin
	"color": "#00FF99", #Set color to hex value.
}

func setLayout() -> void:
	Style.setStyle(self, style)

func _ready() -> void:
	get_parent().connect("sizeChanged", self, "setLayout")
	setLayout()
