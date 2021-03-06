extends Node

const NUM_REGNANTS = 2
const NUM_COUNSELORS = 3
const MAX_ROUNDS = 8
const MAX_CARDS =3
const ROUND_QUEEN_DIED = 5


enum enum_regnant   {KING , QUEEN}
enum enum_counselor {COMMANDER , CARPENTER, WIZARD}
enum enum_turn      {AI, PLAYER}
enum enum_moods     {HAPPY, QUIET, SAD, ANGRY}

# mapping enum to string
var regnant_dict	= {KING: "King" , QUEEN: "Queen"}
var counselor_dict 	= {COMMANDER : "Commander" , CARPENTER : "Carpenter", WIZARD: "Wizard"}
var turn_dict 		= {AI: "Enemy", PLAYER:"Player"}
var moods_dict 		= {HAPPY: "Happy", QUIET: "Quiet", SAD = "Sad", ANGRY = "Angry"}
var cards_dict = {COMMANDER: "res://assets/cards/commander_card_front.png", CARPENTER: "res://assets/cards/carpenter_card_front.png", WIZARD:"res://assets/cards/wizard_card_front.png"}
 
enum enum_player_state {SETUP,AI_ATTACK, AI_SPAWN, AI_MOVE, AI_END_TURN, P_BEGIN, P_SUMMON_C1,P_SUMMON_C2, P_PICKED_C1,P_PICKED_C2, P_FLIP_C,P_EXEC_C1,P_EXEC_C1_COMPLETED,P_EXEC_C2,P_END_TURN,P_END_GAME }

var num_counselors_dead = 0

var regnants_alive
 
var curr_round
var curr_turn
var curr_regnant
var game_state
var game_finished = false

var timer 

var regnants
var counselors

class Counselor:
	var name
	var id
	var summoned
	var alive
	var mood
	var cards = []
	var deck

	const MAX_CARDS = 3
	
	func _init(n, id, cards_dict):
		var Card = preload("res://Card.gd").new().Card
		var Deck = preload("res://Deck.gd").new().Deck
		name = n
		self.id = id
		summoned = false
		alive = true
		mood = HAPPY

		self.deck = Deck.new(name)


class Regnant:
	var name
	var id
	var alive
	var summons
	var hand

	func _init(n,id):
		name = n
		self.id = id
		alive = true
		
		
func _ready():
	
	timer = get_node("Timer");
	timer.connect("timeout", self, "_on_Timer_timeout")
	timer.set_wait_time( 1 )
	
	setup_game()


func _on_ok_pressed():
	print("game: button ok pressed")
	if game_state == SETUP:
		print("start timer")
		timer.start()
	elif game_state == P_SUMMON_C1 or game_state == P_SUMMON_C2:
		$UI.enable_counsellors()
	elif game_state == P_END_TURN and curr_round == ROUND_QUEEN_DIED:
		turn_AI()

	
func _on_Timer_timeout():
	print("time timeout")
	if game_state == SETUP:
		timer.stop()
		turn_AI();

	
func setup_game():
	print("Game: Setup")
	
	regnants_alive = 2
	curr_round = 0
	curr_turn = AI
	curr_regnant = KING
	game_state = SETUP
	regnants = []
	counselors = []

	game_state = SETUP
	for i in range(NUM_REGNANTS):
		regnants.append(Regnant.new(regnant_dict[i], i))
	for i in range(NUM_COUNSELORS):
		counselors.append(Counselor.new(counselor_dict[i], i, cards_dict))
	
	var text = "Help the King and the Queen survive the Siege \n"
	text += "until their faraway army comes back at turn " + str(MAX_ROUNDS+1) + ".\n"
	text += "The two regnants command three counselors: the Carpenter,\n"
	text += "the Commander, and the Wizard, that give you options\n"
	text += "to fight back the attackers in the form of cards.\n"
	text += "Each regnant is limited to summon a single counselor \n"
	text += "per turn and play a single card, so you have to choose wisely.\n"
	text += "Turn after turn, your options become fewer and fewer as \n"
	text += "the attackers damage your walls and buildings..."
	
	$UI.update_message(text)
	$UI.show_message(true);

