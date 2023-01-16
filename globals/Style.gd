extends Node

# == THEMING ==
# This section contains variables and functions relating to theming the game.
var darkModeOn = false

var lightMode = {
	"background": "#f1e8e6",
	"background-dark": "#edd2cb",
	"foreground": "#361d32",
	"foreground-light": "#543c52",
	"accent": "#f55951"
}

var darkMode = {
	"background": "#543c52",
	"background-dark": "#361d32",
	"foreground": "#edd2cb",
	"foreground-light": "#f1e8e6",
	"accent": "#f55951"
}

func getColors():
	if darkModeOn:
		return darkMode
	else:
		return lightMode

func switchMode():
	darkModeOn = !darkModeOn
	emit_signal("sizeChanged")

# == LAYOUT ==
# This section contains variables and functions relating to responsive layout design.
signal sizeChanged
var signalTimer = 0

func setTimer():
	signalTimer = 20

# Returns "value" percent of "target".
func percent(value: int, target: int):
	return (target * value) / 100

# Returns a pixel value that is the "value" percent of the current window height.
func hercent(value: int):
	return percent(value, get_viewport().size.x)

# Returns a pixel value that is the "value" percent of the current window width.
func vercent(value: int):
	return percent(value, get_viewport().size.y)

# Returns a pixel(int) value from a dimension format string. Dimension formats are
# x%H for x percent of the screen height, x%W for x percent of the screen width, x%h
# for x percent of the parent height, x%w for x percent of the parent width and
# xpx for x pixels. It also accepts "H" for current window height, "W" for current 
# window width and "a" for the aspect ratio (w / h). A value with no suffix will be
# interpreted as a float, with decimal support.
func parseDimension(dimensionString: String, node: Node = null):	
	if dimensionString == "H":
		return get_viewport().size.y
	
	if dimensionString == "W":
		return get_viewport().size.x
	
	if dimensionString == "a":
		return get_viewport().size.x / get_viewport().size.y
	
	if dimensionString.is_valid_float():
		return float(dimensionString)
		
	var value = dimensionString.left(dimensionString.length() - 2)
	value = int(value)
		
	if dimensionString[-2] == "%":
		if dimensionString.ends_with("H"):
			value = vercent(value)
		elif dimensionString.ends_with("W"):
			value = hercent(value)
		elif dimensionString.ends_with("h"):
			value = percent(value, node.get_parent().rect_size.y)
		elif dimensionString.ends_with("w"):
			value = percent(value, node.get_parent().rect_size.x)
		elif dimensionString.ends_with("x"):
			value = percent(value, node.rect_size.x)
		elif dimensionString.ends_with("y"):
			value = percent(value, node.rect_size.y)
		
	return value
	
# Parses a dynamic layout string and returns a bool indicating if the dynamic condition is met.
func parseDynamics(dynamicString:String):
	# Get the parameters and the operand from the string
	var regex = RegEx.new()
	regex.compile("(.+)\\b([<>=]{1,2})(.+)")
	var regexResult = regex.search_all(dynamicString)[0].get_strings()
	regexResult.pop_at(0)
	# Set parameters and operand, create an operation string
	var param_one = parseDimension(regexResult[0])
	var operand = regexResult[1]
	var param_two = parseDimension(regexResult[2])
	var operation_format = "{param1}{operand}{param2}" 
	var operation = operation_format.format({"param1":param_one, "param2":param_two, "operand":operand})
	# Evaluate the operation
	var expression = Expression.new()
	var error = expression.parse(operation, [])
	if error != OK:
		print(expression.get_error_text())
		return
	var result = expression.execute([], null, true)
	if not expression.has_execute_failed():
		return result
	
# Gets a node and a style dict and applies the style to the node.
func setStyle(node: Node, layoutDict: Dictionary) -> void:
	if layoutDict.has("dynamic_rule"):
		if parseDynamics(layoutDict["dynamic_rule"]):
			setStyle(node, layoutDict["dynamic_style"])
			return
	
	if layoutDict.has("height"):
		var height = parseDimension(layoutDict["height"], node)
		if layoutDict.has("min_height"):
			var minHeight = parseDimension(layoutDict["min_height"], node)
			height = max(height, minHeight)
			node.rect_min_size.x = height
		if layoutDict.has("max_height"):
			var maxHeight = parseDimension(layoutDict["max_height"], node)
			height = min(height, maxHeight)
		node.rect_size.y = height
		
	if layoutDict.has("width"):
		var width = parseDimension(layoutDict["width"], node)
		if layoutDict.has("min_width"):
			var minWidth = parseDimension(layoutDict["min_width"], node)
			width = max(width, minWidth)
			node.rect_min_size.y = width
		if layoutDict.has("max_width"):
			var maxWidth = parseDimension(layoutDict["max_width"], node)
			width = min(width, maxWidth)
		node.rect_size.x = width
		
	if layoutDict.has("position"):
		if layoutDict.has("resize"):
			node.set_anchors_and_margins_preset(layoutDict["position"],layoutDict["resize"])
		else:
			node.set_anchors_and_margins_preset(layoutDict["position"], Control.PRESET_MODE_KEEP_SIZE)
	
	#Margin format is <TOP RIGHT BOTTOM LEFT>
	if layoutDict.has("margin"):
		var margins = layoutDict["margin"].split(" ")
		node.margin_top += parseDimension(margins[0], node) - parseDimension(margins[2], node)
		node.margin_bottom += parseDimension(margins[0], node) - parseDimension(margins[2], node)
		node.margin_left += parseDimension(margins[3], node) - parseDimension(margins[1], node)
		node.margin_right += parseDimension(margins[3], node) - parseDimension(margins[1], node)
	
	if layoutDict.has("color"):
		var palette = getColors()
		if palette.has(layoutDict["color"]):
			node.color = Color(getColors()[layoutDict["color"]])
		else:
			node.color = Color(layoutDict["color"])
	
	if layoutDict.has("visible"):
		node.visible = layoutDict["visible"]
	
	if layoutDict.has("signal"):
		node.emit_signal(layoutDict["signal"])
	
	if layoutDict.has("theme"):
		if layoutDict.has("font_size"):
			layoutDict["theme"].default_font.size = parseDimension(layoutDict["font_size"], node)
	
	if layoutDict.has("rotation"):
		node.rect_rotation = layoutDict["rotation"]

func _ready() -> void:
	get_tree().get_root().connect("size_changed", self, "setTimer")

func _process(delta: float) -> void:
	if signalTimer != 0:
		signalTimer -= 1
		if signalTimer == 0:
			emit_signal("sizeChanged")
