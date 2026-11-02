# StartMenu.gd
extends CanvasLayer

signal mode_selected(is_multi: bool)

func _on_single_btn_pressed() -> void:
	mode_selected.emit(false) # 1인용 선택
	queue_free() # 시작 메뉴 삭제

func _on_multi_btn_pressed() -> void:
	mode_selected.emit(true)  # 2인용 선택
	queue_free() # 시작 메뉴 삭제
