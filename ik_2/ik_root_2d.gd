tool
extends IKBone2D
class_name IKRoot2D

export(NodePath) var end_bone_path
export(NodePath) var target_path
var end_bone
var centroid

func _get_configuration_warning():
	if not target_path:
		#ik_handler.IK_on = false
		return "Can't find Target"
	if not end_bone_path:
		return "Can't find End"
	return ''

