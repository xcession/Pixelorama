extends Container

const PADDING := 1

@export var h_scroll_bar_node_path: NodePath
@onready var h_scroll_bar: HScrollBar = get_node_or_null(h_scroll_bar_node_path)


func _ready():
	clip_contents = true
	sort_children.connect(_on_sort_children)
	if is_instance_valid(h_scroll_bar):
		h_scroll_bar.resized.connect(_update_scroll)
		h_scroll_bar.value_changed.connect(_on_scroll_bar_value_changed)


func _gui_input(event: InputEvent) -> void:
	if get_child_count():
		var vertical_scroll: bool = get_child(0).size.y >= size.y
		if event is InputEventMouseButton and (event.shift_pressed or not vertical_scroll):
			if is_instance_valid(h_scroll_bar):
				if event.button_index == MOUSE_BUTTON_WHEEL_UP:
					h_scroll_bar.value -= Global.animation_timeline.cel_size / 2 + 2
					accept_event()
				elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
					h_scroll_bar.value += Global.animation_timeline.cel_size / 2 + 2
					accept_event()


func _update_scroll() -> void:
	if get_child_count():
		if is_instance_valid(h_scroll_bar):
			h_scroll_bar.max_value = get_child(0).size.x
			h_scroll_bar.page = size.x
			h_scroll_bar.visible = h_scroll_bar.page < h_scroll_bar.max_value
			get_child(0).position.x = -h_scroll_bar.value + PADDING


func ensure_control_visible(control: Control):
	if not is_instance_valid(control):
		return
	# Based on Godot's implementation in ScrollContainer
	var global_rect := get_global_rect()
	var other_rect := control.get_global_rect()
	var diff := maxf(
		minf(other_rect.position.x, global_rect.position.x),
		other_rect.position.x + other_rect.size.x - global_rect.size.x
	)
	h_scroll_bar.value += diff - global_rect.position.x


func _on_sort_children() -> void:
	if get_child_count():
		get_child(0).size = get_child(0).get_combined_minimum_size()
		_update_scroll()


func _on_scroll_bar_value_changed(_value: float) -> void:
	_update_scroll()


func _clips_input() -> bool:
	return true
