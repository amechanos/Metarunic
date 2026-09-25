extends Node
class_name bard

var upgrade_req = 5

var chat = [
	{"text": "You have the look of someone who has heard a good song and is pretending not to need another.", "choices": {"I am looking for something else.": 1, "Play me a song.": 2 if Global.bard_guitar_returned else 1, "Goodbye.": 9}},
	{"text": "My guitar is gone. I left it beside a campfire, and the next morning, it was gone. It was like the night had scattered it away!", "choices": {"How can I help?": start_guitar_quest, "Why would a night scatter a guitar?": 3, "Goodbye.": 7}},
	{"text": "A song without a listener is just a secret with a melody. Sit a moment; I will make it less lonely.", "choices": {"That was beautiful.": 0, "Tell me about your guitar.": 4}},
	{"text": "Because it was jealous. Every time I played, the stars leaned closer, and one night the sky decided to keep the tune for itself.", "choices": {"I will look for the pieces.": start_guitar_quest, "That is not how guitars work.": 0}},

	{"text": "My guitar was forged to calm the beasts, but they are slumbering as of now. Perhaps if they were awake, my tunes could soothe them to not destroy our world.", "choices": {"How do I do that?": 5, "I found your guitar.": check_guitar, "Wow.": 0}},
	{"text": "Sometimes, the most beautiful melodies are the ones we sing to ourselves in the dark. Tarot cards can be reversed, giving beasts a second chance.", "choices": {"Got it.": 0}},

	{"text": "Wow! You found my guitar! Thanks a lot, traveller. Here, take this card I found.", "choices": {"Play me a song?": 2, "Goodbye.": 7}},
	{"text": "Safe roads, traveller. Leave a little room in your day for an unexpected chorus.", "choices": {}}
]

# --- Custom NPC Functions ---

func start_guitar_quest() -> int:
	Global.bard_guitar_scattered = true
	Global.bard_guitar_room = Map.current_node
	return 4

func check_guitar() -> int:
	if Global.bard_guitar_returned:
		return 6
	if Global.bard_guitar_found:
		Global.bard_guitar_returned = true
		if "the_star" not in Global.completedCards:
			Global.completedCards.append("the_star")
		Global.shardLibrary.erase("the_star")
		Global.lostShards.erase("the_star")
		return 6
	return 7
