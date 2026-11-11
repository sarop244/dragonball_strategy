extends Node2D
@onready var ui: GameUI = $GameUI
@onready var game_manager: GameManager = $GameManager
@onready var p1: PlayerController = $World/Player1
@onready var p2: PlayerController = $World/Player2
@onready var start_menu = $StartMenu
var network_client: NetworkClient
var online_mode := false
var my_player_number := 0
func _ready() -> void:
	ui.hide()
	network_client = preload("res://network_client.gd").new()
	network_client.name = "NetworkClient"
	add_child(network_client)
	network_client.connected_to_room.connect(_on_network_connected)
	network_client.room_ready.connect(_on_network_room_ready)
	network_client.turn_received.connect(_on_network_turn)
	network_client.connection_status.connect(_on_network_status)
	ui.exit_pressed.connect(_on_game_ui_exit_pressed)
	start_menu.network_requested.connect(_on_network_requested)
func _set_action_buttons_enabled(enabled: bool) -> void:
	for button_path in ["P1_Panel/charge", "P1_Panel/guard", "P1_Panel/punch", "P1_Panel/pa", "P1_Panel/ult"]:
		var button := $GameUI.get_node(button_path) as Button
		button.disabled = not enabled
func _submit_action(action: GameManager.Action) -> void:
	if game_manager.is_game_over: return
	if online_mode:
		if not network_client.opponent_ready:
			ui.status_label.text = "상대가 방에 들어올 때까지 기다려 주세요."
			return
		if my_player_number == 0:
			ui.status_label.text = "먼저 방에 연결하세요."
			return
		if network_client.submit_action(action):
			_set_action_buttons_enabled(false)
			ui.status_label.text = "행동을 보냈습니다. 상대의 선택을 기다리는 중..."
	else:
		game_manager.receive_player_action(action)
func _on_game_ui_charge_pressed() -> void:
	_submit_action(GameManager.Action.CHARGE)
func _on_game_ui_guard_pressed() -> void:
	_submit_action(GameManager.Action.GUARD)
func _on_game_ui_punch_pressed() -> void:
	_submit_action(GameManager.Action.PUNCH)
func _on_game_ui_pa_pressed() -> void:
	var ki := game_manager.p1_ki if (not online_mode or my_player_number == 1) else game_manager.p2_ki
	if ki > 0: _submit_action(GameManager.Action.PA)
	else: ui.status_label.text = "'기'가 부족합니다! 다른 행동을 선택하세요."
func _on_game_ui_ult_pressed() -> void:
	_submit_action(GameManager.Action.KAMEHAMEHA)
func _on_game_ui_exit_pressed() -> void:
	if online_mode: network_client.close_connection()
	get_tree().reload_current_scene()
func _on_game_ui_restart_pressed() -> void:
	if online_mode: network_client.close_connection()
	get_tree().reload_current_scene()
func _on_game_manager_turn_processed(result_data: Dictionary) -> void:
	var view_data := result_data.duplicate()
	if online_mode and my_player_number == 2:
		for pair in [["p1_ki", "p2_ki"], ["p1_damage", "p2_damage"], ["p1_dead", "p2_dead"], ["p1_act", "p2_act"]]:
			var temp = view_data[pair[0]]
			view_data[pair[0]] = view_data[pair[1]]
			view_data[pair[1]] = temp
	if online_mode:
		view_data["p1_name"] = "내"
		view_data["p2_name"] = "상대"
	ui.display_result(view_data)
	p1.play_action_anim(result_data.p1_act)
	p2.play_action_anim(result_data.p2_act)
	if result_data.p1_dead: p1.play_dead_anim()
	if result_data.p2_dead: p2.play_dead_anim()
	if online_mode and not game_manager.is_game_over:
		_set_action_buttons_enabled(network_client.opponent_ready)
func _on_start_menu_mode_selected(is_multi: bool) -> void:
	game_manager.is_multiplayer = is_multi
	if not is_multi:
		online_mode = false
		ui.show()
func _on_network_requested(server_url: String, room_code: String, create_room: bool) -> void:
	online_mode = true
	network_client.connect_to_room(server_url, room_code, create_room)
func _on_network_connected(player_number: int, room_code: String) -> void:
	my_player_number = player_number
	start_menu.set_room_code(room_code)
	start_menu.hide()
	ui.show()
	$GameUI/P2_Panel.visible = true
	$GameUI/P1_Panel/KiLabel.text = "내 기"
	$GameUI/P1_Panel/HpLabel.text = "내 피해"
	$GameUI/P2_Panel/KiLabel.text = "상대 기"
	$GameUI/P2_Panel/HpLabel.text = "상대 피해"
	_set_action_buttons_enabled(network_client.opponent_ready)
	if network_client.opponent_ready:
		ui.status_label.text = "방 %s · 상대가 들어왔습니다. 행동을 선택하세요." % room_code
	else:
		ui.status_label.text = "방 코드: %s · 상대가 들어올 때까지 기다려 주세요." % room_code
func _on_network_room_ready() -> void:
	_set_action_buttons_enabled(true)
	ui.status_label.text = "상대가 참가했습니다. 행동을 선택하세요."
func _on_network_turn(p1_action: int, p2_action: int) -> void:
	game_manager.process_turn(p1_action, p2_action)
func _on_network_status(message: String) -> void:
	if message.contains("상대 연결이 끊겼습니다"):
		_set_action_buttons_enabled(false)
	if is_instance_valid(start_menu) and start_menu.visible:
		start_menu.set_status(message)
	elif is_instance_valid(ui):
		ui.status_label.text = message

