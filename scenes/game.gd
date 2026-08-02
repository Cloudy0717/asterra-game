extends Node2D

@onready var main_menu = $UI/MainMenu
@onready var hud = $UI/HUD
@onready var dialogue_box = $UI/DialogueBox
@onready var naming_screen = $UI/NamingScreen
@onready var inventory_screen = $UI/InventoryScreen
@onready var status_screen = $UI/StatusScreen
@onready var settings_screen = $UI/SettingsScreen
@onready var fade_rect = $UI/FadeLayer/FadeRect
@onready var player = $Player
@onready var camera = $Player/Camera2D
@onready var battle_screen = $UI/BattleScreen
@onready var shop_screen = $UI/ShopScreen
var game_over_screen: CanvasLayer
var pause_menu: CanvasLayer
var quest_log_screen: CanvasLayer
var forge_screen: CanvasLayer
var recycle_screen: CanvasLayer
var party_board_screen: CanvasLayer
var storage_screen: CanvasLayer
var map_manager: Node
var quest_manager: Node
var encounter_manager: Node
var transition_manager: Node

func _ready():
	add_to_group("game")
	hud.visible = false
	dialogue_box.visible = false
	naming_screen.visible = false
	inventory_screen.visible = false
	status_screen.visible = false
	settings_screen.visible = false
	battle_screen.visible = false
	shop_screen.visible = false
	game_over_screen = load("res://scenes/game_over_screen.gd").new()
	game_over_screen.name = "GameOverScreen"
	$UI.add_child(game_over_screen)
	game_over_screen.hide_screen()

	pause_menu = load("res://scenes/pause_menu.gd").new()
	pause_menu.name = "PauseMenu"
	$UI.add_child(pause_menu)

	quest_log_screen = load("res://scenes/quest_log_screen.gd").new()
	quest_log_screen.name = "QuestLogScreen"
	$UI.add_child(quest_log_screen)
	quest_log_screen.hide_screen()
	
	forge_screen = load("res://scenes/forge_screen.tscn").instantiate()
	forge_screen.name = "ForgeScreen"
	$UI.add_child(forge_screen)
	forge_screen.forge_closed.connect(func(): pass)

	recycle_screen = load("res://scenes/recycle_screen.tscn").instantiate()
	recycle_screen.name = "RecycleScreen"
	$UI.add_child(recycle_screen)

	party_board_screen = load("res://scenes/party_board_screen.tscn").instantiate()
	party_board_screen.name = "PartyBoardScreen"
	$UI.add_child(party_board_screen)

	storage_screen = load("res://scenes/storage_screen.tscn").instantiate()
	storage_screen.name = "StorageScreen"
	$UI.add_child(storage_screen)

	fade_rect.color.a = 0.0

	main_menu.new_game_pressed.connect(start_new_game_flow)
	main_menu.continue_pressed.connect(load_saved_game)
	main_menu.settings_pressed.connect(func(): settings_screen.show_screen())

	hud.btn_action_pressed.connect(handle_action_press)
	hud.btn_inventory_pressed.connect(func(): inventory_screen.show_screen())
	hud.btn_status_pressed.connect(func(): status_screen.show_screen())
	hud.btn_quest_pressed.connect(func(): quest_log_screen.show_screen())
	hud.btn_menu_pressed.connect(return_to_main_menu)
	shop_screen.shop_closed.connect(_on_shop_closed)
	shop_screen.item_purchased.connect(_on_item_purchased)
	game_over_screen.restart_pressed.connect(_on_game_over_restart)
	game_over_screen.menu_pressed.connect(_on_game_over_menu)

	naming_screen.name_confirmed.connect(start_actual_game)

	map_manager = Node2D.new()
	map_manager.name = "MapManager"
	map_manager.set_script(preload("res://managers/map_manager.gd"))
	$Maps.add_child(map_manager)

	encounter_manager = Node.new()
	encounter_manager.name = "EncounterManager"
	encounter_manager.set_script(preload("res://managers/encounter_manager.gd"))
	encounter_manager.player_ref = player
	add_child(encounter_manager)

	quest_manager = Node.new()
	quest_manager.name = "QuestManager"
	quest_manager.set_script(preload("res://managers/quest_manager.gd"))
	quest_manager.dialogue_box_ref = dialogue_box
	quest_manager.hud_ref = hud
	quest_manager.encounter_manager_ref = encounter_manager
	quest_manager.map_manager_ref = map_manager
	add_child(quest_manager)

	transition_manager = Node.new()
	transition_manager.name = "TransitionManager"
	transition_manager.set_script(preload("res://managers/transition_manager.gd"))
	transition_manager.player_ref = player
	transition_manager.fade_rect_ref = fade_rect
	add_child(transition_manager)

	encounter_manager.connect("battle_started", _on_battle_started)
	quest_manager.connect("show_dialogue", _on_quest_dialogue)
	transition_manager.connect("map_changing", _on_map_changing)

	encounter_manager.spawn_wolves(map_manager.get_map_node("plains"))
	map_manager.spawn_vital_herbs()

	main_menu.show_menu()
	player.visible = false
	map_manager.set_active_map("")

