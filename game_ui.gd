class_name GameUI
extends CanvasLayer

#signal turn_requested(p1_act: GameManager.Action, p2_act: GameManager.Action)
signal charge_pressed()
signal guard_pressed()
signal punch_pressed()
signal pa_pressed()
signal restart_pressed()
signal ult_pressed()

var p1_selected: GameManager.Action = GameManager.Action.NONE
var p2_selected: GameManager.Action = GameManager.Action.NONE

@onready var status_label: Label = $StatusLabel
@onready var p1_ki_label: Label = $P1_Panel/KiLabel
@onready var p1_hp_label: Label = $P1_Panel/HpLabel
@onready var p2_ki_label: Label = $P2_Panel/KiLabel
@onready var p2_hp_label: Label = $P2_Panel/HpLabel


func _ready() -> void:
	#$Restart.pressed.connect(_on_execute_pressed)
	pass
	
# 버튼 클릭 시 호출
func select_p1_action(act: GameManager.Action) -> void:
	p1_selected = act
	update_status_text()

func select_p2_action(act: GameManager.Action) -> void:
	p2_selected = act
	update_status_text()



#func _on_execute_pressed() -> void:
	##if p1_selected == GameManager.Action.NONE or p2_selected == GameManager.Action.NONE:
		##status_label.text = "양쪽 다 행동을 선택해야 합니다!"
		##return
	#
	#turn_requested.emit(p1_selected, p2_selected)
	#p1_selected = GameManager.Action.NONE
	#p2_selected = GameManager.Action.NONE

func update_status_text() -> void:
	status_label.text = "1P: %s / 2P: %s 선택 중..." % [
		GameManager.Action.keys()[p1_selected], 
		GameManager.Action.keys()[p2_selected]
	]

func update_skill_buttons(ki: int) -> void:
	if ki >= 3:
		$P1_Panel/pa.visible = false   # 기가 3 이상이면 파 버튼 숨기기 (노드 이름이 다르면 수정하세요)
		$P1_Panel/ult.visible = true   # 울트라 버튼 보이기
	else:
		$P1_Panel/pa.visible = true    # 기가 3 미만이면 파 버튼 보이기
		$P1_Panel/ult.visible = false  # 울트라 버튼 숨기기
		
func display_result(data: Dictionary) -> void:
	p1_ki_label.text = "기: " + str(data.p1_ki)
	p1_hp_label.text = "누적피해: " + str(data.p1_damage) + "/4"
	p2_ki_label.text = "기: " + str(data.p2_ki)
	p2_hp_label.text = "누적피해: " + str(data.p2_damage) + "/4"
	
	update_skill_buttons(data.p1_ki)
	
	if data.p1_dead or data.p2_dead:
		$Restart.disabled = false
	if data.p1_dead and data.p2_dead:
		status_label.text = "💀 무승부!"
	elif data.p1_dead:
		status_label.text = "🎉 2P 승리!"
	elif data.p2_dead:
		status_label.text = "🎉 1P 승리!"
	else:
		status_label.text = "턴 완료!"

func _on_charge_pressed() -> void:		#차지버튼 눌렀을때
	charge_pressed.emit()
func _on_guard_pressed() -> void:
	guard_pressed.emit()
func _on_punch_pressed() -> void:
	punch_pressed.emit()
func _on_pa_pressed() -> void:
	pa_pressed.emit()
func _on_restart_pressed() -> void:
	restart_pressed.emit()
func _on_ult_pressed() -> void:
	ult_pressed.emit()
