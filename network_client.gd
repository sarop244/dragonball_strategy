extends Node
class_name NetworkClient
signal connected_to_room(player_number: int, room_code: String)
signal turn_received(p1_action: int, p2_action: int)
signal connection_status(message: String)
var socket := WebSocketPeer.new()
var room_code := ""
var player_number := 0
var active := false
var pending_join: Dictionary = {}
func connect_to_room(server_url: String, code: String, create_room: bool) -> void:
	if server_url.strip_edges().is_empty() or server_url.contains("YOUR-SERVER"):
		connection_status.emit("공개 WebSocket 서버 주소를 설정해야 합니다 (wss://...).")
		return
	room_code = code.strip_edges().to_upper()
	if not create_room and room_code.is_empty():
		connection_status.emit("참가할 방 코드를 입력하세요.")
		return
	var err := socket.connect_to_url(server_url.strip_edges())
	if err != OK:
		connection_status.emit("서버 연결 실패: %s" % error_string(err))
		return
	active = true
	pending_join = {"type": "create" if create_room else "join", "room": room_code}
	set_process(true)
func _process(_delta: float) -> void:
	if not active: return
	socket.poll()
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		if not pending_join.is_empty():
			socket.send_text(JSON.stringify(pending_join))
			pending_join.clear()
		while socket.get_available_packet_count() > 0:
			var data = JSON.parse_string(socket.get_packet().get_string_from_utf8())
			if data is Dictionary: _handle_message(data)
	elif socket.get_ready_state() == WebSocketPeer.STATE_CLOSED:
		active = false
		connection_status.emit("서버 연결이 끊겼습니다.")
func submit_action(action: int) -> void:
	if active and socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		socket.send_text(JSON.stringify({"type":"action", "action":action}))
func _handle_message(data: Dictionary) -> void:
	match data.get("type", ""):
		"joined":
			player_number = int(data.get("player", 0))
			room_code = str(data.get("room", room_code))
			connected_to_room.emit(player_number, room_code)
			connection_status.emit("방 %s 연결 완료 · %dP" % [room_code, player_number])
		"turn": turn_received.emit(int(data.get("p1", 0)), int(data.get("p2", 0)))
		"error": connection_status.emit(str(data.get("message", "연결 오류")))
func close_connection() -> void:
	active = false
	if socket.get_ready_state() != WebSocketPeer.STATE_CLOSED: socket.close()
