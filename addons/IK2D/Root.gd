tool
extends "./Chain.gd"

func _get_configuration_warning():
	if(!find_node("IKSub-BasePos") && !find_node("IKEnd2D")):
		return "Can't find End or SubBase in Children"
	return ''