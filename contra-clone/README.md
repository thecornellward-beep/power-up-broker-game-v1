# Ridge Assault

A one-stage 2D side-scrolling run-and-gun for the Godot 4 engine, in the
spirit of classic 8-bit commando shooters: a lone soldier fights across
mountainous terrain against an alien invasion force, armed with a
rapid-fire machine gun.

This is a separate Godot project from the `Vector Strike` game at the
repo root — each has its own `project.godot` and must be opened
independently in the Godot editor.

## Requirements

Godot **4.3** or later (GL Compatibility renderer). No external art
assets — every character, enemy, and piece of terrain is drawn
procedurally in code (`_draw()` + `draw_line`/`draw_circle`/
`draw_colored_polygon`), so nothing needs to be imported.

## Running

1. Open Godot 4, choose "Import", and select `contra-clone/project.godot`.
2. Press F5 — `scenes/Main.tscn` is the main scene.

## Controls

| Action              | Keys              |
|---------------------|-------------------|
| Run left / right    | Arrow keys / WASD |
| Jump                | Space             |
| Crouch              | Down / S          |
| Aim up & fire       | Up / W + X        |
| Fire (machine gun)  | X (hold for rapid fire) |
| Restart             | Space or Enter (on Game Over / Stage Clear) |

The player can fire while standing, running, crouching (low, forward),
or airborne, and can aim straight up while stationary or moving.

## Project structure

```
project.godot              Dusk-sky clear color, 1024x600 viewport
icon.svg                   Project icon
scenes/
  Main.tscn                 Parallax background, terrain/enemy containers,
                             goal gate, player, camera, HUD
  Player.tscn                Player CharacterBody2D (stand + crouch collision shapes)
  Enemy.tscn                  Alien trooper (Area2D)
  PlayerBullet.tscn            Machine-gun tracer (Area2D)
  EnemyBullet.tscn              Alien plasma bolt (Area2D)
scripts/
  Main.gd                    Builds the level from data tables, spawns
                             enemies, tracks score/lives/checkpoints,
                             drives the camera, handles stage clear/game over
  Player.gd                  Movement, jump, crouch, machine-gun fire,
                             and the vector-drawn soldier figure
                             (tan skin, olive fatigues, red headband)
  Enemy.gd                   Bipedal alien: patrol -> aggro -> fire AI
  PlayerBullet.gd / EnemyBullet.gd   Projectiles
  TerrainChunk.gd             A single ground slab (collision + rock visual)
  MountainLayer.gd            Procedural jagged mountain-range silhouette
  Sky.gd                      Dusk sky backdrop (moon + stars)
  Goal.gd                     Stage-end gate
```

## Design notes

- **Terrain is data-driven.** `Main.gd`'s `GROUND_SEGMENTS` array lists
  flat ground slabs (`x`, `width`, `top`); gaps between entries are
  chasms. `Main.gd` builds a `TerrainChunk` (a `StaticBody2D`) for each
  entry at runtime — there's no hand-placed level geometry in the
  `.tscn` file, so the level profile can be edited entirely in code.
  This produces the stepped, climbable mountain profile (valleys,
  plateaus, a couple of jump-or-fall chasms) while keeping collision
  simple (flat tops + vertical cliff faces — no slope physics needed).
- **Two parallax mountain-silhouette layers** (far/near, different
  heights and scroll speeds) plus a static starfield/moon sky sell the
  mountain backdrop, independent of the walkable foreground terrain.
- **One-hit death, checkpoint respawn.** Any enemy contact or enemy
  bullet kills the player immediately (classic 8-bit run-and-gun
  rules). `Main.gd` tracks the furthest checkpoint reached and
  respawns the player there with brief invincibility, rather than
  restarting the whole stage — makes a single-stage demo playable
  without being punishing. Running out of lives (3 by default) ends
  the run with a restart prompt; reaching the gate at the far right
  of the level ends it in victory.
- **Collision layers**: player = 1, player bullets = 2, enemies = 4,
  enemy bullets = 8, terrain = 16. Enemies and enemy bullets detect the
  player (and terrain, for bullets) via `body_entered`, since the
  player is a physics body (`CharacterBody2D`); player bullets detect
  enemies via `area_entered`, since enemies are `Area2D`.
- The camera follows the player horizontally at a fixed height (classic
  ground-level run-and-gun framing) rather than free-roaming, with
  `Camera2D` limits clamping it to the level bounds.
