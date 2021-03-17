tool
extends Bone2D
class_name IKBone2D

export(NodePath) var IK_handler_path
export(float) var length := 16.0
export(NodePath) var child_bone_path
var child_bone
var child_prev_position
var ik_handler

func _ready():
	if Engine.editor_hint or not Engine.editor_hint:
		validate_needed_nodes()
		if child_bone:
			child_prev_position = child_bone.position
	if Engine.editor_hint:
		if ik_handler:
			if ik_handler.root_bone != self:
				ik_handler = null
				IK_handler_path = null

func _process(_delta):
	if Engine.editor_hint or not Engine.editor_hint:
		if child_bone:
			length = global_position.distance_to(child_bone.global_position)
			default_length = global_position.distance_to(child_bone.global_position)
			child_prev_position = child_bone.position
		if child_bone is IKEnd2D:
			look_at(ik_handler.target.global_position)

func validate_needed_nodes():
	if not ik_handler:
		ik_handler = get_node(IK_handler_path)
