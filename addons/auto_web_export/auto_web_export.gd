@tool
extends EditorPlugin

# Web 내보내기 설정
const EXPORT_PRESET := "Web"
const EXPORT_FILE := "res://index.html"

var export_timer: Timer
var export_process_id := -1
var export_waiting := false

# 저장 후 잠깐 기다렸다가 내보내기
func _enter_tree() -> void:
	resource_saved.connect(_on_resource_saved)
	export_timer = Timer.new()
	export_timer.one_shot = true
	export_timer.wait_time = 1.5
	export_timer.timeout.connect(_export_web)
	add_child(export_timer)
	set_process(true)
	print("웹 자동 내보내기 켜짐")

# 플러그인 종료
func _exit_tree() -> void:
	if resource_saved.is_connected(_on_resource_saved):
		resource_saved.disconnect(_on_resource_saved)

# 파일 저장 신호
func _on_resource_saved(_resource: Resource) -> void:
	export_timer.start()
	print("저장 감지: 웹 내보내기 예약")

# 내보내기 중 저장 처리
func _process(_delta: float) -> void:
	if export_process_id != -1 and not OS.is_process_running(export_process_id):
		export_process_id = -1
		if export_waiting:
			export_waiting = false
			_export_web()

# Web 프리셋으로 다시 내보내기
func _export_web() -> void:
	if export_process_id != -1 and OS.is_process_running(export_process_id):
		export_waiting = true
		return

	var project_path := ProjectSettings.globalize_path("res://")
	var output_path := ProjectSettings.globalize_path(EXPORT_FILE)
	var arguments := PackedStringArray([
		"--headless",
		"--path", project_path,
		"--export-release", EXPORT_PRESET, output_path
	])
	export_process_id = OS.create_process(OS.get_executable_path(), arguments)
	if export_process_id == -1:
		push_error("웹 내보내기를 시작하지 못했습니다. Godot 실행 파일을 확인하세요.")
	else:
		print("웹 내보내기 시작: ", output_path)
