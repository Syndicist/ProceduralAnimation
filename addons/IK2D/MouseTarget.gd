extends Area2D

var mouse = false;

func _ready():
	connect("mouse_entered", self, "_on_Area2D_mouse_entered");
	connect("mouse_exited", self, "_on_Area2D_mouse_exited");

func _process(delta):
	if(Input.is_action_pressed("click") && mouse):
		global_position = get_global_mouse_position();
	elif(Input.is_action_just_released("click")):
		mouse = false;

func _on_Area2D_mouse_entered():
	mouse = true;

func _on_Area2D_mouse_exited():
	if(!Input.is_action_pressed("click")):
		mouse = false;