extends Control

const PEACE_TITLE := "THE LONG SLEEP"
const PEACE_TEXT := "Every statue in Teranilus stands whole, and every beast sleeps on. You returned each Arcana to its place and the seal holds, just as it did for the ritualist before you. The beasts ask nothing more of humanity for another hundred years.\n\nArtemedias closes his book and, for once, has nothing to add. The Bard plays something soft in the square, and the Writer scribbles a line in the margin: the world did not end; it merely kept its promise. Somewhere, a Philosopher is wondering whether peace is a door or a wall.\n\nThe ritual will be repeated, but not by you. Rest well, ritualist. The world is safe."

const MULTI_TITLE := "A WORLD DIVIDED"
const MULTI_TEXT := "%s now walk free beneath the sky of Teranilus, while the rest of the Arcana sleep on. The seal is broken, but not shattered. Some regions bloom with wonders and others burn with fear, and no two travellers can agree which stories are true.\n\nArtemedias adds a new chapter to his book, and his hand shakes as he writes it. The Writer says the world has forgotten how to introduce itself. The Philosopher says every door opens into another room, and that someone must now decide who walks through.\n\nYou kept some of the beasts asleep. It was not enough to keep the peace, and not enough to lose it all. The world will have to learn to live with what you set loose."

const CHAOS_TITLE := "THE END OF TERANILUS"
const CHAOS_TEXT := "One by one the statues shatter, and the roars of twenty-two beasts become a single sound that shakes the sky. Freed from their masters and their promise, they answer to nothing.\n\nThe seas boil and the mountains fall. The towers crumble, the fields burn, and the cities of Teranilus are swallowed whole. Artemedias' book is ash before he can finish its last page. The Bard's song is drowned out, the Writer's ink runs dry, and the Philosopher finds that every door has been torn from its frame.\n\nThe beasts wished humanity to be worthy of them. You decided it was not. When the dust finally settles, there is no one left to remember that you were ever chosen."

const LOST_FAITH_TITLE := "FAITH LOST"
const LOST_FAITH_TEXT := "Your mind falters for the last time, and the ritual falls silent. Far beneath Teranilus, the beasts feel the seal slacken and wait for an answer that never comes. Three times humanity stumbled, and three times the beasts gave it the chance to rise.\n\nThere will not be a fourth. The statues crack from the inside, one by one, until twenty-two roars become a single sound. Freed from their masters and from their patience, the beasts no longer ask whether humanity is worthy of them.\n\nThe seas boil, the towers fall, and the cities of Teranilus are swallowed whole. Artemedias' book is ash, the Bard's song is silence, and the Philosopher's last door is torn from its frame. The beasts had wished humanity not to descend in intelligence. In the end, it simply did.\n\nYou were chosen, ritualist, and you could not hold."

const MENU_SCENE := "res://mainmenu.tscn"

@onready var title: Label = $Title
@onready var body: RichTextLabel = $Body
@onready var summary: Label = $Summary
@onready var menu_button: Button = $MenuButton
@onready var text_sound: AudioStreamPlayer = $AudioStreamPlayer

var typing := false
var progress := 0.0

func _ready() -> void:
	Global.stop_music()
	var ending: Dictionary = _build_ending()
	title.text = ending["title"]
	body.text = "[center]%s[/center]" % ending["text"]
	if Global.ending_reached == "lost_faith":
		summary.text = "The beasts have lost faith in humanity."
	else:
		summary.text = "Beasts released: %d / %d" % [Global.released_beasts.size(), Global.TOTAL_BEASTS]

	body.visible_characters = 0
	summary.modulate.a = 0.0
	menu_button.visible = false
	menu_button.pressed.connect(_on_menu_pressed)

	modulate.a = 0.0
	create_tween().tween_property(self, "modulate:a", 1.0, 1.5)
	typing = true

func _process(delta: float) -> void:
	if not typing:
		return
	progress += delta * Global.dialogue_text_speed
	var total: int = body.get_total_character_count()
	body.visible_characters = mini(int(progress), total)
	text_sound.play()
	if body.visible_characters >= total:
		_finish()

func _input(event: InputEvent) -> void:
	if typing and event.is_action_pressed("ui_accept"):
		_finish()

func _finish() -> void:
	typing = false
	body.visible_characters = -1
	menu_button.visible = true
	create_tween().tween_property(summary, "modulate:a", 1.0, 1.0)

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)

func _build_ending() -> Dictionary:
	var released: int = Global.released_beasts.size()

	if Global.ending_reached == "lost_faith":
		return {"title": LOST_FAITH_TITLE, "text": LOST_FAITH_TEXT}

	if released == 0:
		return {"title": PEACE_TITLE, "text": PEACE_TEXT}

	if released >= Global.TOTAL_BEASTS:
		return {"title": CHAOS_TITLE, "text": CHAOS_TEXT}

	if released == 1:
		var beast := load("res://bosses/beasts/%s.tres" % Global.released_beasts[0]) as BeastData
		var custom_text: String = beast.release_ending if beast else ""
		if not custom_text.is_empty():
			return {
				"title": "%s UNBOUND" % _beast_name(Global.released_beasts[0]).to_upper(),
				"text": custom_text
			}

	var names := PackedStringArray()
	for id in Global.released_beasts:
		names.append(_beast_name(id))
	var intro := "%d beasts" % released
	return {
		"title": MULTI_TITLE,
		"text": MULTI_TEXT % ("%s (%s)" % [intro, _join_names(names)])
	}

func _beast_name(id: String) -> String:
	return id.replace("_", " ").capitalize()

func _join_names(names: PackedStringArray) -> String:
	if names.size() <= 2:
		return " and ".join(names)
	return ", ".join(names.slice(0, names.size() - 1)) + ", and " + names[names.size() - 1]
