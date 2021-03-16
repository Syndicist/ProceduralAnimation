tool
extends IKBone2D
class_name IKRoot2D

export(NodePath) var IK_handler_path
export(NodePath) var end_bone_path
var end_bone
var ik_handler
var ready := false

func _ready():
	if Engine.editor_hint or not Engine.editor_hint:
		validate_needed_nodes()
	if Engine.editor_hint:
		if ik_handler:
			if ik_handler.root_bone != self:
				ik_handler = null
				IK_handler_path = null
	._ready()

func _get_configuration_warning():
	if not end_bone_path:
		return "Can't find End"
	return ''

func validate_needed_nodes():
	if not ik_handler:
		ik_handler = get_node(IK_handler_path)
