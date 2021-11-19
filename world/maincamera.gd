extends Camera2D

export(NodePath) var target

func _physics_process(delta:float) -> void:
	var target_object = get_node_or_null(target)
	if(target_object != null):
		position = lerp(position,target_object.position,0.1)
