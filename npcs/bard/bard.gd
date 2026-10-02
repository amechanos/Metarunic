extends Node
class_name bard

var chat = [
	{"text": "A song can mend more than a broken heart. Need a little help?", "choices": {"Heal me.": offer_heal, "Goodbye.": 5}},
	{"text": "", "choices": {"Play for me.": heal_player, "Not now.": 0}},
	{"text": "", "choices": {"I'll come back later.": 0}},
	{"text": "You are already at full health.", "choices": {"Thank you.": 0}},
	{"text": "", "choices": {"Thank you.": 0}},
	{"text": "Safe roads, traveller. Leave a little room in your day for an unexpected chorus.", "choices": {}}
]

func offer_heal() -> int:
	if Global.health >= Global.MAX_HEALTH:
		return 3

	var price = 1 + Global.bard_heal_count
	var shard_count = _get_shard_count()
	if shard_count < price:
		chat[2]["text"] = "You need %d shards for a healing song, but you only have %d." % [price, shard_count]
		return 2

	chat[1]["text"] = "I can restore you to full health for %d shard(s). You have %d. Shall I play?" % [price, shard_count]
	return 1

func heal_player() -> int:
	if Global.health >= Global.MAX_HEALTH:
		return 3

	var price = 1 + Global.bard_heal_count
	if not _spend_shards(price):
		return offer_heal()

	Global.health = Global.MAX_HEALTH
	Global.bard_heal_count += 1
	chat[4]["text"] = "Your health is restored. My next song will cost %d shard(s)." % (1 + Global.bard_heal_count)
	return 4

func _get_shard_count() -> int:
	var total = 0
	for card_name in Global.foundShards:
		total += Global.foundShards[card_name].size()
	return total

func _spend_shards(amount: int) -> bool:
	if _get_shard_count() < amount:
		return false

	var remaining = amount
	for card_name in Global.foundShards.keys():
		var card_shards: Array = Global.foundShards[card_name]
		while remaining > 0 and not card_shards.is_empty():
			card_shards.pop_back()
			remaining -= 1
		if card_shards.is_empty():
			Global.foundShards.erase(card_name)
		if remaining == 0:
			return true
	return false