func player_win():
	
	game_state = P_END_GAME
	
	var text = ' YOU WIN! The Castle has survived'
	print(text)
	$UI.update_message(text)
	$UI.show_message(false);
	
	
	$UI.disable_all_cards(regnants[KING])
	$UI.disable_all_cards(regnants[QUEEN])
	
	$UI.disable_counsellors()



func turn_AI():
	# turn AI:
	# 1. attack
	# 2. spawn
	# 3. everybody moves
	if !game_finished:
		game_state = AI_ATTACK
		$UI.hide_message()
		
		curr_round +=1
		curr_turn = turn_dict[AI]
		$UI.update_ui(curr_round,curr_turn)
		$UI.hide_all_cards()
		$UI.disable_counsellors()
		print("Game: Round " + str(curr_round) + ", Turn AI")
				
		attack()
	

func attack():
	if !game_finished:
		print("Game: do_attack")
		game_state = AI_ATTACK
		$Battlefield.do_attack()
	
func spawn():
	if !game_finished:
		print("Game: do_spawn")
		game_state = AI_SPAWN
		$Battlefield.do_spawn()
	
func move():
	if !game_finished:
		print("Game: do_move")
		game_state = AI_MOVE
		$Battlefield.do_move()

# from signal attack_done
func _on_attack_done():
	spawn()

# from signal spawn_done
func _on_spawn_done():
	move()

# from signal move_done
func _on_move_done():
	if !game_finished:
		turn_player()
	
"""
# turn PLAYER:
#phase 1
#summon counselors

#phase 2
#show cards

#phase 3
#pick cards
#select target
#execute actions
"""

func turn_player():
	#Change state
	if curr_round == MAX_ROUNDS:
		player_win()
		return
	
	game_state = P_BEGIN
	curr_turn = turn_dict[PLAYER]
	#print log info
	print("Game: Round " + str(curr_round) + ", Turn Player")
	#clean temporary variables
	 
	curr_regnant = KING;
	#update ui
	$UI.update_ui(curr_round,curr_turn)
	$UI.enable_counsellors()
	 

	#next action
	summon_counselor(curr_regnant)
	
func summon_counselor(id):
	#Change state
	if game_state == P_BEGIN:
		if regnants_alive == 2:
			game_state = P_SUMMON_C1
		else:
			game_state = P_SUMMON_C2
	if game_state == P_PICKED_C1:
		game_state = P_SUMMON_C2

	#print log info
	print("Summon a counselor")
	# update ui
	var regnant = regnants[id]
	$UI.do_show_popup_counselor(id,regnant.name)

func _on_btn_commander_pressed():
	picked_counselor(COMMANDER)
	
func _on_btn_carpenter_pressed():
	picked_counselor(CARPENTER)
	 
func _on_btn_wizard_pressed():
	picked_counselor(WIZARD)

func picked_counselor(counselor):
	#Change state
	if game_state == P_SUMMON_C1:
		if regnants_alive == 2:
			game_state = P_PICKED_C1
		else:
			game_state = P_PICKED_C2
	elif game_state == P_SUMMON_C2:
			game_state = P_PICKED_C2



	#Print log info
	print("GAME: The " + regnant_dict[curr_regnant] + " summons the " + counselor_dict[counselor])


	$UI.hide_message()

	#A Regnant picked a counselor. Show its cards
	regnants[curr_regnant].summons = counselor
	counselors[counselor].summoned = true

	# assign to the regnant the hand
	regnants[curr_regnant].hand = counselors[counselor].deck.draw(MAX_CARDS)
	show_cards(regnants[curr_regnant])

	if game_state == P_PICKED_C1 and regnants_alive == 2:
		curr_regnant = QUEEN
		summon_counselor(curr_regnant)

	# show and choose cards
	if game_state == P_PICKED_C2:
		$UI.disable_counsellors()
		for regnant in regnants:
			flip_cards(regnant)
		 



