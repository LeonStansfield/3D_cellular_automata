extends Node3D

# Settings
@export var iterations : int = 7
var _iterations : int
@export var neighbours : int = 12
@export var spawn_chance : float = 0.43

# 3D matrix storing the map information of each cells state (alive or dead)
@export var grid_size = Vector3(25, 25, 25)
# Voxel matrix
var voxel_grid = []

# Voxels
@export var blockPrefab : PackedScene
@export var grassPrefab : PackedScene
@export var dirtPrefab : PackedScene
var blocks := {}

# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.terrain = self
	
	# Generate the cell grid
	generate_grid()
	# Generate island
	generate_island()

func _process(delta):
	# If generate is pressed, clear the voxel grid and create a new island
	if Input.is_action_just_pressed("Generate"):
		for x in range(grid_size.x):
			for y in range(grid_size.y):
				for z in range(grid_size.z): 
					var pos = Vector3(x, y, z)
					# Check if there is a block there
					if blocks.has(pos):
						# Remove the block
						var block = blocks[pos]
						block.queue_free()
						blocks.erase(pos)
		
		voxel_grid.clear()
		blocks.clear()
		generate_grid()
		generate_island()

func generate_grid():
	# Calculate the total number of voxels
	var total_voxels = grid_size.x * grid_size.y * grid_size.z
	
	# Initialize the voxel array with default values
	voxel_grid.resize(total_voxels)
	
	# For each cell
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			for z in range(grid_size.z):
				# Calculate the index for the current voxel in the linear array
				var index = x + y * grid_size.x + z * (grid_size.x * grid_size.y)
				
				# Initialize each voxel to a default value (e.g., 0 for empty, 1 for filled)
				voxel_grid[index] = 0

# Accessing and modifying voxel values
func get_voxel(x, y, z):
	# Calculate the index for the specified voxel in the linear array
	var index = x + y * grid_size.x + z * (grid_size.x * grid_size.y)
	
	return voxel_grid[index]

func set_voxel(x, y, z, value):
	# Calculate the index for the specified voxel in the linear array
	var index = x + y * grid_size.x + z * (grid_size.x * grid_size.y)
	
	voxel_grid[index] = value

func generate_island():
	# Initialize the grid with random values
	init_grid()
	draw_grid()
	await get_tree().create_timer(0.01).timeout
	
	# Iterate over iterations
	_iterations = iterations
	while _iterations > 0:
		_iterations -= 1
		
		update_grid()
		draw_grid()
		await get_tree().create_timer(0.01).timeout
	
	# Apply tapered points
	post_processing()
	draw_grid()

func init_grid():
	# Initialize the grid with random values
	
	# RNG
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	
	# Loop through each value in the map
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			for z in range(grid_size.z):
				# Set the value to a random number between 0 and 1
				var i = rng.randf_range(0, 1)
				if i <= spawn_chance:
					set_voxel(x, y, z, 1)
				else:
					set_voxel(x, y, z, 0)

func update_grid():
	# Loop through each value in the map
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			for z in range(grid_size.z):
				# Get the number of alive neighbors
				var aliveNeighbours = countAliveNeighbours(Vector3(x, y, z))
				# If the value is alive
				if get_voxel(x, y, z) == 1:
					# If the number of alive neighbors is less than 2
					if aliveNeighbours < neighbours:
						# Kill the voxel
						set_voxel(x, y, z, 0)
				# Else the value is dead
				else:
					# If the number of alive neighbors is exactly 3
					if aliveNeighbours >= neighbours:
						# Spawn a block there
						set_voxel(x, y, z, 1)

func draw_grid():
	# Loop through each value in the grid
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			for z in range(grid_size.z):
				# If the value is alive
				if get_voxel(x, y, z) == 1:
					var pos = Vector3(x, y, z)
					# Check if there is already a block there
					if !blocks.has(pos):
						# Spawn a block there
						var block = blockPrefab.instantiate()
						block.position = pos
						add_child(block)
						blocks[pos] = block
				else:
					var pos = Vector3(x, y, z)
					# Check if there is a block there
					if blocks.has(pos):
						# Remove the block
						var block = blocks[pos]
						block.queue_free()
						blocks.erase(pos)

func post_processing():
	# Replace all blocks facing air above them with grass
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			for z in range(grid_size.z):
				var pos = Vector3(x, y, z)
				# Check if there is a block there
				if blocks.has(pos):
					var block = blocks[pos]
					# Check if the block is facing air
					if !blocks.has(pos + Vector3(0, 1, 0)):
						# Replace the block with grass
						block.queue_free()
						blocks.erase(pos)
						var grass = grassPrefab.instantiate()
						grass.position = pos
						add_child(grass)
						blocks[pos] = grass

func countAliveNeighbours(position : Vector3) -> int:
	var aliveNeighbours : int = 0
	var neighbours = getNeighbors(position)
	for n in neighbours:
		if blocks.has(n):
			aliveNeighbours += 1
			
	return aliveNeighbours

func getNeighbors(position : Vector3) -> Array:
	# Position of current block's center
	var centerPos = position
	var neighbors := []
	
	# Define directions
	var directions = [
		Vector3(1, 0, 0),  # Right
		Vector3(-1, 0, 0), # Left
		Vector3(0, 1, 0),  # Up
		Vector3(0, -1, 0), # Down
		Vector3(0, 0, 1),  # Forward
		Vector3(0, 0, -1),  # Backward
		Vector3(1, 1, 0), # Top right
		Vector3(-1, 1, 0), # Top left
		Vector3(1, -1, 0), # Bottom right
		Vector3(-1, -1, 0), # Bottom left
		Vector3(1, 0, 1), # Forward right
		Vector3(-1, 0, 1), # Forward left
		Vector3(1, 0, -1), # Backward right
		Vector3(-1, 0, -1), # Backward left
		Vector3(0, 1, 1), # Forward top
		Vector3(0, -1, 1), # Forward bottom
		Vector3(0, 1, -1), # Backward top
		Vector3(0, -1, -1), # Backward bottom
		Vector3(1, 1, 1), # Forward top right
		Vector3(-1, 1, 1), # Forward top left
		Vector3(1, -1, 1), # Forward bottom right
		Vector3(-1, -1, 1), # Forward bottom left
		Vector3(1, 1, -1), # Backward top right
		Vector3(-1, 1, -1), # Backward top left
		Vector3(1, -1, -1), # Backward bottom right
		Vector3(-1, -1, -1), # Backward bottom left
	]
	
	# Set relevant neighbor positions
	for direction in directions:
		var neighborPos = centerPos + direction
		neighbors.append(neighborPos)
	
	return neighbors
