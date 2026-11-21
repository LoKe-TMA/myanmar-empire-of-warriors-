# Myanmar: Empire of Warriors — GDD v0.1

## Vision
Create an accessible mobile-first, turn-based historical strategy game inspired by Myanmar's kingdoms, armies, fortifications, and campaigns.

## Product target
- Primary platform: Android
- Distribution goal: Google Play
- Engine: Godot 4.x with GDScript
- Initial language: English UI labels with Myanmar localization planned
- Business model: undecided; no monetization in the first prototype

## Historical scope
The first playable scenario uses two opposing prototype factions:
- Red Army: Konbaung-inspired
- Gold Army: Hanthawaddy-inspired

This is a fictionalized tutorial encounter for testing combat mechanics. It must not be presented as a verified historical battle. Campaign missions will be based on researched events and reviewed for historical accuracy.

## Core gameplay
1. The player selects one of their units.
2. A unit may move to a legal adjacent hex or attack an adjacent enemy.
3. The player ends the turn.
4. Enemy AI moves or attacks.
5. Victory occurs when all enemy units are defeated; defeat occurs when all player units are defeated.

## Prototype unit classes
| Unit | Role | Design intent |
|---|---|---|
| Infantry | Balanced | Reliable basic unit |
| Cavalry | Mobile | Higher movement potential in later iterations |
| War elephant | Heavy | High health and strong close combat |

Initial prototype stats are placeholders and will be tuned through playtesting.

## Battlefield
- Hex-based tactical board
- Prototype terrain: plain, forest, hill, river
- Later terrain rules: movement costs, defensive bonuses, blocked cells, and line of sight

## Phase 1 acceptance criteria
- Project opens in Godot 4.x without parse errors.
- Main menu opens the battle scene.
- Player can select, move, and attack with units.
- Enemy AI takes a turn.
- Victory and defeat states are displayed.
- UI is readable on a portrait Android screen.
- A debug APK can be exported and installed on the user's Android device.

## Later roadmap
- Phase 2: art direction, unit sprites, sound, tutorial, save data
- Phase 3: campaign map, generals, upgrades, historical missions
- Phase 4: device testing, performance, accessibility, localization
- Phase 5: Play Console setup, closed testing, store listing, AAB release

## Risks and safeguards
- Verify historical details before presenting them as facts.
- Use original or properly licensed artwork, music, fonts, and sound.
- Do not copy proprietary assets or UI from Grand War: Rome; use it only as a genre reference.
- Keep Android signing keystores and credentials out of version control.