func show_cards(regnant):
	$UI.do_show_cards(regnant)

func get_cards(counselor):
	return counselor.cards

func flip_cards(regnant):
	print("GAME: flip the cards")

	game_state = P_FLIP_C
	$UI.disable_counsellors()
	
	$UI.do_flip_cards(regnant)
	
func player_end_turn():

	$UI.disable_all_cards(regnants[curr_regnant])	
			
	game_state = P_END_TURN
	
	if curr_round == ROUND_QUEEN_DIED and regnants_alive == NUM_REGNANTS:
		player_queen_died("The Queen has been poisoned. God save the King!")
	else:
		turn_AI()

func player_execute_cards(regnant_id, card_id):

# TODO: this is hard_coded
	if game_state == P_FLIP_C:
		if regnants_alive == 2:
			game_state = P_EXEC_C1
			curr_regnant = KING
		else:
			curr_regnant = QUEEN
			game_state = P_EXEC_C2
	else:
		if game_state == P_EXEC_C1_COMPLETED:
			curr_regnant = QUEEN
			game_state = P_EXEC_C2

	#DO some stuff
	#TODO here I choose hardcoded the card of the counselor. change it
	$Battlefield.set_cursor_shape(regnants[regnant_id].hand[card_id])
	$UI.disable_all_cards(regnants[regnant_id])	
			

	
# Player turn ATTACK
func _on_card_pressed(regnant_id, card_id):
	player_execute_cards(regnant_id, card_id)
	
func _on_btn_attackcommander_pressed():
	player_execute_cards(COMMANDER)

func _on_btn_attackcarpenter_pressed():
	player_execute_cards(CARPENTER)
	
func _on_btn_attackwizard_pressed():
	player_execute_cards(WIZARD)

# on buildings damaged and destroyed
func on_castle_severely_hit():
	print('The Castle has been severely hit -- maybe if there are two regnants one of them should die')
	
	if(regnants[QUEEN].alive):
		player_queen_died("The castle has been severely hit. The Queen died in the fight!")
	
func player_queen_died(text):
	
	regnants_alive -= 1
	regnants[QUEEN].alive = false
	$UI.update_message(text)
	$UI.show_message(true);
	$UI.disable_texture_regnant(QUEEN)
	
func on_castle_destroyed():
	game_state = P_END_GAME
	game_finished = true
	player_game_over('GAME OVER: \nThe Castle has been destroyed')
	
	
func player_game_over(text):
	print(text)	
	game_finished = true
	game_state = P_END_GAME
	$UI.disable_all_cards(regnants[KING])
	$UI.disable_all_cards(regnants[QUEEN])
	
	$UI.disable_counsellors()
	$UI.update_message(text)
	$UI.show_message(false);
	 

func restart_game():
	get_tree().reload_current_scene()
	 
	
	
func on_building_destroyed(counselor_id):
	
	if game_state != P_END_GAME:
		var text
		if counselor_id == enum_counselor.COMMANDER:
			text = 'The Commander has been killed'
		elif counselor_id == enum_counselor.CARPENTER:
			text = 'The Carpenter has been killed'
		elif counselor_id == enum_counselor.WIZARD:
			text = 'The Wizard has been killed'
	
		print(text)
		$UI.update_message(text)
		$UI.show_message(true);
			
		num_counselors_dead += 1	
		counselors[counselor_id].alive = false	
		$UI.disable_counselor(counselor_id)
	
		if num_counselors_dead == NUM_COUNSELORS:
			game_finished
			player_game_over("GAME OVER: \nAll counselers are dead!")
		
		
		