extends Node

var data = {
	"bard": [
		{"text": "Greetings traveller!", "choices": {"Who are you?": 1, "Goodbye.": 2}}, #0
	],

	"fortune_teller": [
		{"text": "Greetings traveller, would you like me to read your fortune?", "choices": {"Yes": 1, "I'd like to upgrade my memory.": 2, "No": 5}}, #0
		{"text": "Greatness is upon you. You are destined to change the world. Do not give up young one.", "choices": {"Okay.": 0}},
		{"text": "You will need at least <x> shards to upgrade. Are you sure?", "choices": {"Yes": 3 if shards >= required else 4}},
		{"text": "Your memory has been upgraded to <fade_duration>.", "choices": {"Okay.": 0}},
		{"text": "You do not have enough shards, come back once you have more.", "choices": {"Okay.": 0}},
		{"text": "Salutations traveller!", "choices": {}},
	],	

	"philosopher": [
		{"text": "", "choices": {}}, #0
	],

	"scholar": [
		{"text": "", "choices": {}}, #0
	],

	"wizard": [
		{"text": "Greetings traveller, is there anything I can help you with?", "choices": {"Do you have a twin?": 1, "What do I do again?": 2, "Why am I chosen?": 3, "Goodbye.": 4}}, #0
		{"text": "I do infact have a twin. My brother is also a wizard, someone you probably have met in the tutorial. I assume he has taught you well.", "choices": {"Okay.": 0}},
		{"text": "You need to reform the shattered shards scattered across the land to complete the ritual. If you are lost, you can return to my brother for the tutorial.", "choices": {"Okay.": 0}},
		{"text": "I don't even know. From what I know, the great scholar Artemedias selects the ritualists, perhaps he may have answers?", "choices": {"Okay.": 0}},
		{"text": "Goodbye to you too traveller!", "choices": {}},
	],

	"writer": [
		{"text": "", "choices": {}}, #0
	],
}
