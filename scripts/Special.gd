extends Sprite

var disabled: bool = true

func _ready():
	get_node("AnimationPlayer").play("Spawn")

func _on_DespawnWarningTimer_timeout():
	get_node("AnimationPlayer").play("DespawnWarning")

func _on_DespawnTimer_timeout():
	get_node("AnimationPlayer").play("Despawn")

func set_disabled(value):
	disabled = value
	visible = !disabled

func is_disabled():
	return disabled