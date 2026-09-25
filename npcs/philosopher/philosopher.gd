extends Node
class_name philosopher

var upgrade_req = 5

var chat = [
	{"text": "You have arrived at the exact moment I was wondering whether a question can walk without an answer.", "choices": {"What were you wondering?": 1, "Do you ever say hello normally?": 2, "Goodbye.": 8}},
	{"text": "If a map shows every road, does it still leave room for a journey? Or is surprise simply an unlabelled destination?", "choices": {"The journey matters more than the map.": 3, "I prefer knowing where I am going.": 4, "Ask me something practical.": 5}},
	{"text": "Hello, then. You are a person. I am a person. We have successfully met the minimum requirements for a conversation.", "choices": {"That was almost warm.": 0, "Tell me something useful.": 5}},
	{"text": "Then remember this: certainty is a lantern, not the sun. Carry it proudly, but do not mistake its circle of light for the whole world.", "choices": {"I will remember that.": 0}},
	{"text": "Then remember this: a straight road is still a choice. Even the safest step teaches you what the others would have felt like.", "choices": {"That is less practical than you promised.": 0}},
	{"text": "Very well. When a choice frightens you, ask which consequence you are willing to repair. Fear becomes easier to hold when it has a handle.", "choices": {"What if every choice is bad?": 6, "Thank you.": 0}},
	{"text": "Then choose the bad thing that leaves you able to choose again. A door is not a failure because it opens into another room.", "choices": {"You make everything sound like a door.": 7}},
	{"text": "Doors are honest. They admit that every answer changes the question.", "choices": {"I need a less philosophical answer.": 5, "Goodbye.": 8}},
	{"text": "Go carefully. Or boldly. I have not yet decided which is wiser, and I would hate to settle the matter prematurely.", "choices": {}}
]

# --- Custom NPC Functions ---
