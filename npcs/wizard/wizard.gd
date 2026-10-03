extends Node
class_name wizard

const TOTAL_CARDS := 22

var chat = [
	{"text": "Welcome, ritualist. What would you like to know?", "choices": {
		"What is my goal?": 1,
		"How do I find shards?": 2,
		"How does mental work?": show_mental,
		"How do I restore cards and face beasts?": 4,
		"Why was I chosen?": 5,
		"How many cards have I restored?": show_progress,
		"Goodbye.": 7
	}},
	{"text": "Recover the shards scattered across the regions, then assemble them into the 22 Major Arcana cards. Follow the marked exits to explore connected regions. Restored cards let you challenge the beasts and complete the ritual that keeps them asleep.", "choices": {
		"How do I find shards?": 2,
		"How do I restore cards and face beasts?": 4,
		"How many cards have I restored?": show_progress,
		"Back.": 0
	}},
	{"text": "Move with the arrow keys or WASD. The number revealed on the tile you leave tells you how many shard tiles are in the eight surrounding tiles. Use those clues to choose where to search. Press Enter or left-click to reveal the tile under you; right-click to flag or unflag it. Finding a shard adds it to your collection.", "choices": {
		"How does mental work?": show_mental,
		"What do I do with the shards?": 4,
		"Back.": 0
	}},
	{"text": "A wrong reveal costs one mental. I've heard stories of a Bard that can restore you to full mental in exchange for shards; each healing costs more than the last.", "choices": {
		"How do I find shards?": 2,
		"Back.": 0
	}},
	{"text": "Open the Tarot Bag to arrange the shards into cards. Drag pieces together and rotate them with R or E. Once a card is restored, take it to a beast's statue and offer the card that answers its riddle.", "choices": {
		"What is my goal?": 1,
		"How many cards have I restored?": show_progress,
		"Back.": 0
	}},
	{"text": "That is a question for Artemedias, the scholar. He knows the history of Teranilus and the reason you were chosen.", "choices": {
		"What is my goal?": 1,
		"Back.": 0
	}},
	{"text": "", "choices": {
		"What is my goal?": 1,
		"Back.": 0
	}},
	{"text": "Farewell, ritualist. Explore carefully, follow the clues, and bring the Arcana back together.", "choices": {}}
]

func show_mental() -> int:
	chat[3]["text"] = "A wrong reveal costs one mental. You have %d of %d mental. If it reaches zero, your run ends. The Bard can restore you to full mental in exchange for shards; each healing costs more than the last." % [Global.health, Global.MAX_HEALTH]
	return 3

func show_progress() -> int:
	var restored_cards: Dictionary = {}
	for card in Global.completedCards:
		if Global.shardLibrary.has(card):
			restored_cards[card] = true

	chat[6]["text"] = "You have restored %d of %d cards. Keep exploring to find the remaining shards." % [restored_cards.size(), TOTAL_CARDS]
	return 6
