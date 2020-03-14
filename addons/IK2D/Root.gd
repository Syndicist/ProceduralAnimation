tool
extends "./Chain.gd"

func _get_configuration_warning():
	if(!find_end(self)):
		return "Can't find End or SubBase in Children"
	return ''