func _on_quest_dialogue(steps, callback):
	GameState.emit_signal("show_dialogue", steps, callback)

func _on_battle_started(enemy_node, config):
	battle_screen.start_battle(enemy_node, config)
	if not battle_screen.battle_ended.is_connected(on_battle_ended):
		battle_screen.battle_ended.connect(on_battle_ended, CONNECT_ONE_SHOT)
	if not battle_screen.player_defeated.is_connected(_on_player_defeated):
		battle_screen.player_defeated.connect(_on_player_defeated, CONNECT_ONE_SHOT)

func _on_map_changing(map_name):
	map_manager.set_active_map(map_name)
	var target = map_manager.get_map_node(map_name)

	match map_name:
		"cabin":
			map_manager.configure_camera_limits(camera, 12, 10)
			hud.show_region_banner("Cozy Cabin (屋內)")
		"plains":
			map_manager.configure_camera_limits(camera, 32, 32)
			hud.show_region_banner("Greenridge Plains (綠原村平原)")
			if map_manager.vital_herbs_list.is_empty():
				map_manager.spawn_vital_herbs()
			if GameState.get_quest().state == 2 and encounter_manager.slimes_list.is_empty():
				encounter_manager.spawn_quest_slimes(target)
		"guild":
			hud.show_region_banner("Mercenary Guild Hall (傭兵公會)")
		"stone_claw":
			map_manager.configure_camera_limits(camera, 20, 12)
			hud.show_region_banner("Stone Claw Pass (石爪隘口)")
			if map_manager.vital_herbs_list.is_empty():
				map_manager.spawn_vital_herbs()
			if GameState.get_quest().state == 7:
				GameState.get_quest().state = 8
				encounter_manager.spawn_quest_goblins(target)
				encounter_manager.spawn_boss_goblin_chief(target, Vector2(16 * 32 + 16, 5 * 32 + 16))
				hud.update_hud()
				GameState.save_game()
				var msg = [
					{ "speaker": "System", "avatar": "⚔️", "text": "You arrive at Stone Claw Pass. Goblins and their formidable Chief lurk at the northern ridge!" }
				]
				GameState.emit_signal("show_dialogue", msg, null)
			elif GameState.get_quest().state == 8:
				encounter_manager.spawn_quest_goblins(target)
				encounter_manager.spawn_boss_goblin_chief(target, Vector2(16 * 32 + 16, 5 * 32 + 16))
		"south_forest":
			map_manager.configure_camera_limits(camera, 20, 20)
			hud.show_region_banner("Southern Forest (南部森林)")
			if map_manager.vital_herbs_list.is_empty():
				map_manager.spawn_vital_herbs()
		"mine_b1":
			map_manager.configure_camera_limits(camera, 16, 12)
			hud.show_region_banner("Stone Claw Mine - B1 (石爪礦坑 B1)")
			if encounter_manager.mine_b1_enemies.is_empty():
				encounter_manager.spawn_mine_b1_enemies(target)
		"mine_b2":
			map_manager.configure_camera_limits(camera, 16, 12)
			hud.show_region_banner("Stone Claw Mine - B2 (石爪礦坑 B2)")
			if encounter_manager.mine_b2_enemies.is_empty():
				encounter_manager.spawn_mine_b2_enemies(target)
		"mine_b3":
			map_manager.configure_camera_limits(camera, 12, 10)
			hud.show_region_banner("Stone Claw Mine - Depths (石爪礦坑 深處)")
			if not is_instance_valid(encounter_manager.golem_boss_ref):
				encounter_manager.spawn_golem_boss(target, Vector2(6 * 32 + 16, 5 * 32 + 16))
		"guild", "guild_1f":
			map_manager.configure_camera_limits(camera, 24, 18)
			hud.show_region_banner("Mercenary Guild - 1F (佣兵公會 一樓大廳)")
			if GameState.get_quest().state == 9:
				GameState.get_quest().state = 10
				hud.update_hud()
				GameState.save_game()
		"guild_2f":
			map_manager.configure_camera_limits(camera, 20, 14)
			hud.show_region_banner("Mercenary Guild - 2F (佣兵公會 二樓酒館)")
		"south_forest":
			map_manager.configure_camera_limits(camera, 20, 16)
			if encounter_manager.forest_wolves_list.is_empty():
				encounter_manager.spawn_forest_wolves(target)
			if map_manager.vital_herbs_list.is_empty():
				map_manager.spawn_vital_herbs()

