extends Node

signal show_dialogue(steps, callback)

var dialogue_box_ref: Node
var hud_ref: CanvasLayer
var encounter_manager_ref: Node
var map_manager_ref: Node

func trigger_lina_dialogue():
	var state = GameState.get_quest().state
	if state == 4:
		var steps = [
			{ "speaker": "Lina", "avatar": "lina", "text": "Welcome back, brother! Did you find a job?" },
			{ "speaker": GameState.get_player().name, "avatar": "protagonist", "text": "Yes! I cleared the slimes near the village boundaries. The guild paid me 50 gold coins!" },
			{ "speaker": "Lina", "avatar": "lina", "text": "Wow, 50 gold! That's amazing. We can buy enough bread and dried meat to last for weeks!" },
			{ "speaker": "Lina", "avatar": "lina", "text": "Let me dress your clothes and mend your wear. Please rest for a bit." },
			{ "speaker": "System", "avatar": "✨", "text": "Lina's care has fully restored your HP and MP!" },
			{ "speaker": "Lina", "avatar": "lina", "text": "I believe in you, brother. One day, you will become the World's Strongest Mercenary!" }
		]
		emit_signal("show_dialogue", steps, func():
			var p = GameState.get_player()
			p.hp = p.max_hp
			p.mp = p.max_mp
			GameState.get_quest().state = 5
			hud_ref.update_hud()
			GameState.save_game()
		)
	elif state == 5:
		var steps = [
			{ "speaker": "Lina", "avatar": "lina", "text": "Take care out there, brother! Remember to equip your gear in the Inventory [I] before fighting monsters!" }
		]
		emit_signal("show_dialogue", steps, null)
	elif state == 11:
		var steps = [
			{ "speaker": "Lina", "avatar": "lina", "text": "Hey brother! Did you check out the Weapon Shop in town? I heard they have some great deals on iron swords!" },
			{ "speaker": GameState.get_player().name, "avatar": "protagonist", "text": "Good idea, Lina. I'll head over and see what they've got before my next job." }
		]
		emit_signal("show_dialogue", steps, null)
	elif state == 12:
		var steps = [
			{ "speaker": "Lina", "avatar": "lina", "text": "Brother! You're back! I heard from the villagers that you escorted a caravan through Stone Claw Pass!" },
			{ "speaker": GameState.get_player().name, "avatar": "protagonist", "text": "Yeah, it was rough — fought off a whole goblin ambush with an old mercenary named Garrick." },
			{ "speaker": "Lina", "avatar": "lina", "text": "Goblins?! Are you hurt?! Let me check your wounds!" },
			{ "speaker": GameState.get_player().name, "avatar": "protagonist", "text": "I'm fine, Lina. Thanks to the new gear I bought with the reward money." },
			{ "speaker": "Lina", "avatar": "lina", "text": "You've changed, brother. You look stronger already. I'm so proud of you." },
			{ "speaker": "Lina", "avatar": "lina", "text": "Promise me you'll keep coming home safe, okay?" },
			{ "speaker": GameState.get_player().name, "avatar": "protagonist", "text": "I promise, Lina. I'll become the World's Strongest Mercenary — for both of us." },
			{ "speaker": "System", "avatar": "✨", "text": "Chapter 2 Complete! Enjoy Free Play.\nTip: Wander the plains, fight monsters, and test your new gear!" }
		]
		emit_signal("show_dialogue", steps, func():
			var p = GameState.get_player()
			p.hp = p.max_hp
			p.mp = p.max_mp
			GameState.get_quest().state = 13
			hud_ref.update_hud()
			GameState.save_game()
		)
	else:
		var greetings = [
			[
				{ "speaker": "Lina", "avatar": "lina", "text": "Good morning, brother! Did you sleep well? The porridge is on the table if you're hungry." }
			],
			[
				{ "speaker": "Lina", "avatar": "lina", "text": "Hey, " + GameState.get_player().name + "! Be careful out there, okay? Check the Bulletin Board outside to see how we can earn some gold." }
			],
			[
				{ "speaker": "Lina", "avatar": "lina", "text": "Brother! I just finished mending your spare cloak. It should keep you warm on long hunts." },
				{ "speaker": GameState.get_player().name, "avatar": "protagonist", "text": "Thanks, Lina. I don't know what I'd do without you." },
				{ "speaker": "Lina", "avatar": "lina", "text": "You'd probably freeze! Now go earn us some gold, hero!" }
			],
			[
				{ "speaker": "Lina", "avatar": "lina", "text": "I heard wolves have been spotted near the village. Please be careful if you go out!" }
			],
			[
				{ "speaker": "Lina", "avatar": "lina", "text": "You know, one day when you become the World's Strongest Mercenary, we should move to a bigger house!" },
				{ "speaker": GameState.get_player().name, "avatar": "protagonist", "text": "Haha, I'll build you a mansion, Lina. That's a promise." }
			]
		]
		var picked = greetings[randi() % greetings.size()]
		emit_signal("show_dialogue", picked, null)

