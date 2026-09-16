extends Control

@onready var monolith_bg: Control = $MonolithBackground
@onready var tab_container: Control = $ContentLayout/MiddleRow/Margin/TabButtons

var tabs: Array[Control] = []

func _ready() -> void:
	# Чекаємо один кадр, щоб контейнери встигли розрахувати свої розміри
	await get_tree().process_frame
	
	# Динамічно отримуємо всі таби з контейнера TabButtons
	for child in tab_container.get_children():
		if child is Control:
			tabs.append(child)
			
			# Якщо TabButton є кнопкой або має сигнал pressed
			if child.has_signal("pressed"):
				child.pressed.connect(_on_tab_pressed.bind(child))
			# Якщо TabButton — це кастомна підсцена, всередині якої є Button
			elif child.has_node("Button"):
				child.get_node("Button").pressed.connect(_on_tab_pressed.bind(child))

	# За замовчуванням робимо перший таб активним
	if tabs.size() > 0:
		_on_tab_pressed(tabs[0])

func _on_tab_pressed(clicked_tab: Control) -> void:
	# Передаємо активний таб у монолітний фон
	monolith_bg.active_tab = clicked_tab
	_update_tabs_visuals(clicked_tab)

func _update_tabs_visuals(active: Control) -> void:
	for tab in tabs:
		if tab == active:
			# Активний таб: прибираємо його власний фон/бордер (якщо є)
			tab.add_theme_stylebox_override("panel", StyleBoxEmpty.new())
		else:
			# Неактивний таб: тут можна задати стиль неактивного таба
			pass