func is_ui_blocked() -> bool:
	return main_menu.visible or dialogue_box.visible or naming_screen.visible or \
		   inventory_screen.visible or status_screen.visible or settings_screen.visible or \
		   shop_screen.visible or encounter_manager.in_battle or \
		   (quest_log_screen and quest_log_screen.visible) or \
		   (forge_screen and forge_screen.visible) or \
		   (recycle_screen and recycle_screen.visible) or \
		   (party_board_screen and party_board_screen.visible)

func _input(event: InputEvent):
	if naming_screen.visible:
		return

	if event.is_action_pressed("toggle_menu"):
		if inventory_screen.visible:
			inventory_screen.hide_screen()
		elif status_screen.visible:
			status_screen.hide_screen()
		elif quest_log_screen.visible:
			quest_log_screen.hide_screen()
		elif settings_screen.visible:
			settings_screen.hide_screen()
		elif not main_menu.visible:
			return_to_main_menu()
	elif event.is_action_pressed("toggle_inventory"):
		if inventory_screen.visible:
			inventory_screen.hide_screen()
		elif not is_ui_blocked():
			inventory_screen.show_screen()
	elif event.is_action_pressed("toggle_status"):
		if status_screen.visible:
			status_screen.hide_screen()
		elif not is_ui_blocked():
			status_screen.show_screen()
	elif event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_Q:
		if quest_log_screen.visible:
			quest_log_screen.hide_screen()
		elif not is_ui_blocked():
			quest_log_screen.show_screen()
	elif event.is_action_pressed("interact"):
		if dialogue_box.visible:
			dialogue_box.on_dialogue_clicked()
		elif not is_ui_blocked():
			handle_action_press()