func trigger_guild_dialogue():
	var state = GameState.get_quest().state
	if state == 5:
		var steps = [
			{ "speaker": "Guild Receptionist", "avatar": "📋", "text": "Welcome to the Asterra Mercenary Guild! How can I help you today?" },
			{ "speaker": GameState.get_player().name, "avatar": "protagonist", "text": "I just got promoted to D-Rank. I was told I should check in at the guild." },
			{ "speaker": "Guild Receptionist", "avatar": "📋", "text": "Ah, a fresh D-Rank! Congratulations. D-Rank opens up much better commissions — and bigger risks." },
			{ "speaker": "Guild Receptionist", "avatar": "📋", "text": "Take a look around. You might find a seasoned mercenary willing to show you the ropes. Good luck out there!" },
			{ "speaker": "System", "avatar": "✨", "text": "Quest Updated: Talk to the experienced mercenary at the table." }
		]
		emit_signal("show_dialogue", steps, func():
			GameState.get_quest().state = 6
			hud_ref.update_hud()
			GameState.save_game()
		)
	elif state == 10:
		var steps = [
			{ "speaker": "Guild Receptionist", "avatar": "📋", "text": "Welcome back! I heard you handled the goblin situation at Stone Claw Pass. Impressive work for a newly-promoted D-Rank!" },
			{ "speaker": GameState.get_player().name, "avatar": "protagonist", "text": "It was a good fight. The merchant paid well too." },
			{ "speaker": "Guild Receptionist", "avatar": "📋", "text": "Speaking of payment — you should visit the Weapon Shop and upgrade your gear. You'll need better equipment for higher-ranked quests." },
			{ "speaker": "System", "avatar": "✨", "text": "Quest Updated: Visit the Weapon Shop to gear up." }
		]
		emit_signal("show_dialogue", steps, func():
			GameState.get_quest().state = 11
			hud_ref.update_hud()
			GameState.save_game()
		)
	elif state == 11 or state == 12 or state == 13:
		var steps = [
			{ "speaker": "Guild Receptionist", "avatar": "📋", "text": "Getting stronger every day, I see. Keep it up, and you'll be C-Rank before you know it!" }
		]
		emit_signal("show_dialogue", steps, null)
	else:
		trigger_idle_guild()

func trigger_idle_guild():
	var greetings = [
		[{ "speaker": "Guild Receptionist", "avatar": "📋", "text": "Welcome to the guild. The quest board is on the wall if you need a commission." }],
		[{ "speaker": "Guild Receptionist", "avatar": "📋", "text": "Busy day today. Lots of adventurers coming and going." }],
		[{ "speaker": "Guild Receptionist", "avatar": "📋", "text": "Make sure to register any completed quests at the counter!" }]
	]
	emit_signal("show_dialogue", greetings[randi() % greetings.size()], null)

