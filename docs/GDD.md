# Myanmar: Empire of Warriors — GDD v0.2

## Vision
A mobile-first historical strategy game about Myanmar kingdoms, armies, fortifications, and campaigns. The game combines tactical unit control with defending a kingdom stronghold.

## Product target
- Primary platform: Android
- Engine: Godot 4.x with GDScript
- Development workflow: Android phone + Godot Android Editor
- Initial UI language: English; Myanmar localization planned
- Monetization: not included in the prototype

## Historical scope
The prototype uses fictionalized tutorial factions:
- Red Army: Konbaung-inspired defenders
- Gold Army: hostile raiders representing a rival force
This is not presented as a verified historical battle. Campaign scenarios require historical research.

## Phase 1 — Playable tactical prototype
- Main menu and battle scene
- Hex selection, movement, and adjacent attacks
- Basic enemy turn and restart
- Portrait Android layout

## Phase 2 — Kingdom Base Defense prototype
- 15×15 hex wilderness map, larger than the original 7×7 test board
- Touch-drag map scrolling
- A central royal base with 20 HP
- Three player defenders: infantry, cavalry, and war elephant
- Hostile units spawn at random legal wilderness cells, not from a fixed road
- End Wave advances hostile movement toward the base and creates the next wave
- Player can select, reposition, and use adjacent attacks
- Base reaching zero HP ends the defense attempt

## Current prototype controls
1. Tap a RED defender to select it.
2. Tap an adjacent empty hex to reposition it.
3. Tap an adjacent GOLD raider to attack it.
4. Drag the battlefield to scroll the large map.
5. Tap END WAVE to let raiders advance and spawn the next wave.
6. Tap RESTART to reset the defense.

## Roadmap
- Phase 3: fortification placement, archer towers, walls, defensive upgrades
- Phase 4: original character sprites, terrain art, sound, animation, tutorial, save data
- Phase 5: campaign progression, generals, researched historical missions, localization
- Phase 6: device optimization, accessibility, Android packaging, store preparation

## Asset and historical safeguards
Use original or properly licensed artwork, audio, and fonts. Do not copy proprietary game assets or UI. Distinguish researched history from fictionalized gameplay.
