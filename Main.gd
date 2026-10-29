extends Node2D

@onready var ui: GameUI = $GameUI
@onready var game_manager: GameManager = $GameManager
@onready var p1: PlayerController = $World/Player1
@onready var p2: PlayerController = $World/Player2


func _ready() -> void:
	pass	
	
	
	# UI에서 턴 실행을 요청하면 GameManager로 전달
	#ui.turn_requested.connect(game_manager.process_turn)	#시그널 연걸
	#
	## GameManager 연산 완료 시 UI 및 캐릭터 연출 업데이트
	#game_manager.turn_processed.connect(_on_turn_processed)

#func _on_turn_processed(data: Dictionary) -> void:
	#
#
	## 1. UI 업데이트
	#ui.display_result(data)
	#
	## 2. 캐릭터 애니메이션 연출
	#p1.play_action_anim(data.p1_act)
	#p2.play_action_anim(data.p2_act)
	#
	#if data.p1_dead: p1.play_dead_anim()
	#if data.p2_dead: p2.play_dead_anim()
	#
func _on_game_ui_charge_pressed(player_id: int) -> void:
	# GameManager 함수 호출
	game_manager.receive_player_action(game_manager.Action.CHARGE)
	print("기 충전 완료!",game_manager.p1_ki)
func _on_game_ui_guard_pressed(player_id: int) -> void:
	game_manager.receive_player_action(game_manager.Action.GUARD)
	print("방어")
func _on_game_ui_punch_pressed(player_id: int) -> void:
	game_manager.receive_player_action(game_manager.Action.PUNCH)
	print("주먹")
func _on_game_ui_pa_pressed(player_id: int) -> void:
	game_manager.receive_player_action(game_manager.Action.PA)
	print("파")
func _on_game_ui_restart_pressed(int: Variant) -> void:
	pass # Replace with function body.


func _on_game_ui_turn_requested(p1_act: GameManager.Action, p2_act: GameManager.Action) -> void:
	# 1. UI 업데이트
	game_manager.process_turn(p1_act, p2_act)


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