func trigger_mentor_dialogue():
	var state = GameState.get_quest().state
	if state == 6:
		var steps = [
			{ "speaker": "Veteran Mercenary", "avatar": "⚔️", "text": "Hey, kid. You're the new D-Rank, right? Name's Garrick. I've been doing this job for twenty years." },
			{ "speaker": "Veteran Mercenary", "avatar": "⚔️", "text": "I need a hand with a caravan escort to Stone Claw Pass. The merchant pays 60 gold — I'll split it with you." },
			{ "speaker": GameState.get_player().name, "avatar": "protagonist", "text": "Stone Claw Pass? I heard there have been goblin sightings there." },
			{ "speaker": "Veteran Mercenary", "avatar": "⚔️", "text": "Exactly why I need backup. A few goblins won't be a problem for two experienced fighters. What do you say?" },
			{
				"speaker": "Veteran Mercenary",
				"avatar": "⚔️",
				"text": "Ready to earn your first real payday?",
				"choices": [
					{ "text": "Accept the Escort Quest", "action": func(): accept_escort_quest() },
					{ "text": "Not yet, maybe later", "action": func(): dialogue_box_ref.close_dialogue() }
				]
			}
		]
		emit_signal("show_dialogue", steps, null)
	else:
		var idle = [
			[{ "speaker": "Veteran Mercenary", "avatar": "⚔️", "text": "Garrick's the name. If you ever need backup on a job, I'm your man." }],
			[{ "speaker": "Veteran Mercenary", "avatar": "⚔️", "text": "Stone Claw Pass is no joke. Make sure your gear is up to snuff before heading there." }],
			[{ "speaker": "Veteran Mercenary", "avatar": "⚔️", "text": "Hah, I remember my first D-Rank job. Feels like yesterday." }]
		]
		emit_signal("show_dialogue", idle[randi() % idle.size()], null)

func accept_escort_quest():
	dialogue_box_ref.close_dialogue()
	GameState.get_quest().state = 7
	GameState.get_quest().goblins_killed = 0
	hud_ref.update_hud()
	GameState.save_game()

	var steps = [
		{ "speaker": "Veteran Mercenary", "avatar": "⚔️", "text": "Good choice, kid! We head out at dawn. Meet me at Stone Claw Pass — head north from here through the plains gate, just past the outer plains." },
		{ "speaker": "System", "avatar": "✨", "text": "Quest Accepted: Caravan Escort to Stone Claw Pass.\nObjective: Head north through the plains gate to Stone Claw Pass. Goblins have been reported in the area." }
	]
	emit_signal("show_dialogue", steps, null)

func trigger_board_dialogue():
	var state = GameState.get_quest().state
	if state == 1:
		var steps = [
			{ "speaker": "Bulletin Board", "avatar": "📜", "text": "====== MERCENARY GUILD COMMISSION ======" },
			{ "speaker": "Bulletin Board", "avatar": "📜", "text": "Commission [E-Rank]: Slime Threat in the Outskirts\nDescription: Defeat 3 annoying wild slimes nearby.\nReward: 50 Gold, +10 Mercenary Reputation." },
			{
				"speaker": "Bulletin Board",
				"avatar": "📜",
				"text": "Do you accept this commission?",
				"choices": [
					{ "text": "Accept Quest", "action": func(): accept_commission() },
					{ "text": "Leave it", "action": func(): dialogue_box_ref.close_dialogue() }
				]
			}
		]
		emit_signal("show_dialogue", steps, null)
	elif state == 2:
		var steps = [
			{ "speaker": "Bulletin Board", "avatar": "📜", "text": "Quest Status: Defeat Slimes (" + str(GameState.get_quest().slimes_killed) + "/" + str(GameState.get_quest().slimes_required) + ")." },
			{ "speaker": "Bulletin Board", "avatar": "📜", "text": "Please return after defeating 3 slimes." }
		]
		emit_signal("show_dialogue", steps, null)
	elif state == 3:
		var steps = [
			{ "speaker": "Bulletin Board", "avatar": "📜", "text": "====== COMMISSION COMPLETED ======" },
			{ "speaker": "Bulletin Board", "avatar": "📜", "text": "You have successfully eliminated 3 Slimes. Thank you for your service!" },
			{ "speaker": "Bulletin Board", "avatar": "📜", "text": "Received Reward: 50 Gold, +10 Mercenary Reputation!" }
		]
		emit_signal("show_dialogue", steps, func():
			GameState.modify_gold(50)
			GameState.get_player().reputation += 10
			GameState.get_quest().state = 4
			hud_ref.update_hud()
			GameState.save_game()
		)
	elif state >= 5:
		# Show side quest bounty board
		_show_bounty_board()
	else:
		var steps = [
			{ "speaker": "Bulletin Board", "avatar": "📜", "text": "No active E-rank quests currently available. Great job, rookie!" }
		]
		emit_signal("show_dialogue", steps, null)

