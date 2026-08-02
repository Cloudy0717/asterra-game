# ADR 001: Grand Adventurer's Guild Spatial Architecture & Enrichment

## Context
The Mercenary Guild hall in Asttera previously felt sparse and lacked functional interactions. Expanding the map size to a 2-Floor structure (1F: 24x18, 2F: 20x14) created open space that needed clear spatial organization, interactive gameplay features, and unobstructed navigation.

## Decision
1. **Unobstructed Main Corridor (中央主干道)**:
   - Establish a 4-tile-wide clear walkway (Cols 10 to 13) running uninterrupted from the entrance door at the bottom (`Row 17`) straight to the Reception Desk at the top (`Row 2`).
2. **Four-Quadrant Functional Zones (1F)**:
   - **Quadrant 1 (Top-Left)**: Commission Desk, Bulletin Board, Honor Wall, Rest Area.
   - **Quadrant 2 (Bottom-Left)**: Blacksmith Smithy, Anvil, Fireplace, Weapon Racks, Training Dummy, Apprentice NPC.
   - **Quadrant 3 (Top-Right)**: Party Recruitment Board, Guild Storage Chest, Stairs to 2F.
   - **Quadrant 4 (Bottom-Right)**: Logistics General Store, Material Appraisal Counter, Potion/Relic Display Cabinets.
3. **Interactive Facilities**:
   - **Training Dummy**: Real-time damage calculation and floating combat feedback.
   - **Guild Storage Chest**: Separate persistent storage inventory managed by `GameState`.
   - **Bard Music Player (2F)**: Dynamic BGM track selection and world lore.
   - **Information Broker (2F)**: Purchasable monster manuals and secret rumors.

## Consequences
- Prevents player navigation blocking upon entering the Guild.
- Provides persistent item management (`Guild Storage Chest`) freeing player inventory limits.
- Increases player engagement through damage testing (`Training Dummy`) and tavern entertainment (`Bard Jukebox`).
