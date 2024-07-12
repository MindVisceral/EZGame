extends Control

var start_menu
var level_select_menu
var options_menu

@export (String, FILE) var testing_area_scene = "res://Resources/Levels/Testing_Area.tscn"
@export (String, FILE) var space_level_scene = "res://assets/Space_Level_Objects/Space_Level.tscn"
@export (String, FILE) var ruins_level_scene = "res://assets/Ruin_Level_Objects/Ruins_Level.tscn"

func _ready():
	start_menu = $Start_Menu
	level_select_menu = $Level_Select_Menu
	options_menu = $Options_Menu
	
	$Start_Menu/Button_Start.connect("pressed", Callable(self, "start_menu_button_pressed").bind("start"))
	$Start_Menu/Button_Open_Godot.connect("pressed", Callable(self, "start_menu_button_pressed").bind("open_godot"))
	$Start_Menu/Button_Options.connect("pressed", Callable(self, "start_menu_button_pressed").bind("options"))
	$Start_Menu/Button_Quit.connect("pressed", Callable(self, "start_menu_button_pressed").bind("quit"))
	
	$Level_Select_Menu/Button_Back.connect("pressed", Callable(self, "level_select_menu_button_pressed").bind("back"))
	$Level_Select_Menu/Button_Level_Testing_Area.connect("pressed", Callable(self, "level_select_menu_button_pressed").bind("testing_scene"))
	$Level_Select_Menu/Button_Level_Space.connect("pressed", Callable(self, "level_select_menu_button_pressed").bind("space_level"))
	$Level_Select_Menu/Button_Level_Ruins.connect("pressed", Callable(self, "level_select_menu_button_pressed").bind("ruins_level"))
	
	$Options_Menu/Button_Back.connect("pressed", Callable(self, "options_menu_button_pressed").bind("back"))
	$Options_Menu/Button_Fullscreen.connect("pressed", Callable(self, "options_menu_button_pressed").bind("fullscreen"))
	$Options_Menu/Check_Button_VSync.connect("pressed", Callable(self, "options_menu_button_pressed").bind("vsync"))
	$Options_Menu/Check_Button_Debug.connect("pressed", Callable(self, "options_menu_button_pressed").bind("debug"))
	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	var globals = get_node("/root/Globals")
	$Options_Menu/HSlider_Mouse_Sensitivity.value = globals.mouse_sensitivity
	$Options_Menu/HSlider_Joypad_Sensitivity.value = globals.joypad_sensitivity


func start_menu_button_pressed(button_name):
	if button_name == "start":
		level_select_menu.visible = true
		start_menu.visible = false
	elif button_name == "open_godot":
		OS.shell_open("https://godotengine.org/")
	elif button_name == "options":
		options_menu.visible = true
		start_menu.visible = false
	elif button_name == "quit":
		get_tree().quit()


func level_select_menu_button_pressed(button_name):
	if button_name == "back":
		start_menu.visible = true
		level_select_menu.visible = false
	elif button_name == "testing_scene":
		set_mouse_and_joypad_sensitivity()
		get_node("/root/Globals").load_new_scene(testing_area_scene)
	elif button_name == "space_level":
		set_mouse_and_joypad_sensitivity()
		get_node("/root/Globals").load_new_scene(space_level_scene)
	elif button_name == "ruins_level":
		set_mouse_and_joypad_sensitivity()
		get_node("/root/Globals").load_new_scene(ruins_level_scene)


func options_menu_button_pressed(button_name):
	if button_name == "back":
		start_menu.visible = true
		options_menu.visible = false
	elif button_name == "fullscreen":
		get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (!((get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN) or (get_window().mode == Window.MODE_FULLSCREEN))) else Window.MODE_WINDOWED
	elif button_name == "vsync":
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if ($Options_Menu/Check_Button_VSync.pressed) else DisplayServer.VSYNC_DISABLED)
	elif button_name == "debug":
		get_node("/root/Globals").set_debug_display($Options_Menu/Check_Button_Debug.pressed)


func set_mouse_and_joypad_sensitivity():
	var globals = get_node("/root/Globals")
	globals.mouse_sensitivity = $Options_Menu/HSlider_Mouse_Sensitivity.value
	globals.joypad_sensitivity = $Options_Menu/HSlider_Joypad_Sensitivity.value
