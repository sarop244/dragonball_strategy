extends Node2D

@onready var ui: GameUI = $GameUI
@onready var game_manager: GameManager = $GameManager
@onready var p1: PlayerController = $World/Player1
@onready var p2: PlayerController = $World/Player2


func _ready() -> void:
	# 시작 메뉴 생성 및 모드 선택 대기
	var start_menu = preload("res://StartMenu.tscn").instantiate()
	#add_child(start_menu)
	#start_menu.mode_selected.connect(_on_start_menu_mode_selected)
	
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
	#if game_manager.p1_ki >=3 or game_manager.p2_ki >=3:			#기 3개모였을떄 에네르기파 사용
		#game_manager.receive_player_action(game_manager.Action.KAMEHAMEHA)
	if game_manager.p1_ki >0 or game_manager.p2_ki > 0 :
		game_manager.receive_player_action(game_manager.Action.PA)
		print("파")
	else:
		ui.status_label.text ="'기'가 부족합니다!! 다른행동을 해주세요"
		return
func _on_game_ui_ult_pressed() -> void:
	game_manager.receive_player_action(game_manager.Action.KAMEHAMEHA)

func _on_game_ui_restart_pressed() -> void:
	get_tree().reload_current_scene()

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

func _on_start_menu_mode_selected(is_multi: bool) -> void:
	game_manager.is_multiplayer = is_multi
	if is_multi:
		print("2인용 멀티모드 시작 (네트워크 대기)")
		# 추후 네트워크 서버/클라이언트 연결 로직이 여기에 들어갑니다.
	else:
		print("1인용 한 컴퓨터 대전 시작")
