# ⚔️ ASTERRA — The Legend of World's Strongest Mercenary

<div align="center">

[![Godot Engine](https://img.shields.io/badge/Godot-4.0-478cbf?logo=godot-engine&logoColor=white&style=for-the-badge)](https://godotengine.org)
[![License](https://img.shields.io/badge/License-MIT-8d6e63?style=for-the-badge)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-HTML5%20|%20Windows%20|%20Linux-448f30?style=for-the-badge)]()
[![Status](https://img.shields.io/badge/Status-Active%20Development-e0b034?style=for-the-badge)]()

```
  █████╗ ███████╗████████╗███████╗██████╗ ██████╗  █████╗
 ██╔══██╗██╔════╝╚══██╔══╝██╔════╝██╔══██╗██╔══██╗██╔══██╗
 ███████║███████╗   ██║   █████╗  ██████╔╝██████╔╝███████║
 ██╔══██║╚════██║   ██║   ██╔══╝  ██╔══██╗██╔══██╗██╔══██║
 ██║  ██║███████║   ██║   ███████╗██║  ██║██║  ██║██║  ██║
 ╚═╝  ╚═╝╚══════╝   ╚═╝   ╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝
```

**A retro pixel-art RPG built with Godot Engine 4.0**

*Embark on a journey as a young E-Rank mercenary striving to protect your family, earn your keep, and rise through the ranks to become the World's Strongest Mercenary!*

</div>

---

## 📖 Story

> *The continent of **Asterra** is vast and unforgiving. After a disaster that destroyed their home village, siblings **Alex** (you) and **Lina** have taken refuge in a small, remote cabin on the edge of the wilderness. Resources are scarce — the pantry is nearly empty, and only a few copper coins remain.*
>
> *Having recently registered as an **E-Rank Mercenary**, you must take on dangerous commissions, gather resources from the wild plains, and fight monsters to earn gold and reputation. Your sister Lina believes in you. Don't let her down.*

---

## 🎮 Features

<table>
<tr>
<td>

### ⚔️ Combat & Progression
- Real-time action combat with sword slash effects
- Slay slimes for gold, EXP, and reputation
- Level-up system with rank progression (E → D → ...)
- Equipment system (weapons, armor, accessories)
- Damage numbers, hit particles, HP bar indicators

</td>
<td>

### 🗺️ Exploration
- Two hand-crafted maps: **Cabin Interior** & **Wild Plains**
- Smooth map transitions with fade effects
- Procedural pixel-art tile generation
- Interactive objects: bed, table, fireplace, bulletin board
- Healing herbs to gather in the wild

</td>
</tr>
<tr>
<td>

### 📜 Quest System
- Full quest flow with dialogue-driven narrative
- Bulletin board commission system
- Quest tracker HUD with progress updates
- Multiple quest states with branching dialogue
- Save/load game progress

</td>
<td>

### 🎨 Visual & Audio
- **100% procedurally generated pixel art** — no external assets!
- Animated 4-directional character sprites
- 8-bit synthesized sound effects (AUDIO GENERATED IN CODE)
- Typewriter dialogue with adjustable speed
- Dark-themed modern UI with glassmorphic panels

</td>
</tr>
</table>

---

## 🎯 Quest Flow

```
                  ┌──────────────────────┐
                  │   Game Starts:        │
                  │   Wake up in cabin    │
                  └──────────┬───────────┘
                             │
                             ▼
                  ┌──────────────────────┐
                  │  Talk to Sister Lina  │
                  │  "We need money..."   │
                  └──────────┬───────────┘
                             │
                             ▼
                  ┌──────────────────────┐
                  │  Go Outside → Check   │
                  │  the Bulletin Board   │
                  └──────────┬───────────┘
                             │
                    ┌────────┴────────┐
                    ▼                 ▼
           ┌────────────────┐  ┌──────────────┐
           │ Accept Quest:  │  │ Decline &    │
           │ Kill 3 Slimes  │  │ wander free  │
           └────────┬───────┘  └──────────────┘
                    │
                    ▼
           ┌────────────────┐
           │  Fight Slimes  │
           │  in the Plains │
           │  (3/3)         │
           └────────┬───────┘
                    │
                    ▼
           ┌────────────────┐
           │ Report to      │
           │ Bulletin Board │
           │ → +50 Gold     │
           │ → +10 Rep      │
           └────────┬───────┘
                    │
                    ▼
           ┌────────────────┐
           │ Return to Lina │
           │ → HP/MP Full   │
           │ Restore        │
           └────────┬───────┘
                    │
                    ▼
           ┌──────────────────────────┐
           │ ★ Free Play Mode ★      │
           │ Explore, level up,       │
           │ become the strongest!    │
           └──────────────────────────┘
```

---

## 🎮 Controls

| Key | Action |
|:---:|:------:|
| <kbd>W</kbd> <kbd>A</kbd> <kbd>S</kbd> <kbd>D</kbd> | Move character |
| <kbd>↑</kbd> <kbd>←</kbd> <kbd>↓</kbd> <kbd>→</kbd> | Move character |
| <kbd>E</kbd> / <kbd>Space</kbd> | Interact / Attack / Advance dialogue |
| <kbd>I</kbd> | Open inventory (Backpack) |
| <kbd>C</kbd> | Open status (Character Sheet) |
| <kbd>Esc</kbd> | Return to main menu |

---

## 🧩 Game Systems

### Player Stats

| Stat | Description |
|:----:|:-----------:|
| **Level** | Increases through EXP gain; boosts all attributes |
| **HP** | Health points — hit 0 and you're in trouble |
| **MP** | Magic points — for future spellcasting |
| **ATK** | Base attack + equipped weapon bonus |
| **DEF** | Base defense + equipped armor/accessory bonuses |
| **Gold** | Currency earned from battles and quests |
| **Reputation** | Mercenary guild reputation, affects rank |

### Equipment

| Slot | Starting Item | Effect |
|:----:|:-------------:|:------:|
| ⚔️ Weapon | Rusty Sword | +5 ATK |
| 👕 Armor | Tattered Armor | +4 DEF |
| 📿 Accessory | Lina's Amulet | +2 DEF, +5 Rep |

### Rank Progression

```
E Rank  ──►  D Rank  ──►  ...  ──►  World's Strongest?
   │             │
   │          (at Level 2)
   │
   └── Starting rank for rookie mercenaries
```

---

## 🏗️ Project Structure

```
asterra/
├── project.godot          # Project configuration
├── icon.svg               # Game icon
├── scenes/
│   ├── game.tscn/.gd      # Main game scene (map manager, game flow)
│   ├── player.tscn/.gd    # Player character (movement, animation, combat)
│   ├── lina.tscn/.gd      # NPC sister
│   ├── slime.tscn/.gd     # Enemy slime (AI, combat, drops)
│   ├── herb.tscn/.gd      # Gatherable herb resource
│   ├── hud.tscn/.gd       # HUD overlay (HP/MP bars, quest tracker)
│   ├── dialogue_box.tscn/.gd # Typewriter dialogue system
│   ├── main_menu.tscn/.gd # Title screen with save detection
│   ├── naming_screen.tscn/.gd # Player name input
│   ├── inventory_screen.tscn/.gd # Backpack UI (grid + details)
│   ├── status_screen.tscn/.gd # Character sheet with equipment
│   ├── settings_screen.tscn/.gd # Text speed, audio settings
│   └── bulletin_board.tscn/.gd # Quest commission board
├── scripts/
│   ├── game_state.gd      # Global state (autoload)
│   ├── sprites.gd         # Procedural sprite generator (autoload)
│   ├── audio.gd           # 8-bit SFX synthesizer
│   └── floating_text.gd   # Damage number popup
```

---

## 🚀 Getting Started

### Prerequisites

- [Godot Engine 4.0+](https://godotengine.org/download/archive/4.0-stable/)

### Run the Game

```bash
# Clone or navigate to the project directory
cd asterra-(godot-4.0)

# Open in Godot Editor
godot -e

# Or run directly
godot --path .
```

The game will launch to the main menu. Select **New Game** to begin your adventure!

> **💡 No external assets needed!** All graphics and sounds are generated procedurally at runtime by the `sprites.gd` and `audio.gd` scripts.

---

## 🛠️ Tech Highlights

| Feature | Implementation |
|:-------:|:--------------:|
| **Pixel Art** | Fully procedurally generated via `Image` → `ImageTexture` (see `sprites.gd`) |
| **Sound FX** | 8-bit synthesized audio using Godot's `AudioStreamGenerator` (see `audio.gd`) |
| **Typewriter Text** | Character-by-character text reveal with configurable speed |
| **Save System** | `ConfigFile`-based save/load with auto-save on key events |
| **UI Styling** | Dark theme with `StyleBoxFlat`, rounded corners, glassmorphic panels |
| **Map System** | Grid-based tile maps with collision via `StaticBody2D` + `CollisionShape2D` |
| **Camera** | Smooth `Camera2D` with zoom and bounds limits per map |
| **Particles** | `CPUParticles2D` for hit sparks and herb gathering effects |

---

## 📜 License

This project is licensed under the **MIT License**.

---

<div align="center">

*Built with ❤️ using Godot Engine 4.0*

[Report Bug](https://github.com/your-username/asterra/issues) · [Request Feature](https://github.com/your-username/asterra/issues)

```
"Stronger, for those we protect."
  — Motto of the Asterra Mercenary Guild
```

</div>
