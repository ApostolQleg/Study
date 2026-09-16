@tool
extends Control

## Посилання на контейнер нижньої панелі (наприклад, BottomRow або BgPanel)
@export var main_panel: Control:
	set(value):
		if main_panel and main_panel.item_rect_changed.is_connected(queue_redraw):
			main_panel.item_rect_changed.disconnect(queue_redraw)
		main_panel = value
		if main_panel:
			main_panel.item_rect_changed.connect(queue_redraw)
		queue_redraw()

## Поточний активний таб (встановлюється через код або інспектор)
@export var active_tab: Control:
	set(value):
		if active_tab and active_tab.item_rect_changed.is_connected(queue_redraw):
			active_tab.item_rect_changed.disconnect(queue_redraw)
		active_tab = value
		if active_tab:
			active_tab.item_rect_changed.connect(queue_redraw)
		queue_redraw()

@export_group("Visual Style")
## Колір та напівпрозорість суцільного фону
@export var bg_color: Color = Color(0.18, 0.27, 0.36, 0.7)
## Колір бордера
@export var border_color: Color = Color.BLACK
## Товщина бордера
@export var border_width: float = 2.0

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_IGNORE
	_connect_signals()

func _connect_signals() -> void:
	if main_panel and not main_panel.item_rect_changed.is_connected(queue_redraw):
		main_panel.item_rect_changed.connect(queue_redraw)
	if active_tab and not active_tab.item_rect_changed.is_connected(queue_redraw):
		active_tab.item_rect_changed.connect(queue_redraw)

func _notification(what: int) -> void:
	# Перемальовуємо при зміні розміру самого MonolithBackground або якщо це Container
	if what == NOTIFICATION_RESIZED or what == Container.NOTIFICATION_SORT_CHILDREN:
		queue_redraw()

func _draw() -> void:
	if not main_panel or not main_panel.is_visible_in_tree():
		return

	var panel_rect := main_panel.get_global_rect()
	panel_rect.position -= global_position

	var points := PackedVector2Array()

	# Перевіряємо, чи є видимий активний таб
	if active_tab and active_tab.is_visible_in_tree():
		var tab_rect := active_tab.get_global_rect()
		tab_rect.position -= global_position

		# Будуємо 8 точок моноліту
		points.append(Vector2(panel_rect.position.x, panel_rect.position.y))
		points.append(Vector2(tab_rect.position.x, panel_rect.position.y))
		points.append(Vector2(tab_rect.position.x, tab_rect.position.y))
		points.append(Vector2(tab_rect.end.x, tab_rect.position.y))
		points.append(Vector2(tab_rect.end.x, panel_rect.position.y))
		points.append(Vector2(panel_rect.end.x, panel_rect.position.y))
		points.append(Vector2(panel_rect.end.x, panel_rect.end.y))
		points.append(Vector2(panel_rect.position.x, panel_rect.end.y))
	else:
		# Якщо активного таба немає — малюємо звичайну прямокутну панель
		points.append(Vector2(panel_rect.position.x, panel_rect.position.y))
		points.append(Vector2(panel_rect.end.x, panel_rect.position.y))
		points.append(Vector2(panel_rect.end.x, panel_rect.end.y))
		points.append(Vector2(panel_rect.position.x, panel_rect.end.y))

	# 1. Заливка суцільного полігону без подвійної прозорості
	draw_polygon(points, [bg_color])

	# 2. Малювання контуру по зовнішній межі
	var closed_points := points.duplicate()
	closed_points.append(points[0]) # Замикаємо лінію
	draw_polyline(closed_points, border_color, border_width, true)
