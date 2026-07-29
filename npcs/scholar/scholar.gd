extends Node
class_name scholar

var upgrade_req = 3
var has_book = false

var chat = [
	{"text": "Good day traveller, what brings you here?", "choices": {"Why did you choose me as a ritualist?": 1, "Who are you?": find_book, "Goodbye": 9}}, #0
	{"text": "You have shown promise with an architect's mind. Precise, delibrate actions have made me choose you. Don't fail me.", "choices": {"Okay.": 0}},
	{"text": "My name is Artemedias, the greatest scholar in Teranilus. What would you like to know about?", "choices": {"What happened to the ritualist before me?": 4, "Why do we bother performing these rituals?": 5, "Goodbye.": 9}},
	{"text": "This book? It's an important book that informs me of calamities and of the next ritual. My findings are all collected in here.", "choices": {"That would benefit me for my journey.": 6, "That's really cool...": 2}},
	{"text": "The previous ritualist did his job. He protected Teranilus again, keeping peace in the world. I hope you make the right decisions boy, don't make the world hate you.", "choices": {"Okay.": 2} },
	{"text": "Teranilus was once governed by beasts, ruling our world. When we discovered magic, we were able to turn them into statues, allowing humanity to thrive. But nothing is permanent. The magic slowly wore off, so every 50 years, a new ritualist is chosen to help keep the beasts asleep.", "choices": {"Okay.": 2} },
	{"text": "You want my book? Prove your worth. Reform 3 cards and I'll give it to you.", "choices": {"I've done that.": check_cards, "Okay.": 0}},
	{"text": "Very well. Use it wisely.", "choices": {"Okay.": 0}},
	{"text": "You have not done what I've asked. Come back once you've fixed three cards.", "choices": {"Okay.": 0}},
	{"text": "Goodbye.", "choices": {}},
]

# --- Custom NPC Functions ---

func find_book() -> int:
	if not has_book:
		chat[2]["choices"]["What is that book?"] = 3
	return 2
	
func check_cards() -> int:
	if Global.completedCards.size() >= 3:
		return 7
	else:
		return 8
