class_name GameManager
extends Node

# 행동 종류와 네트워크 번호
enum Action { NONE, CHARGE, PA, GUARD, PUNCH, KAMEHAMEHA }

# 온라인 모드 여부
var is_multiplayer: bool = false 

# 플레이어별 기와 피해
var p1_ki: int = 0
var p1_damage: int = 0
var p2_ki: int = 0
var p2_damage: int = 0

# 현재 입력 플레이어
var current_input_player: int = 1
var p1_action: Action = Action.NONE
var p2_action: Action = Action.NONE

# 게임 종료 상태
var is_game_over: bool = false

# 턴 결과 신호
signal turn_processed(result_data: Dictionary)
signal dead_restart()
# 턴 연산 함수
# 턴 계산
func process_turn(p1_act: Action, p2_act: Action) -> void:
	# 1. 자원 검증
	p1_act = validate_action(p1_act, p1_ki)
	p2_act = validate_action(p2_act, p2_ki)
	
	# 2. 기 소모/충전
	update_ki(1, p1_act)
	update_ki(2, p2_act)

	# 3. 사망 및 피해 판정
	var p1_dead: bool = check_death(p1_act, p2_act)
	var p2_dead: bool = check_death(p2_act, p1_act)

	if p2_act == Action.PUNCH and p1_act != Action.GUARD:	#펀치 누적
		p1_damage += 1
	if p1_act == Action.PUNCH and p2_act != Action.GUARD:
		p2_damage += 1
		
	if p1_damage == 4 and p2_damage ==4:			# 펀치 동타 사망
		p1_damage =0
		p2_damage =0
		
	if p1_damage >= 4: p1_dead = true				# 펀치 4회누적 사망
	if p2_damage >= 4: p2_dead = true
	
	if p1_dead or p2_dead:		# 죽었을경우 게임오버
		dead_restart.emit()
		is_game_over = true

	# 결과를 딕셔너리로 패킹하여 시그널로 전달
	var result = {
		"p1_act": p1_act, "p2_act": p2_act,
		"p1_ki": p1_ki, "p1_damage": p1_damage, "p1_dead": p1_dead,
		"p2_ki": p2_ki, "p2_damage": p2_damage, "p2_dead": p2_dead
	}
	
	turn_processed.emit(result)
	
# 로컬 입력과 턴 처리
func receive_player_action(action: Action) -> void:
	# 누적 피해가 4 이상이면(죽었으면) 입력 차단!
	if is_game_over:
		return
		
	if current_input_player == 1:
		p1_action = action
		print("1P 입력 완료: ", action)
		current_input_player = 2 # 다음은 2P 차례

	elif current_input_player == 2:
		p2_action = action
		print("2P 입력 완료: ", action)
		
		# 둘 다 입력이 끝났으므로 턴 연산 실행
		process_turn(p1_action, p2_action)
		
		# 초기화 및 1P 차례로 되돌리기
		current_input_player = 1
		p1_action = Action.NONE
		p2_action = Action.NONE

# 행동 유효성 검사
# 경기 상태 초기화
func reset_game() -> void:
	p1_ki = 0
	p1_damage = 0
	p2_ki = 0
	p2_damage = 0
	current_input_player = 1
	p1_action = Action.NONE
	p2_action = Action.NONE
	is_game_over = false
func validate_action(act: Action, ki: int) -> Action:
	if act == Action.KAMEHAMEHA and ki < 3 and ki >0:
		return Action.PA 
		
		# 파(1 필요)를 쓰는데 기가 1 미만이면 사용 불가 (NONE 처리)
	if act == Action.PA and ki < 1:
		return Action.NONE
	return act

# 기 충전과 소모
func update_ki(player: int, act: Action) -> void:
	var change = 0
	if act == Action.CHARGE: change = 1
	elif act == Action.PA: change = -1
	elif act == Action.KAMEHAMEHA: change = -3
	
	if player == 1: p1_ki += change
	else: p2_ki += change

# 사망 판정
func check_death(my_act: Action, opp_act: Action) -> bool:
	if opp_act == Action.PA and my_act == Action.PA: return false
	if opp_act == Action.KAMEHAMEHA and my_act == Action.KAMEHAMEHA: return false
	if opp_act == Action.KAMEHAMEHA: return true
	if opp_act == Action.PA and my_act != Action.GUARD: return true
	return false
