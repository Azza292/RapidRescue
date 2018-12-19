# Path - An object which is used to direct `ACTORS` across the board and store `ITEMS`.

extends Node2D

var connections
var moveable
var collectable
# Index Relative to the playing board
var index

var properties = PropertyManager.new()
var traversal = TraversalInfo.new()
var c_storage = CollectableStorage.new()

var _target_pos
var _start_pos
var _t = 0

const sprite_map = {
	
	'' : preload('res://Sprites/road/blank.png'),
	
	# Straight
	'NS' : preload('res://Sprites/road/Straight/straight_ns.png'),
	'EW' : preload('res://Sprites/road/Straight/straight_ew.png'),
	
	# Corner
	'ES' : preload('res://Sprites/road/Corner/corner_es.png'),
	'NE' : preload('res://Sprites/road/Corner/corner_ne.png'),
	'NW' : preload('res://Sprites/road/Corner/corner_nw.png'),
	'SW' : preload('res://Sprites/road/Corner/corner_sw.png'),
	
	# Tee Intersection
	'ESW' : preload('res://Sprites/road/Tee/tee_esw.png'),
	'NES' : preload('res://Sprites/road/Tee/tee_nes.png'),
	'NEW' : preload('res://Sprites/road/Tee/tee_new.png'),
	'NSW' : preload('res://Sprites/road/Tee/tee_nsw.png'),	
}

# Travel time in seconds
const _TRAVEL_TIME = 0.6

signal target_reached

func _ready():
	_target_pos = position
	_start_pos = position
	pass
	
func init(index, connections, moveable, collectable=null):
	self.index = index
	self.connections = connections
	self.moveable = moveable
	self.collectable = collectable
	update_sprite()
	
func _process(delta):
	
	if _t <= _TRAVEL_TIME:
		_move_toward_target(delta)
		
func _move_toward_target(delta):
	
	_t += delta

	if _t >= _TRAVEL_TIME:
		position = _target_pos
		emit_signal("target_reached")
		return
		
	var time = _t / _TRAVEL_TIME
	var progress = Easing.smooth_stop5(time)
	var vector_difference = _target_pos - _start_pos
	var next_pos = _start_pos + (progress * vector_difference)
	
	position = next_pos

func set_target(target, is_instant=false):
	
	if is_instant:
		position = target
		_target_pos = position
	else:
		_start_pos = position
		_target_pos = target
		_t = 0

func update_index(index):
	self.index = index
	
func update_sprite():
	var content = ''
	for c in connections: if connections[c]: content += (c)
	$Sprite.texture = sprite_map[content]

func rotate():
	var names = connections.keys()
	var values = connections.values()
	var temp_values = values.duplicate()
	
	#Shift Bool
	var count = connections.size()
	for i in count:
		if i-1 >= 0:
			values[i] = temp_values[i - 1]
		else:
			values[i] = temp_values[count - 1]
			
	# Apply Rotation
	for i in len(connections):
		connections[names[i]] = values[i]
	
	update_sprite()

class CollectableStorage:
	"""Store Information regarding a potential collectable."""
	var item
	
	var is_occupied setget ,occupied
	
	func occupied():
		return item != null
	
	func collect():
		var t = item
		item = null
		return t
	
	func store(item):
		self.item = item

class TraversalInfo:
	"""Used for traversing the board / path finding."""
	var parent
	var h_cost
	var g_cost
	
	func _init():
		self.g_cost = 0
		self.h_cost = 0


class PropertyManager:
	var _properties = []
	
	func set(key, value):
		
		var success = false
		for p in _properties:
			if p.has(key):
				success = true
				p = value
		
		if !success:
			_properties.append({key : value})
			
	func get(key):
		for p in _properties:
			if p.has(key):
				return p[key]
				
	func remove(key):
		for p in _properties:
			if p.has(key):
				_properties.erase(p)
			
	func has(key):
		for p in _properties:
			if p.has(key):
				return true
		return false
		
