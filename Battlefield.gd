extends Node


var tile_size
var half_tile_size

var grid_size = Vector2(33, 25)
var grid = []
var map
var tiledict

enum ENTITY_TYPES {PLAYER}

func _ready():
	map = get_node("GridMap/base")
	tiledict = map.get_tileset().get_meta('tile_meta')
	tile_size = map.get_cell_size()
	
	# in order to put the object at the center
	half_tile_size = tile_size / 2
	
	# 1. Create the grid Array
	for x in range(grid_size.x):
		grid.append([])
		for y in range(grid_size.y):
			grid[x].append(null)
	
	var start_pos = update_child_pos($Player)
	$Player.position = start_pos
	
# the object will ask if the cell is vacant
func is_cell_vacant(pos, direction):
	# Return true if the cell is vacant, else false

	var grid_pos = map.world_to_map(pos) + direction
	
	var tile_id = map.get_cellv(grid_pos)
	var solid = tile_id in tiledict and tiledict[tile_id]["solid"]
	
	# world boundaries
	if grid_pos.x < grid_size.x and grid_pos.x >=0:
		if grid_pos.y < grid_size.y and grid_pos.y >=0:
			return grid[grid_pos.x][grid_pos.y] == null and not solid
			
	return false
	
func update_child_pos(child_node):
	# Move a child to a new position in the grid Array
	# Returns the new target world position of the child
	var grid_pos = map.world_to_map(child_node.position)
	grid[grid_pos.x][grid_pos.y] = null
	
	var new_grid_pos = grid_pos + child_node.direction
	grid[new_grid_pos.x][new_grid_pos.y] = child_node.type
	
	var target_pos = map.map_to_world(new_grid_pos) + half_tile_size
	return target_pos