func _physics_process(_delta):
	if is_ui_blocked():
		return

	var px = int(player.position.x / 32.0)
	var py = int(player.position.y / 32.0)

	if map_manager.current_map == "cabin":
		if py >= 9 and px == 6:
			transition_manager.transition_to("plains", Vector2(16 * 32 + 16, 12 * 32 + 16), "down")
	elif map_manager.current_map == "plains":
		if py == 11 and px == 16:
			transition_manager.transition_to("cabin", Vector2(6 * 32 + 16, 7 * 32 + 16), "up")
		if py == 11 and px == 4:
			transition_manager.transition_to("guild_1f", Vector2(12 * 32 + 16, 16 * 32 + 16), "up")
		if py == 0 and px == 16:
			transition_manager.transition_to("stone_claw", Vector2(10 * 32 + 16, 10 * 32 + 16), "up")
		if py == 31 and px == 16:
			transition_manager.transition_to("south_forest", Vector2(10 * 32 + 16, 1 * 32 + 16), "up")
	elif map_manager.current_map in ["guild", "guild_1f"]:
		if py >= 17 and (px == 11 or px == 12):
			transition_manager.transition_to("plains", Vector2(4 * 32 + 16, 12 * 32 + 16), "down")
		if py <= 1 and px >= 21:
			transition_manager.transition_to("guild_2f", Vector2(16 * 32 + 16, 2 * 32 + 16), "down")
	elif map_manager.current_map == "guild_2f":
		if py <= 1 and px >= 17:
			transition_manager.transition_to("guild_1f", Vector2(20 * 32 + 16, 2 * 32 + 16), "down")

		if not encounter_manager.in_battle:
			for slime in encounter_manager.slimes_list:
				if is_instance_valid(slime) and player.position.distance_to(slime.position) < 22:
					encounter_manager.start_battle(slime)
					break
			if encounter_manager.in_battle: return
			for wolf in encounter_manager.wolves_list:
				if is_instance_valid(wolf) and player.position.distance_to(wolf.position) < 22:
					encounter_manager.start_battle(wolf)
					break
			if encounter_manager.in_battle: return
			for goblin in encounter_manager.goblins_list:
				if is_instance_valid(goblin) and player.position.distance_to(goblin.position) < 22:
					encounter_manager.start_battle(goblin)
					break
	elif map_manager.current_map == "guild":
		if py == 11 and px == 8:
			transition_manager.transition_to("plains", Vector2(4 * 32 + 16, 14 * 32 + 16), "up")
	elif map_manager.current_map == "stone_claw":
		if py == 11 and px == 10:
			transition_manager.transition_to("plains", Vector2(16 * 32 + 16, 1 * 32 + 16), "down")
		# Mine entrance (right side of map, quest-gated)
		if py == 5 and px >= 18 and GameState.get_quest().state >= 14:
			transition_manager.transition_to("mine_b1", Vector2(8 * 32 + 16, 1 * 32 + 16), "down")
		elif py == 5 and px >= 18 and GameState.get_quest().state < 14:
			var msg = [{ "speaker": "System", "avatar": "🚫", "text": "A collapsed mine entrance. It looks like it could be cleared, but you'd need a reason to go in..." }]
			GameState.emit_signal("show_dialogue", msg, null)

		if not encounter_manager.in_battle:
			if is_instance_valid(encounter_manager.boss_ref) and player.position.distance_to(encounter_manager.boss_ref.position) < 32:
				encounter_manager.start_battle(encounter_manager.boss_ref)
			else:
				for goblin in encounter_manager.goblins_list:
					if is_instance_valid(goblin) and player.position.distance_to(goblin.position) < 22:
						encounter_manager.start_battle(goblin)
						break
	elif map_manager.current_map == "mine_b1":
		# Exit back to Stone Claw
		if py == 0 and px == 8:
			transition_manager.transition_to("stone_claw", Vector2(18 * 32 + 16, 5 * 32 + 16), "down")
		# Stairs down to B2
		if py >= 10 and px == 12:
			transition_manager.transition_to("mine_b2", Vector2(3 * 32 + 16, 1 * 32 + 16), "down")

		if not encounter_manager.in_battle:
			for bat in encounter_manager.mine_b1_enemies:
				if is_instance_valid(bat) and player.position.distance_to(bat.position) < 22:
					encounter_manager.start_battle(bat)
					break

	elif map_manager.current_map == "mine_b2":
		# Stairs up to B1
		if py == 0 and px == 3:
			transition_manager.transition_to("mine_b1", Vector2(12 * 32 + 16, 10 * 32 + 16), "up")
		# Stairs down to B3
		if py >= 10 and px == 8:
			transition_manager.transition_to("mine_b3", Vector2(3 * 32 + 16, 1 * 32 + 16), "down")

		if not encounter_manager.in_battle:
			for spider in encounter_manager.mine_b2_enemies:
				if is_instance_valid(spider) and player.position.distance_to(spider.position) < 22:
					encounter_manager.start_battle(spider)
					break

	elif map_manager.current_map == "mine_b3":
		# Stairs up to B2
		if py == 0 and px == 3:
			transition_manager.transition_to("mine_b2", Vector2(8 * 32 + 16, 10 * 32 + 16), "up")

		# BOSS trigger (center altar)
		if not encounter_manager.in_battle and is_instance_valid(encounter_manager.golem_boss_ref):
			if player.position.distance_to(Vector2(6 * 32 + 16, 5 * 32 + 16)) < 48:
				encounter_manager.start_battle(encounter_manager.golem_boss_ref)

	elif map_manager.current_map == "south_forest":
		if py == 0 and px == 10:
			transition_manager.transition_to("plains", Vector2(16 * 32 + 16, 30 * 32 + 16), "up")

		if not encounter_manager.in_battle:
			for wolf in encounter_manager.forest_wolves_list:
				if is_instance_valid(wolf) and player.position.distance_to(wolf.position) < 22:
					encounter_manager.start_battle(wolf)
					break

