tool
extends Bone2D
class_name IKBone2D

export(float) var length := 16.0
export(NodePath) var child_bone_path
var child_bone
var child_prev_position

func _ready():
	if Engine.editor_hint or not Engine.editor_hint:
		if child_bone:
			child_prev_position = child_bone.position

func _process(_delta):
	if Engine.editor_hint or not Engine.editor_hint:
		if child_bone:
			length = global_position.distance_to(child_bone.global_position)
			default_length = global_position.distance_to(child_bone.global_position)
			child_prev_position = child_bone.position
