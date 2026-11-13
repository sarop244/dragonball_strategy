class_name PlayerController
# 캐릭터 행동 그림
extends Node2D


@onready var sprites = {
	"idle": $idle,
	"charge": $charge,
	"guard": $guard,
	"hurt": $hurt,
	"die": $die,
	"pa": $pa,
	"punch": $punch,
	"ult" : $ult
}
# 그림 전환
func show_only(target_name: String) -> void:
	for key in sprites:
		var sprite_node = sprites[key]
		if sprite_node:
			sprite_node.visible = (key == target_name)
			
# 행동 그림
func play_action_anim(action: GameManager.Action) -> void:
	match action:
		GameManager.Action.CHARGE:
			show_only("charge")
		GameManager.Action.GUARD:
			show_only("guard")
		GameManager.Action.PUNCH:
			show_only("punch")
		GameManager.Action.PA:
			show_only("pa")
		GameManager.Action.KAMEHAMEHA:
			show_only("ult")
		_:
			show_only("idle")

# 사망 그림
func play_dead_anim() -> void:
	show_only("die") # 또는 "hurt"