func handle_action_press():
	if dialogue_box.visible:
		return

	if map_manager.current_map == "cabin":
		var lina_pos = Vector2(6 * 32 + 16, 4 * 32 + 16)
		if player.position.distance_to(lina_pos) < 45:
			quest_manager.trigger_lina_dialogue()
			return

		var bed_pos = Vector2(2 * 32 + 16, 2 * 32 + 32)
		if player.position.distance_to(bed_pos) < 40:
			var p = GameState.get_player()
			if p.hp < p.max_hp or p.mp < p.max_mp:
				p.hp = p.max_hp
				p.mp = p.max_mp
				var msg = [{ "speaker": "System", "avatar": "🛏️", "text": "You lie down and rest. HP and MP fully restored!" }]
				GameState.emit_signal("show_dialogue", msg, func():
					hud.update_hud()
					GameState.save_game()
				)
			else:
				var msg = [{ "speaker": "System", "avatar": "🛏️", "text": "You're not tired yet. Your HP and MP are already full." }]
				GameState.emit_signal("show_dialogue", msg, null)
			return

	elif map_manager.current_map == "plains":
		var horn_pos = Vector2(2 * 32 + 16, 11 * 32 + 16)
		if player.position.distance_to(horn_pos) < 50:
			quest_manager.trigger_broadcast_horn_dialogue()
			return

		var board_pos = Vector2(18 * 32 + 16, 13 * 32 + 16)
		if player.position.distance_to(board_pos) < 45:
			quest_manager.trigger_board_dialogue()
			return

		for herb in map_manager.herbs_list:
			if is_instance_valid(herb) and player.position.distance_to(herb.position) < 24:
				herb.collect()
				return

		for herb in map_manager.vital_herbs_list:
			if is_instance_valid(herb) and player.position.distance_to(herb.position) < 24:
				herb.collect()
				return
				
		for bush in map_manager.fruit_bushes_list:
			if is_instance_valid(bush) and player.position.distance_to(bush.position) < 32:
				if bush.has_method("collect"):
					bush.collect()
				return

	elif map_manager.current_map in ["guild", "guild_1f"]:
		# Receptionist
		var receptionist_pos = Vector2(10 * 32 + 32, 2 * 32 - 4)
		if player.position.distance_to(receptionist_pos) < 50:
			quest_manager.trigger_guild_dialogue()
			return

		# Bulletin Board
		var board_pos = Vector2(4 * 32 + 16, 2 * 32 + 16)
		if player.position.distance_to(board_pos) < 40:
			quest_manager.trigger_board_dialogue()
			return

		# Honor Wall
		var honor_pos = Vector2(2 * 32 + 16, 2 * 32 + 16)
		if player.position.distance_to(honor_pos) < 40:
			quest_manager.trigger_honor_wall_dialogue()
			return

		# Mage Lily
		var lily_pos = Vector2(3 * 32 + 16, 5 * 32 + 8)
		if player.position.distance_to(lily_pos) < 45:
			quest_manager.trigger_mage_lily_dialogue()
			return

		# Training Dummy (Damage Test)
		var dummy_pos = Vector2(6 * 32 + 16, 14 * 32 + 16)
		if player.position.distance_to(dummy_pos) < 45:
			var total_atk = GameState.get_total_atk()
			var p = GameState.get_player()
			var bonus = total_atk - p.base_atk
			var msg = [{ "speaker": "Training Dummy", "avatar": "🎯", "text": "🎯 [b]TRAINING DUMMY HIT![/b]\nBase ATK: " + str(p.base_atk) + " | Gear Bonus: +" + str(bonus) + "\nTotal Damage Output: [b][color=#ffeb3b]" + str(total_atk) + "[/color][/b]" }]
			GameState.emit_signal("show_dialogue", msg, null)
			return

		# Apprentice Pip
		var pip_pos = Vector2(5 * 32 + 16, 12 * 32 + 8)
		if player.position.distance_to(pip_pos) < 45:
			quest_manager.trigger_apprentice_pip_dialogue()
			return

		# Blacksmith
		var blacksmith_pos = Vector2(3 * 32 + 16, 12 * 32 - 4)
		if player.position.distance_to(blacksmith_pos) < 50:
			if GameState.get_quest().state >= 10:
				forge_screen.show_screen()
			else:
				quest_manager.trigger_blacksmith_dialogue()
			return

		# Party Board
		var party_pos = Vector2(16 * 32 + 16, 2 * 32 + 16)
		if player.position.distance_to(party_pos) < 45:
			party_board_screen.show_screen()
			return

		# Storage Chest
		var storage_pos = Vector2(18 * 32 + 16, 2 * 32 + 16)
		if player.position.distance_to(storage_pos) < 45:
			storage_screen.show_screen()
			return

		# Ranger Tom
		var tom_pos = Vector2(17 * 32 + 16, 4 * 32 + 8)
		if player.position.distance_to(tom_pos) < 45:
			quest_manager.trigger_ranger_tom_dialogue()
			return

		# Shopkeeper
		var shopkeeper_pos = Vector2(17 * 32 + 32, 6 * 32 - 4)
		if player.position.distance_to(shopkeeper_pos) < 50:
			if GameState.get_quest().state >= 10:
				shop_screen.show_screen()
			else:
				var msg = [{ "speaker": "Shopkeeper", "avatar": "🛒", "text": "Welcome! Feel free to browse once you've registered with the guild." }]
				GameState.emit_signal("show_dialogue", msg, null)
			return

		# Appraiser
		var appraiser_pos = Vector2(17 * 32 + 32, 12 * 32 - 4)
		if player.position.distance_to(appraiser_pos) < 50:
			recycle_screen.show_screen()
			return

	elif map_manager.current_map == "guild_2f":
		# Bartender
		var bartender_pos = Vector2(5 * 32 + 32, 2 * 32 - 4)
		if player.position.distance_to(bartender_pos) < 50:
			quest_manager.trigger_bartender_dialogue()
			return

		# Bard Orpheus
		var bard_pos = Vector2(11 * 32 + 16, 2 * 32 + 8)
		if player.position.distance_to(bard_pos) < 45:
			quest_manager.trigger_bard_orpheus_dialogue()
			return

		# Information Broker
		var broker_pos = Vector2(2 * 32 + 16, 10 * 32 + 8)
		if player.position.distance_to(broker_pos) < 45:
			quest_manager.trigger_information_broker_dialogue()
			return

		# Garrick
		var garrick_pos = Vector2(4 * 32 + 16, 6 * 32 + 16)
		if player.position.distance_to(garrick_pos) < 50:
			quest_manager.trigger_mentor_dialogue()
			return

		# Merchant Hans
		var hans_pos = Vector2(12 * 32 + 16, 6 * 32 + 16)
		if player.position.distance_to(hans_pos) < 50:
			quest_manager.trigger_hans_dialogue()
			return

		# Clara
		var clara_pos = Vector2(8 * 32 + 16, 9 * 32 + 16)
		if player.position.distance_to(clara_pos) < 50:
			quest_manager.trigger_clara_dialogue()
			return

	elif map_manager.current_map == "stone_claw":
		var sign_pos = Vector2(8 * 32 + 16, 9 * 32 + 16)
		if player.position.distance_to(sign_pos) < 45:
			var steps = [
				{ "speaker": "Sign", "avatar": "🪧", "text": "[b]Stone Claw Pass[/b]\nElevation: 840m\nWatch for goblin ambushes. Travel in groups recommended.\n— Asterra Territorial Authority" }
			]
			GameState.emit_signal("show_dialogue", steps, null)
			return

		for herb in map_manager.vital_herbs_list:
			if is_instance_valid(herb) and player.position.distance_to(herb.position) < 24:
				herb.collect()

	elif map_manager.current_map in ["mine_b1", "mine_b2", "mine_b3"]:
		for ore in map_manager.ore_veins_list:
			if is_instance_valid(ore) and player.position.distance_to(ore.position) < 28:
				if ore.has_method("collect"):
					ore.collect()
				return

	elif map_manager.current_map == "south_forest":
		var sign_pos = Vector2(8 * 32 + 16, 1 * 32 + 24)
		if player.position.distance_to(sign_pos) < 45:
			var steps = [
				{ "speaker": "Sign", "avatar": "🪧", "text": "[b]Southern Forest[/b]\nWarning: Large wolf packs have been sighted in these woods.\nProceed with caution. — Asterra Territorial Authority" }
			]
			GameState.emit_signal("show_dialogue", steps, null)
			return

		for herb in map_manager.vital_herbs_list:
			if is_instance_valid(herb) and player.position.distance_to(herb.position) < 24:
				herb.collect()

