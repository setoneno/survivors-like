# Vampire Survivor Prototype

Godot 4 / GDScript prototype. Phase 9 completes Ver 0.1 with a polished HUD, HP bar, visual feedback, readable overlays, and lightweight generated sound effects.

## Run

1. Open this directory in Godot 4.
2. Run the project (`F5` or the play button).
3. Confirm that the blue square moves in every direction and remains inside the window.
4. Confirm that red enemies continuously appear and move toward the player.
5. Confirm that yellow bullets automatically target enemies and each enemy takes three hits to defeat.
6. Confirm that enemy contact deals 10 damage at most once per second.
7. Confirm that reaching 0 HP stops the player and enemy spawning, then displays `GAME OVER`.
8. Confirm that each defeated enemy grants 1 XP and that 5 XP raises the player to Level 2.
9. Confirm that the next XP requirements shown are 7 at Level 2 and 9 at Level 3.
10. Confirm that leveling pauses the game and displays the three upgrade choices.
11. Confirm that the selected attack damage, attack speed, or movement speed upgrade is applied and the game resumes.
12. Confirm that consecutive level-ups require one choice per gained level.
13. Confirm that the timer starts at `01:00`, uses `MM:SS`, and pauses while an upgrade is selected.
14. Confirm that surviving until `00:00` displays `GAME CLEAR` and stops all gameplay.
15. Confirm that `GAME OVER` stops the timer and never changes into `GAME CLEAR`.
16. Confirm that the HUD and HP bar remain readable while enemies move behind them.
17. Confirm that the player flashes red when damaged and defeated enemies briefly expand and fade.
18. Confirm that the level-up and end-state overlays are clear and that basic sound feedback plays.

The authoritative game specification is maintained in [Notion](https://app.notion.com/p/3e83230596628141b5c6e7c083d24d5c).
