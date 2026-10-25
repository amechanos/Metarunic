extends Node
class_name fortune_teller

const MAX_FADE_DURATION := 30
const BASE_REQUIREMENT := 5
const REQUIREMENT_STEP := 14

var chat = [
	{"text": "Would you like me to read your fortune?", "choices": {"Yes": 1, "Upgrade Memory": offer_upgrade, "No": 5}},
	{"text": "Greatness is upon you.", "choices": {"Okay.": 0}},
	{"text": "", "choices": {"Yes": check_upgrade, "No": 0}},
	{"text": "", "choices": {"Okay.": 0}},
	{"text": "", "choices": {"Okay.": 0}},
	{"text": "Salutations traveller!", "choices": {}},
	{"text": "Your memory seems to transcend even of mine...I can't seem to upgrade it any further I'm afraid.", "choices": {"Okay.": 0}},
]

# --- Custom NPC Functions ---

# Each upgrade raises the number of shards you must have gathered. Nothing is spent.
func get_requirement() -> int:
	return BASE_REQUIREMENT + REQUIREMENT_STEP * (Global.fade_duration - Global.WIDTH)

func offer_upgrade() -> int:
	if Global.fade_duration >= MAX_FADE_DURATION:
		return 6

	chat[2]["text"] = "Your memory holds %d seconds. To strengthen it, you must have gathered at least %d shards, and you carry %d. Shall we try?" % [
		Global.fade_duration,
		get_requirement(),
		Global.get_shard_count()
	]
	return 2

func check_upgrade() -> int:
	if Global.fade_duration >= MAX_FADE_DURATION:
		return 6

	var required: int = get_requirement()
	var owned: int = Global.get_shard_count()
	if owned < required:
		chat[4]["text"] = "You need to have gathered at least %d shards, but you only carry %d." % [required, owned]
		return 4

	Global.fade_duration += 1
	if Global.fade_duration >= MAX_FADE_DURATION:
		chat[3]["text"] = "Your memory has been strengthened! You can now recall %d seconds. It cannot be strengthened any further." % Global.fade_duration
	else:
		chat[3]["text"] = "Your memory has been strengthened! You can now recall %d seconds. The next upgrade will need at least %d shards." % [Global.fade_duration, get_requirement()]
	return 3
