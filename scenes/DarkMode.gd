extends Button

var style = {
	"margin": "5%H 10px 0px 0px", #Add 5% of window height top margin.
}

func setLayout() -> void:
	Style.setStyle(self, style)

func _ready() -> void:
	get_parent().connect("sizeChanged", self, "setLayout")
	setLayout()

func _on_DarkMode_pressed():
	Style.switchMode()
