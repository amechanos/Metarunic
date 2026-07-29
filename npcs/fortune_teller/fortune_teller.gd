extends Node
class_name fortune_teller

var upgrade_req = 5

var chat = [
	{"text": "Would you like me to read your fortune?", "choices": {"Yes": 1, "Upgrade Memory": 2, "No": 5}},
	{"text": "Greatness is upon you.", "choices": {"Okay.": 0}},
	{"text": "You will need at least %d shards. Are you sure?" % upgrade_req, "choices": {"Yes": check_upgrade, "No": 0}},
	{"text": "Your memory has been strengthened! You can now recall %d seconds." % Global.fade_duration, "choices": {"Okay.": 0}},
	{"text": "You do not have enough shards.", "choices": {"Okay.": 0}},
	{"text": "Salutations traveller!", "choices": {}},
	{"text": "Your memory seems to transcend even of mine...I can't seem to upgrade it any further I'm afraid.", "choices": {"Okay.": 0}},
]

# --- Custom NPC Functions ---

func check_upgrade() -> int:
	if Global.foundShards.size() >= upgrade_req:
		apply_upgrade()
		return 3 # Pass index
	elif Global.fade_duration > 30:
		return 6 # Assuming index 6 is the max upgrade text
	else:
		return 4 # Fail index

func apply_upgrade():
	var total = Loader.DEFAULT_COLS * Loader.DEFAULT_ROWS * 22
	Global.fade_duration += 1
	
	upgrade_req *= floor(total * 0.6 / 100 + 1)
	
	print("Next upgrade: ", upgrade_req)
	
	chat[2]["text"] = "You will need at least %d shards. Are you sure?" % upgrade_req
	chat[3]["text"] = "Your memory has been strengthened! You can now recall %d seconds." % Global.fade_duration
	
