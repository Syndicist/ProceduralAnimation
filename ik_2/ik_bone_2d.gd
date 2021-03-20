tool
extends Bone2D
class_name IKBone2D

export(int) var root_idx : int
export(NodePath) var IK_handler_path
export(float) var length := 16.0
export(NodePath) var child_bone_path
var child_bone
var child_prev_position
var ik_handler
export(bool) var constrained := false
export(float) var upper_constraint := 0.0
export(float) var lower_constraint := 0.0

func _ready():
	if Engine.editor_hint or not Engine.editor_hint:
		if child_bone:
			child_prev_position = child_bone.position

func _draw():
	if constrained:
		var line = Vector2(16,0)
		var tempx = line.x
		var tempy = line.y
		line.x = tempx * cos(upper_constraint - rotation) - tempy * sin(upper_constraint - rotation)
		line.y = tempx * sin(upper_constraint - rotation) + tempy * cos(upper_constraint - rotation)
		draw_line(Vector2(0,0), line, Color.red)
		
		line = Vector2(16,0)
		tempx = line.x
		tempy = line.y
		line.x = tempx * cos(lower_constraint - rotation) - tempy * sin(lower_constraint - rotation)
		line.y = tempx * sin(lower_constraint - rotation) + tempy * cos(lower_constraint - rotation)
		draw_line(Vector2(0,0), line, Color.blue)

func _process(_delta):
	if Engine.editor_hint:
		update()
	if Engine.editor_hint or not Engine.editor_hint and ik_handler:
		if child_bone:
			length = global_position.distance_to(child_bone.global_position)
			default_length = global_position.distance_to(child_bone.global_position)
