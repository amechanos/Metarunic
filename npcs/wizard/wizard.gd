extends Node
class_name wizard

var upgrade_req = 5

var chat = [
		{"text": "Greetings traveller, is there anything I can help you with?", "choices": {"Do you have a twin?": 1, "What do I do again?": 2, "Why am I chosen?": 3, "Goodbye.": 4}}, #0
		{"text": "I do infact have a twin. My brother is also a wizard, someone you probably have met in the tutorial. I assume he has taught you well.", "choices": {"Okay.": 0}},
		{"text": "You need to reform the shattered shards scattered across the land to complete the ritual. If you are lost, you can return to my brother for the tutorial.", "choices": {"Okay.": 0}},
		{"text": "I don't even know. From what I know, the great scholar Artemedias selects the ritualists, perhaps he may have answers?", "choices": {"Okay.": 0}},
		{"text": "Goodbye to you too traveller!", "choices": {}},
]

# --- Custom NPC Functions ---
