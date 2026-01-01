# Project Report: Blimp Journey

## Overview
**Blimp Journey** is a 2D game project built with **Godot Engine 4.4**. It uses a structured architecture with separate directories for characters, systems, UI, and world elements.

## Key Directories
The `src` folder is where most of your code and assets live:

- **`src/character`**: Contains the logic and scenes for the Player and NPCs.
    - **Player Logic**: `src/character/player/player.gd` is likely the main script controlling the character.
- **`src/world`**: Contains level data and maps.
    - **Current Start Level**: The game is configured to start at `src/world/levels/07_scorched_complex/scorched_complex.tscn`.
- **`src/systems`**: Core game mechanics that manage things behind the scenes.
    - **Global Communication**: `src/systems/event_bus.gd` handles signals and events across the game.
    - **Inventory**: `src/systems/inventory.gd` manages items.
- **`src/ui`**: User interface components (menus, HUD, etc.).
- **`addons`**: Third-party plugins installed in the project.
    - **Dialogic**: For creating dialogue trees and conversations.
    - **Godot State Charts**: For managing complex states (like player movement states).

## How the Game Starts
1.  **Entry Point**: When you press "Play", Godot loads `src/world/levels/07_scorched_complex/scorched_complex.tscn`.
2.  **Autoloads (Singletons)**: Several scripts run automatically in the background to handle global systems:
    -   `EventBus`: For game-wide events.
    -   `SaverLoader`: For saving and loading the game.
    -   `Dialogic`: For handling dialogues.
    -   `Inventory`: For managing player items.

## Where to Start Modifying

### 1. Changing Player Logic
If you want to tweak how the player moves or interacts, look at:
- `src/character/player/player.gd`
- `src/character/player/player.tscn` (The visual scene for the player)

### 2. Level Design
To edit the levels, you would open scenes within:
- `src/world/levels/`
- specifically `src/world/levels/07_scorched_complex/` for the current starting area.

### 3. Dialogues
The game uses the **Dialogic** plugin. Dialogue files (`.dtl`) are scattered in level folders (e.g., `src/world/levels/07_scorched_complex/dialogue/`). You typically edit these using the Dialogic tab in the Godot Editor.

## Recommendations for a Beginner
1.  **Open the Project**: Launch Godot and import this folder (`project.godot`).
2.  **Run the Game**: Press the "Play" button (top right) to see the current state.
3.  **Explore the Player Script**: Open `src/character/player/player.gd`. specific variables like speed or jump height are often defined at the top of this file.
4.  **Check the "Remote" Tab**: While the game is running, clicking "Remote" in the Scene dock allows you to inspect the live game tree.