func _show_bounty_board():
	# Check for completable side quests first
	var completed_any = false
	for q in GameState.get_active_side_quests():
		if q.current_qty >= q.target_qty:
			var result = GameState.complete_side_quest(q.id)
			if result.size() > 0:
				var steps = [
					{ "speaker": "Bulletin Board", "avatar": "📜", "text": "====== BOUNTY COMPLETED ======" },
					{ "speaker": "Bulletin Board", "avatar": "📜", "text": "Bounty [b]" + result.title + "[/b] fulfilled!\nReward: " + str(result.gold_reward) + " Gold, " + str(result.exp_reward) + " EXP!" }
				]
				emit_signal("show_dialogue", steps, func():
					hud_ref.update_hud()
				)
				completed_any = true
				break

	if completed_any:
		return

	# Show active bounties status
	var active = GameState.get_active_side_quests()
	if active.size() > 0:
		var status_lines = ""
		for q in active:
			status_lines += "• " + q.title + " (" + str(q.current_qty) + "/" + str(q.target_qty) + ")\n"
		var steps = [
			{ "speaker": "Bulletin Board", "avatar": "📜", "text": "====== ACTIVE BOUNTIES ======\n" + status_lines },
			{
				"speaker": "Bulletin Board",
				"avatar": "📜",
				"text": "Would you like to take on another bounty?",
				"choices": [
					{ "text": "View available bounties", "action": func(): _show_available_bounties() },
					{ "text": "Leave", "action": func(): dialogue_box_ref.close_dialogue() }
				]
			}
		]
		emit_signal("show_dialogue", steps, null)
	else:
		_show_available_bounties()

func _show_available_bounties():
	dialogue_box_ref.close_dialogue()
	var bounties = GameState.get_available_bounties()
	var available = []
	for b in bounties:
		if not GameState.has_side_quest(b.id):
			available.append(b)

	if available.is_empty():
		var empty_steps = [
			{ "speaker": "Bulletin Board", "avatar": "📜", "text": "No new bounties available right now. Check back later!" }
		]
		emit_signal("show_dialogue", empty_steps, null)
		return

	var choices = []
	for b in available:
		var bounty_ref = b
		choices.append({
			"text": b.title + " (" + str(b.gold_reward) + "G, " + str(b.exp_reward) + "EXP)",
			"action": func(): _accept_bounty(bounty_ref)
		})
	choices.append({ "text": "Leave", "action": func(): dialogue_box_ref.close_dialogue() })

	var steps = [
		{ "speaker": "Bulletin Board", "avatar": "📜", "text": "====== AVAILABLE BOUNTIES ======" },
	]
	for b in available:
		steps.append({ "speaker": "Bulletin Board", "avatar": "📜", "text": "📋 [b]" + b.title + "[/b]\n" + b.description + "\nReward: " + str(b.gold_reward) + " Gold, " + str(b.exp_reward) + " EXP" })
	steps.append({
		"speaker": "Bulletin Board",
		"avatar": "📜",
		"text": "Which bounty would you like to accept?",
		"choices": choices
	})
	emit_signal("show_dialogue", steps, null)

func _accept_bounty(bounty: Dictionary):
	dialogue_box_ref.close_dialogue()
	GameState.accept_side_quest(bounty)
	var steps = [
		{ "speaker": "System", "avatar": "✨", "text": "Bounty accepted: [b]" + bounty.title + "[/b]!\n" + bounty.description },
		{ "speaker": GameState.get_player().name, "avatar": "protagonist", "text": "Alright, time to get to work!" }
	]
	emit_signal("show_dialogue", steps, func():
		hud_ref.update_hud()
	)

func accept_commission():
	dialogue_box_ref.close_dialogue()
	GameState.get_quest().state = 2
	GameState.get_quest().slimes_killed = 0
	hud_ref.update_hud()
	GameState.save_game()

	encounter_manager_ref.spawn_quest_slimes(map_manager_ref.get_map_node("plains"))

	var steps = [
		{ "speaker": GameState.get_player().name, "avatar": "protagonist", "text": "Alright, 3 slimes. Time to equip my Rusty Sword from the inventory and defeat them!" }
	]
	emit_signal("show_dialogue", steps, null)
