extends Node2D

@onready var ui: GameUI = $GameUI
@onready var game_manager: GameManager = $GameManager
@onready var p1: PlayerController = $World/Player1
@onready var p2: PlayerController = $World/Player2


func _ready() -> void:
	pass	
	
func _on_game_ui_charge_pressed() -> void:
	# GameManager 함수 호출
	game_manager.receive_player_action(game_manager.Action.CHARGE)
	print("기 충전 완료!",game_manager.p1_ki)
func _on_game_ui_guard_pressed() -> void:
	game_manager.receive_player_action(game_manager.Action.GUARD)
	print("방어")
func _on_game_ui_punch_pressed() -> void:
	game_manager.receive_player_action(game_manager.Action.PUNCH)
	print("주먹")
func _on_game_ui_pa_pressed() -> void:
	game_manager.receive_player_action(game_manager.Action.PA)
	print("파")
func _on_game_ui_restart_pressed() -> void:
	get_tree().reload_current_scene()


#func _on_game_ui_turn_requested(p1_act: GameManager.Action, p2_act: GameManager.Action) -> void:
	## 1. UI 업데이트
	#print("이거나오긴해?")
	#game_manager.process_turn(p1_act, p2_act)


func _on_game_manager_turn_processed(result_data: Dictionary) -> void:
	# 1. UI 업데이트
	ui.display_result(result_data)
	ui.display_result(result_data)
	
	# 2. 캐릭터 애니메이션 연출 (실제 행동 데이터 사용)
	p1.play_action_anim(result_data.p1_act)
	p2.play_action_anim(result_data.p2_act)
	
	# 3. 사망 판정 시 죽는 애니메이션 재생
	if result_data.p1_dead: 
		p1.play_dead_anim()
	if result_data.p2_dead: 
		p2.play_dead_anim()
		
		
