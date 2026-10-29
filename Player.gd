class_name PlayerController
extends Node2D


@onready var sprites = {
	"idle": $idle,
	"charge": $charge,
	"guard": $guard,
	"hurt": $hurt,
	"die": $die,
	"pa": $pa,
	"punch": $punch
}
func show_only(target_name: String) -> void:		# 버튼누를때 사진바뀌게 이외에는 off
	for key in sprites:
		var sprite_node = sprites[key]
		if sprite_node:
			sprite_node.visible = (key == target_name)
			
func play_action_anim(action: GameManager.Action) -> void:
	match action:
		GameManager.Action.CHARGE:
			show_only("charge")
		GameManager.Action.GUARD:
			show_only("guard")
		GameManager.Action.PUNCH:
			show_only("punch")
		GameManager.Action.PA, GameManager.Action.KAMEHAMEHA:
			show_only("pa")
		_:
			show_only("idle")

func play_dead_anim() -> void:
	show_only("die") # 또는 "hurt"
