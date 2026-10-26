# Vector Strike

A minimal 2D side-scrolling shooter for the Godot 4 engine, styled after
classic monochrome vector arcade games: a pure black background with all
line art drawn in green using Godot's runtime vector drawing API
(`_draw()` + `draw_line` / `draw_circle`) rather than sprite textures.

This repo also contains a second, separate Godot project,
[`contra-clone/`](contra-clone/README.md) ("Ridge Assault") — a one-stage
8-bit-style run-and-gun platformer set in mountainous terrain. It has its
own `project.godot` and must be opened independently in the Godot editor;
see its own README for details.

## Requirements

Godot **4.3** or later (uses the GL Compatibility renderer for broad
hardware support). No external assets or plugins are required — every
visual is drawn procedurally in code.

## Running

1. Open Godot 4, choose "Import", and select this project's `project.godot`.
2. Press F5 (or the Play button) — `scenes/Main.tscn` is the main scene.

## Controls

| Action        | Keys              |
|---------------|-------------------|
| Move          | Arrow keys / WASD |
| Fire          | Space             |
| Restart       | Space (after Game Over) |

## Project structure

```
project.godot              Project settings (black clear color, 1024x600 viewport)
icon.svg                   Vector project icon
scenes/
  Main.tscn                Root scene: background, player, HUD, spawn logic
  Player.tscn               Player ship (Area2D)
  Enemy.tscn                Enemy fighter (Area2D)
  PlayerBullet.tscn          Player projectile (Area2D)
  EnemyBullet.tscn           Enemy projectile (Area2D)
scripts/
  Main.gd                   Enemy spawning, score/lives HUD, game over/restart
  ScrollingBackground.gd    Scrolling vector grid + starfield (side-scroll illusion)
  Player.gd                 Movement, shooting, damage/invincibility flicker
  Enemy.gd                  Drift-in movement, optional shooting, health
  PlayerBullet.gd / EnemyBullet.gd   Straight-line projectiles

```

## Design notes

- The player ship stays within the fixed screen (like *Gradius*/*R-Type*);
  the "side-scrolling" motion comes from `ScrollingBackground.gd` animating
  a green grid and starfield leftward while enemies drift in from the
  right edge.
- All gameplay shapes (ship, enemies, bullets) are hand-authored polygons
  drawn each frame in each node's `_draw()` — there are no image assets,
  so the look stays crisp vector line art at any resolution.
- Collision uses Area2D layers/masks (no physics/gravity needed):
  player = layer 1, player bullets = layer 2, enemies = layer 3,
  enemy bullets = layer 4.
- Enemies spawn with randomized speed/health/fire-rate to create three
  rough "classes" (scout / fighter / gunship) from a single scene.