func start_new_game_flow():
	main_menu.hide_menu()
	naming_screen.show_screen()

func start_actual_game():
	main_menu.hide_menu()
	naming_screen.hide_screen()
	hud.visible = true
	player.visible = true

	var focus_owner = get_viewport().gui_get_focus_owner()
	if focus_owner:
		focus_owner.release_focus()

	map_manager.set_active_map("cabin")

	map_manager.configure_camera_limits(camera, 12, 10)

	player.position = Vector2(5 * 32 + 16, 5 * 32 + 16)
	player.dir = "down"

	hud.update_hud()
	Audio.play_bgm()

	get_tree().create_timer(1.0).timeout.connect(func():
		var steps = [
			{ "speaker": "Lina", "avatar": "lina", "text": "Morning, " + GameState.get_player().name + "! You are finally awake." },
			{ "speaker": "Lina", "avatar": "lina", "text": "I was looking at our pantry... we are almost completely out of food, and we only have a few copper coins left." },
			{ "speaker": "Lina", "avatar": "lina", "text": "Since you registered as an E-Rank mercenary, maybe you could go outside to the plains and check the Bulletin Board for a simple job?" },
			{ "speaker": GameState.get_player().name, "avatar": "protagonist", "text": "Don't worry, Lina. I will make sure we get through this. I will go check the board right now." },
			{ "speaker": "Lina", "avatar": "lina", "text": "Thank you! Please be careful. There have been reports of wild slimes bouncing around nearby." }
		]
		GameState.emit_signal("show_dialogue", steps, func():
			GameState.get_quest().state = 1
			hud.update_hud()
			GameState.save_game()
		)
	)

