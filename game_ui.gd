class_name GameUI
extends CanvasLayer

signal turn_requested(p1_act: GameManager.Action, p2_act: GameManager.Action)
signal charge_pressed(player_id: int)
signal guard_pressed(player_id: int)
signal punch_pressed(player_id: int)
signal pa_pressed(player_id: int)
signal restart_pressed(int)

var p1_selected: GameManager.Action = GameManager.Action.NONE
var p2_selected: GameManager.Action = GameManager.Action.NONE

@onready var status_label: Label = $StatusLabel
@onready var p1_ki_label: Label = $P1_Panel/KiLabel
@onready var p1_hp_label: Label = $P1_Panel/HpLabel
@onready var p2_ki_label: Label = $P2_Panel/KiLabel
@onready var p2_hp_label: Label = $P2_Panel/HpLabel


func _ready() -> void:
	$Restart.pressed.connect(_on_execute_pressed)

# 버튼 클릭 시 호출
func select_p1_action(act: GameManager.Action) -> void:
	p1_selected = act
	update_status_text()

func select_p2_action(act: GameManager.Action) -> void:
	p2_selected = act
	update_status_text()

func _on_execute_pressed() -> void:
	if p1_selected == GameManager.Action.NONE or p2_selected == GameManager.Action.NONE:
		status_label.text = "양쪽 다 행동을 선택해야 합니다!"
		return
	
	turn_requested.emit(p1_selected, p2_selected)
	p1_selected = GameManager.Action.NONE
	p2_selected = GameManager.Action.NONE

func update_status_text() -> void:
	status_label.text = "1P: %s / 2P: %s 선택 중..." % [
		GameManager.Action.keys()[p1_selected], 
		GameManager.Action.keys()[p2_selected]
	]

func display_result(data: Dictionary) -> void:
	p1_ki_label.text = "기1: " + str(data.p1_ki)
	p1_hp_label.text = "누적피해: " + str(data.p1_damage) + "/4"
	p2_ki_label.text = "기2: " + str(data.p2_ki)
	p2_hp_label.text = "누적피해: " + str(data.p2_damage) + "/4"
	
	if data.p1_dead and data.p2_dead:
		status_label.text = "💀 무승부!"
	elif data.p1_dead:
		status_label.text = "🎉 2P 승리!"
	elif data.p2_dead:
		status_label.text = "🎉 1P 승리!"
	else:
		status_label.text = "턴 완료!"

func _on_charge_pressed() -> void:		#차지버튼 눌렀을때
	emit_signal("charge_pressed",1)		#시그널보내기 메인한테
func _on_guard_pressed() -> void:
	emit_signal("guard_pressed",1)
func _on_punch_pressed() -> void:
	emit_signal("punch_pressed",1)
func _on_pa_pressed() -> void:
	emit_signal("pa_pressed",1)

func _on_restart_pressed() -> void:
	emit_signal("restart_pressed",1)
