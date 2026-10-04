extends Node
class_name wizard

const TOTAL_CARDS := 22

var chat = [
	{"text": "Welcome, ritualist. What would you like to know?", "choices": {
		"What is my goal?": 1,
		"How do I find shards?": 2,
		"How does mental work?": 3,
		"How do I restore cards and face beasts?": 4,
		"Why was I chosen?": 5,
		"How many cards have I restored?": show_progress,
		"Check my status.": show_status,
		"Goodbye.": 7
	}},
	{"text": "Your goal is to recover the lost fragments of Arcana scattered across the world, then assemble them into the 22 cards. They are the masters of the sleeping beasts. Follow the marked exits to explore connected regions.", "choices": {
		"How do I find shards?": 2,
		"How do I restore cards and face beasts?": 4,
		"How many cards have I restored?": show_progress,
		"Check my status.": show_status,
		"Back.": 0
	}},
	{"text": "You can move with the arrow keys or WASD. The number revealed on the tile you leave tells you how many shards are adjacent to the tile you are standing on. Think Minesweeper. Use those clues to choose where to search. Press Enter or left-click to reveal the tile under you; right-click to flag or unflag it. Finding a shard adds it to your collection.", "choices": {
		"How does mental work?": 3,
		"What do I do with the shards?": 4,
		"Check my status.": show_status,
		"Back.": 0
	}},
	{"text": "A wrong reveal costs one mental. You have %d out of %d mental. If it reaches zero, your run ends. I've heard stories of a Bard travelling the world that may be able to restore your mental if you ever need it." % [Global.health, Global.MAX_HEALTH], "choices": {
		"How do I find shards?": 2,
		"Check my status.": show_status,
		"Back.": 0
	}},
	{"text": "Open the Tarot Bag to arrange the shards into cards. Drag pieces together and rotate them with Right Mouse Button, R or E. Once a card is restored, you'll have to figure out which Arcana belongs to which beast based on its riddle.", "choices": {
		"What is my goal?": 1,
		"How many cards have I restored?": show_progress,
		"Check my status.": show_status,
		"Back.": 0
	}},
	{"text": "That is a question for Artemedias, the scholar. He knows the history of Teranilus and the reason you were chosen.", "choices": {
		"What is my goal?": 1,
		"Check my status.": show_status,
		"Back.": 0
	}},
	{"text": "", "choices": {
		"What is my goal?": 1,
		"Check my status.": show_status,
		"Back.": 0
	}},
	{"text": "Farewell, ritualist. Explore carefully, follow the clues, and bring the Arcana back together.", "choices": {}}
]

func show_progress() -> int:
	var restored_cards: Dictionary = {}
	for card in Global.completedCards:
		if Global.shardLibrary.has(card):
			restored_cards[card] = true

	chat[6]["text"] = "You have restored %d of %d cards. Keep exploring to find the remaining shards." % [restored_cards.size(), TOTAL_CARDS]
	return 6

func show_status() -> int:
	var restored_cards: Dictionary = {}
	for card in Global.completedCards:
		if Global.shardLibrary.has(card):
			restored_cards[card] = true

	var collected_shards := 0
	for shards in Global.foundShards.values():
		collected_shards += shards.size()

	var total_shards := 0
	for shards in Global.shardLibrary.values():
		total_shards += shards.size()

	var discovered_rooms: Dictionary = {}
	for room in Map.discovered_nodes:
		discovered_rooms[room] = true

	chat[6]["text"] = "Your current status:\nMental: %d/%d\nCards restored: %d/%d\nShards collected: %d/%d\nBeasts awakened: %d/%d\nRooms explored: %d/%d" % [
		Global.health,
		Global.MAX_HEALTH,
		restored_cards.size(),
		TOTAL_CARDS,
		collected_shards,
		total_shards,
		Global.defeated_beasts.size(),
		TOTAL_CARDS,
		discovered_rooms.size(),
		Map.map_width * Map.map_height
	]
	return 6
