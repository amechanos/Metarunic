extends Node

var health: int = 10

# Minesweeper Mode 
const TILE_SIZE = 96
const WIDTH = 8
const HEIGHT = 6

var fade_duration = WIDTH
var grid: Array = []

var found: int = 0

# Jigsaw Mode
var shardLibrary: Dictionary = {}

var assemblyState: Dictionary = {}

var lostShards: Dictionary = {}
var foundShards: Dictionary = {}

var completedCards: Array = ["the_fool", "wheel_of_fortune"]
var bard_guitar_scattered: bool = false
var bard_guitar_returned: bool = false
var bard_guitar_found: bool = false
var bard_guitar_room: int = -1

func _ready():
	Loader.load_shard_library()
	lostShards = shardLibrary
	
# Environment
var current_npc: NpcData = null
var current_beast: BeastData = null
var defeated_beasts: Array[String] = []
