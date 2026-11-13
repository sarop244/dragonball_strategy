# 시작 메뉴와 온라인 방
extends CanvasLayer
signal mode_selected(is_multi: bool)
signal network_requested(server_url: String, room_code: String, create_room: bool)
@onready var lobby: VBoxContainer
@onready var server_input: LineEdit
@onready var room_input: LineEdit
@onready var status_label: Label
func _ready() -> void:
	_build_lobby()
# 온라인 방 입력 UI
func _build_lobby() -> void:
	var panel := PanelContainer.new()
	panel.name = "OnlineLobby"
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.position = Vector2(-230, -190)
	panel.size = Vector2(460, 380)
	add_child(panel)
	lobby = VBoxContainer.new()
	panel.add_child(lobby)
	var title := Label.new(); title.text = "온라인 대전"; title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER; lobby.add_child(title)
	var note := Label.new(); note.text = "서버 주소는 자동 입력돼 있어요. 방을 만들거나 코드를 입력해 참가하세요."; note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; lobby.add_child(note)
	# 기본 서버 주소
	server_input = LineEdit.new(); server_input.placeholder_text = "wss://서버주소"; server_input.text = "wss://dragonball-strategy.onrender.com/ws"; lobby.add_child(server_input)
	room_input = LineEdit.new(); room_input.placeholder_text = "방 코드 (참가할 때 입력)"; lobby.add_child(room_input)
	var host := Button.new(); host.text = "방 만들기"; host.pressed.connect(func(): network_requested.emit(server_input.text, room_input.text, true)); lobby.add_child(host)
	var join := Button.new(); join.text = "방 참가"; join.pressed.connect(func(): network_requested.emit(server_input.text, room_input.text, false)); lobby.add_child(join)
	status_label = Label.new(); status_label.text = ""; status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART; lobby.add_child(status_label)
	var back := Button.new(); back.text = "돌아가기"; back.pressed.connect(func(): panel.hide()); lobby.add_child(back)
	panel.hide()
# 로컬 대전 시작
func _on_single_btn_pressed() -> void:
	mode_selected.emit(false)
	queue_free()
# 온라인 방 열기
func _on_multi_btn_pressed() -> void:
	$OnlineLobby.show()
# 연결 상태 표시
func set_status(message: String) -> void:
	status_label.text = message
# 방 코드 표시
func set_room_code(code: String) -> void:
	room_input.text = code
