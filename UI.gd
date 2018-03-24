extends Node

func _ready():

	var btn_commander = get_node("pickCounselor/VBoxContainer/btn_commander")
	var btn_carpenter = get_node("pickCounselor/VBoxContainer/btn_carpenter")
	var btn_wizard = get_node("pickCounselor/VBoxContainer/btn_wizard")

	btn_commander.connect("pressed",get_node("/root/Game"),"_on_btn_commander_pressed")
	btn_carpenter.connect("pressed",get_node("/root/Game"),"_on_btn_carpenter_pressed")
	btn_wizard.connect("pressed",get_node("/root/Game"),"_on_btn_wizard_pressed")
	get_node("pickCounselor").hide()
	get_node("chooseCards").hide()
	
	var btn_action = get_node("chooseCards/VBoxContainer/counselor1/btn_action1")
	btn_action.connect("pressed", get_node("/root/Game"),"_on_btn_action_pressed")



func do_show_popup_counselor(i,name):
	
	print("UI: do_show_popup_counselor, by the " + name)
	get_node("pickCounselor/VBoxContainer/title").text = "The " + name + " summons:"
	get_node("pickCounselor/VBoxContainer/id").text = str(i)
	get_node("pickCounselor").show()
	 
func do_show_cards(regnants,counselors):
	var counselors_id = [] 
	var popup = get_node("pickCounselor/VBoxContainer")
	print("UI: do_show_cards, counselor")
	for i in range(len(regnants)):
		var counselor_id = regnants[i].summons
		var counselor = counselors[counselor_id]
		counselors_id.append(counselors_id)
		print(counselor.name + ": Please, " + regnants[i].name + " I suggest you one of this actions")
	get_node("chooseCards").show()
	print(counselors_id)
	
func update_ui(this_round,this_turn):
	var string = this_turn + " turn: #" + str(this_round)
	print("UI: printed ->" + string) 
	get_node("turn_label").text = string 