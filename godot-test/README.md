# Pawn Shop Prototype (Godot 4)

Placeholder prototype for the tech-research milestone. Every screen from the wiki exists and is wired together;
all text and art are placeholders (colored rectangles, "Placeholder ..." strings).

## Run it
1. Install Godot 4.3+ (standard build, no .NET needed).
2. Project Manager -> Import -> select `project.godot` -> open it.
3. Press F5 (main scene is `scenes/main_menu.tscn`).

## Controls
WASD / arrows = move, E = interact, I = inventory, Esc = pause.

## How it is organised
- `scripts/game.gd`  - autoload singleton `Game`: run state, scene switching, save/load, settings, UI theme.
- `scripts/palette.gd` - the brown / muted color palette. Edit colors here.
- `scripts/base_screen.gd` - base class for every screen (background, padding, UI helper functions).
- `scripts/<screen>.gd` + `scenes/<screen>.tscn` - one pair per wiki screen. Scenes are just a root Control;
  the scripts build the UI in code in `build()`.

## Loop to try
Shop -> wait for the customer at the desk (E) -> Negotiations -> Inspect -> accept/decline ->
Repair Bench / Inventory / clean the dirt -> End Day -> Upgrades -> Start Next Day.