func load_saved_game():
	if GameState.load_game():
		main_menu.hide_menu()
		hud.visible = true
		player.visible = true

		var focus_owner = get_viewport().gui_get_focus_owner()
		if focus_owner:
			focus_owner.release_focus()

		var loc = GameState.get_location()
		var target_map = loc.get("map", "cabin")
		map_manager.set_active_map(target_map)
		player.position = Vector2(loc.get("x", 176.0), loc.get("y", 176.0))

		match target_map:
			"cabin": map_manager.configure_camera_limits(camera, 12, 10)
			"plains": map_manager.configure_camera_limits(camera, 32, 32)
			"stone_claw": map_manager.configure_camera_limits(camera, 20, 12)
			"guild", "guild_1f": map_manager.configure_camera_limits(camera, 24, 18)
			"guild_2f": map_manager.configure_camera_limits(camera, 20, 14)
			_: map_manager.configure_camera_limits(camera, 20, 20)

		if GameState.get_quest().state == 2:
			encounter_manager.spawn_quest_slimes(map_manager.get_map_node("plains"))

		hud.update_hud()
		Audio.play_bgm()

func return_to_main_menu():
	GameState.save_game()
	dialogue_box.hide_box()
	hud.visible = false
	player.visible = false

	map_manager.set_active_map("")

	main_menu.show_menu()

