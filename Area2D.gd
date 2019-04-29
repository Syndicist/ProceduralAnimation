extends Area2D

var mouse = false;

func _physics_process(delta):
	if(Input.is_action_pressed("click") && mouse):
		position = get_global_mouse_position();


func _on_Area2D_mouse_entered():
	mouse = true;



func _on_Area2D_mouse_exited():
	mouse = false;
