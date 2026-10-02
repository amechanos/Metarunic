extends Node
class_name writer

var upgrade_req = 5

var chat = [
	{"text": "Stop there. I am trying to describe the sound of a person deciding whether to knock.", "choices": {"Did you decide?": 1, "I can come back later.": 7, "Goodbye.": 7}},
	{"text": "I did. You knocked with your silence, which is much more dramatic than using your hand.", "choices": {"What are you writing?": 2, "Can I read it?": 3, "What can you tell me about my cards?": 8}},
	{"text": "A field guide to impossible places: rooms that remember you, roads that change their minds, and the small courage required to keep walking.", "choices": {"Write about this place.": 4, "That sounds lonely.": 5}},
	{"text": "Not yet. A story should be opened carefully, like a sealed letter from someone who knows your worst habit.", "choices": {"Then tell me the first line.": 4, "Fair enough.": 0}},
	{"text": "The first line is: 'The world did not end; it merely forgot how to introduce itself.' Too grand?", "choices": {"Keep it.": 6, "Make it stranger.": 5}},
	{"text": "Loneliness is useful to a writer. It makes every footstep sound like evidence.", "choices": {"And what is my evidence?": 6, "That is a little bleak.": 0}},
	{"text": "That you keep moving after the map stops explaining itself. I will put that in the margin, where the best truths usually hide.", "choices": {"I am glad I could help.": 0, "Goodbye.": 7}},
	{"text": "Until next time. Try not to do anything too narratively convenient while I am away.", "choices": {}},
	{"text": "Show me a card you carry, and I will tell you what it has been trying to say.", "choices": {}}
]

# --- Custom NPC Functions ---

var card_descriptions = {
	"the_fool": "The Fool is innocence, beginnings, and potential.",
	"the_magician": "The Magician...I've been working on that one. It represents will, skill, and manifestation.",
	"the_high_priestess": "The High Priestess is intuition, mystery, and stillness.",
	"the_empress": "The Empress! My favourite card. It represents fertility, nurture, and abundance.",
	"the_emperor": "The Emperor...Domination and power...It represents authority, structure, and stability.",
	"the_hierophant": "The Hierophant? That's a tricky one. It represents tradition, teaching, and belief.",
	"the_lovers": "The Lovers. A classic. They represent union, choice, and harmony.....and love of course.",
	"the_chariot": "The Chariot you say? I learnt about this most recently. It represents control, triumph, and determination.",
	"strength": "Strength. Ah yes, the card about power. It represents courage, patience, and compassion.",
	"the_hermit": "The Hermit...like my dad...It represents solitude, reflection, and wisdom.",
	"wheel_of_fortune": "The Wheel of Fortune. It's probably the most simple card. It represents change, cycles, and fate.",
	"justice": "Justice prevails! That tarot represents truth, balance, and consequence.",
	"the_hanged_man": "The Hanged Man! Of course. The unlucky man represents surrender, perspective, and pause.",
	"death": "Death. Well, well well. Unlucky number 13, eh? It represents ending, transformation, and release.",
	"temperance": "Temperance is cool. I personally like it because it represents balance, healing, and moderation.",
	"the_devil": "The Devil you say? Ugh, well of course he's from hell. It represents addiction, bondage, temptation, and materialism.",
	"the_tower": "The Tower? Think about a dark, spooky tower. It represents upheaval, revelation, and liberation.",
	"the_star": "The Star...There's not much known, but I know it represents hope, renewal, and guidance.",
	"the_moon": "The Moon is scary and mysterious. It represents illusion, intuition, and uncertainty.",
	"the_sun": "The Sun is is a big ball of sunshine and happiness! It represents joy, clarity, and vitality.",
	"judgement": "Judgement is about judging people, duh. It represents awakening, reckoning, and renewal.",
	"the_world": "The World is about cycles. It represents completion, wholeness, and fulfillment."
}

func _init() -> void:
	for card in Global.completedCards:
		if card_descriptions.has(card):
			chat[8]["choices"][_card_title(card)] = Callable(self, "_describe_card").bind(card)
	chat[8]["choices"]["That is enough for now."] = 0

func _describe_card(card: String) -> int:
	var description = card_descriptions.get(card, "I don't know much about that card. Maybe if you collect the card, I might be able to study it!")
	chat.append({"text": description, "choices": {"Ask about another card.": 8, "That is enough for now.": 0}})
	return chat.size() - 1

func _card_title(card: String) -> String:
	return card.replace("_", " ").capitalize()