func on_battle_ended(won: bool, rewards: Dictionary):
	encounter_manager.in_battle = false

	if won:
		if rewards.get("type") == "slime" and GameState.get_quest().state == 2:
			GameState.get_quest().slimes_killed += 1
			if GameState.get_quest().slimes_killed >= GameState.get_quest().slimes_required:
				GameState.get_quest().state = 3
			GameState.save_game()

		if rewards.get("type") == "goblin" and GameState.get_quest().state == 8:
			GameState.get_quest().goblins_killed += 1
			if GameState.get_quest().goblins_killed >= GameState.get_quest().goblins_required:
				GameState.get_quest().state = 9
				GameState.modify_gold(60)
				GameState.add_exp(80)
			GameState.save_game()

		if rewards.get("type") == "stone_golem" and GameState.get_quest().state == 14:
			GameState.get_quest().state = 15
			GameState.modify_gold(150)
			GameState.add_exp(300)
			GameState.save_game()

		encounter_manager.cleanup_dead()

		var loot_names = []
		for drop in rewards.get("loot", []):
			loot_names.append(drop.get("name", "?"))
		var loot_str = ", ".join(loot_names) if loot_names.size() > 0 else "nothing"

		var steps = [
			{ "speaker": "System", "avatar": "✨", "text": "Victory! Earned " + str(rewards.get("exp", 0)) + " EXP and " + str(rewards.get("gold", 0)) + " Gold!\nLoot: " + loot_str }
		]
		GameState.emit_signal("show_dialogue", steps, null)

		if encounter_manager.wolves_list.size() < 2:
			get_tree().create_timer(15.0).timeout.connect(func():
				if map_manager.current_map == "plains":
					encounter_manager.spawn_wolves(map_manager.get_map_node("plains"))
			)

		if encounter_manager.forest_wolves_list.size() < 2:
			get_tree().create_timer(15.0).timeout.connect(func():
				if map_manager.current_map == "south_forest":
					encounter_manager.spawn_forest_wolves(map_manager.get_map_node("south_forest"))
			)

	hud.update_hud()

var _shop_purchased := false

func _on_item_purchased():
	_shop_purchased = true

func _on_shop_closed():
	if GameState.get_quest().state == 11 and _shop_purchased:
		GameState.get_quest().state = 12
		hud.update_hud()
		GameState.save_game()
	_shop_purchased = false

func _on_player_defeated():
	encounter_manager.in_battle = false
	game_over_screen.show_screen()

func _on_game_over_restart():
	GameState.reset_player(1.0)
	hud.update_hud()
	start_actual_game()

func _on_game_over_menu():
	GameState.reset_player(1.0)
	return_to_main_menu()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if main_menu.visible or naming_screen.visible:
			return
		if dialogue_box.visible:
			return
		if pause_menu:
			if pause_menu.visible:
				pause_menu.close_menu()
			else:
				pause_menu.open_menu()
