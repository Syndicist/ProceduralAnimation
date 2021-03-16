tool
extends "./Chain.gd"

func _ready():
	type = Enums.JointType.ROOT;

func _get_configuration_warning():
	if(!find_end(self)):
		return "Can't find End or SubBase in Children"
	return ''
