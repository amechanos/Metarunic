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

# The Bard only checks that you have collected enough shards; none are spent.
func _required_shards() -> int:
	return 1 + Global.bard_heal_count

func offer_heal() -> int:
	if Global.health >= Global.MAX_HEALTH:
		return 3

	var required: int = _required_shards()
	var shard_count: int = Global.get_shard_count()
	if shard_count < required:
		chat[2]["text"] = "A healing song needs a traveller who has gathered at least %d shards, and you carry %d. Come back when you have found more." % [required, shard_count]
		return 2

	chat[1]["text"] = "I can restore you to full health. You have gathered %d shards, and I ask for %d. Shall I play?" % [shard_count, required]
	return 1

func heal_player() -> int:
	if Global.health >= Global.MAX_HEALTH:
		return 3

	if Global.get_shard_count() < _required_shards():
		return offer_heal()

	Global.health = Global.MAX_HEALTH
	Global.bard_heal_count += 1
	chat[4]["text"] = "Your health is restored. My next song will need you to have gathered at least %d shards." % _required_shards()
	return 4
