tool
extends IKBone2D
class_name IKRoot2D

export(NodePath) var end_bone_path
export(int) var root_idx
var end_bone
var ready := false

func _get_configuration_warning():
	if not end_bone_path:
		return "Can't find End"
	return ''

