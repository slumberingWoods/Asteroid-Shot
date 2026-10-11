extends Control

@onready var main_menu: Control = $MainMenu
@onready var stage_buttons: Control = $MainMenu/ColorRect/MarginContainer/GridContainer
@onready var return_button: Button = $Button


func _ready():
	var index := 0
	for child in stage_buttons.get_children():
		if child is Button:
			child.pressed.connect(_on_stage_button_pressed.bind(index))
			index += 1

	return_button.pressed.connect(_on_return_pressed)
	StageManager.stage_changed.connect(_on_stage_changed)

	_show_menu()


func _on_stage_button_pressed(index: int):
	StageManager.load_stage(index)


func _on_stage_changed(_stage: Node):
	_show_game()


func _on_return_pressed():
	if StageManager.has_method("unload_stage"):
		StageManager.unload_stage()
	_show_menu()


func _show_menu():
	main_menu.show()
	return_button.hide()


func _show_game():
	main_menu.hide()
	return_button.show()