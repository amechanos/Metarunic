extends Node
class_name philosopher

var upgrade_req = 5

var chat = [
	{"text": "You have arrived at the exact moment I was wondering whether a question can walk without an answer.", "choices": {"What were you wondering?": 1, "Do you ever say hello normally?": 2, "I wish to finish the ritual.": ask_finish, "Goodbye.": 8}},
	{"text": "If a map shows every road, does it still leave room for a journey? Or is surprise simply an unlabelled destination?", "choices": {"The journey matters more than the map.": 3, "I prefer knowing where I am going.": 4, "Ask me something practical.": 5}},
	{"text": "Hello, then. You are a person. I am a person. We have successfully met the minimum requirements for a conversation.", "choices": {"That was almost warm.": 0, "Tell me something useful.": 5}},
	{"text": "Then remember this: certainty is a lantern, not the sun. Carry it proudly, but do not mistake its circle of light for the whole world.", "choices": {"I will remember that.": 0}},
	{"text": "Then remember this: a straight road is still a choice. Even the safest step teaches you what the others would have felt like.", "choices": {"That is less practical than you promised.": 0}},
	{"text": "Very well. When a choice frightens you, ask which consequence you are willing to repair. Fear becomes easier to hold when it has a handle.", "choices": {"What if every choice is bad?": 6, "Thank you.": 0}},
	{"text": "Then choose the bad thing that leaves you able to choose again. A door is not a failure because it opens into another room.", "choices": {"You make everything sound like a door.": 7}},
	{"text": "Doors are honest. They admit that every answer changes the question.", "choices": {"I need a less philosophical answer.": 5, "Goodbye.": 8}},
	{"text": "Go carefully. Or boldly. I have not yet decided which is wiser, and I would hate to settle the matter prematurely.", "choices": {}},
	{"text": "", "choices": {"I understand.": 0}},
	{"text": "Every beast has been answered, whether with a lullaby or with a key. Once you walk through this door, it will not open again, and the world will become whatever you have made it. Are you ready to finish the ritual?", "choices": {"Finish the ritual.": finish_ritual, "Not yet.": 0}},
	{"text": "Then let us see what you have decided.", "choices": {"...": 11}}
]

# --- Custom NPC Functions ---

# The ritual can only be finished once all 22 beasts have been faced, whether put to sleep or released.
func ask_finish() -> int:
	var faced: int = Global.defeated_beasts.size()
	if faced < Global.TOTAL_BEASTS:
		chat[9]["text"] = "A door does not open for someone who has not walked the whole hallway. You have faced %d of the %d beasts. Return when none remain, and I will gladly hold it open." % [faced, Global.TOTAL_BEASTS]
		return 9
	return 10

func finish_ritual() -> int:
	if Global.defeated_beasts.size() < Global.TOTAL_BEASTS:
		return ask_finish()
	Global.begin_ending("ritual")
	return 11
