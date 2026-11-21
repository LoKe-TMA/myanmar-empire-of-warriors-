# Myanmar: Empire of Warriors

A mobile-first Myanmar-kingdom strategy game prototype built with Godot 4.x and GDScript.

## Current playable build — Final v1 vertical slice

The main playable scene is a portrait 720×1280 kingdom-defense campaign.

### Implemented gameplay
- 15×15 hex wilderness map with touch drag scrolling
- Konbaung-inspired Red defenders and Gold raider enemies (fictionalized gameplay factions)
- Infantry, Cavalry, and War Elephant player units
- Random enemy spawn positions across the map; enemy strength grows with waves
- Royal Base with upgradeable maximum HP
- Archer Tower placement and automatic ranged attacks
- Wall placement to absorb attacks near the base
- Barracks construction
- Troop recruitment from a Barracks: Infantry, Cavalry, and Elephant rotation
- Gold, Wood, Iron, and Food economy
- Building upgrades up to level 3; Base upgrades
- Enemy AI that targets nearby defenders or the Royal Base
- 3-chapter, 30-wave campaign progression
- Local Save / Load using Godot user storage
- Restart and victory / defeat states
- Original procedural placeholder art drawn in GDScript (no proprietary game assets)

## Controls
- Tap a RED unit, then tap an adjacent empty hex to move.
- Tap an adjacent GOLD enemy to attack.
- Tap TOWER, then an empty hex to build an Archer Tower (80 Gold).
- Tap the left half of WALL / BARRACKS, then an empty hex to build a Wall (35 Wood).
- Tap the right half of WALL / BARRACKS, then an empty hex to build a Barracks (100 Gold + 60 Wood).
- Tap a building, then UPGRADE to improve it (up to level 3). If no building is selected, UPGRADE improves the Royal Base.
- Build a Barracks before recruiting. RECRUIT cycles through Infantry, Cavalry, and Elephant costs.
- Drag the map to explore the wilderness.
- END WAVE advances enemy actions and starts the next wave.
- SAVE and LOAD store progress on the current device. RESTART begins a new campaign.

## Open and test
1. Download the repository ZIP from GitHub.
2. Extract it on the Android device.
3. Open Godot Android Editor and import the folder containing project.godot.
4. Open the project and press Run.
5. Select DEFEND KINGDOM on the Main Menu.

## Build and validation
- Godot project validation is run by .github/workflows/godot-validate.yml.
- Android APK export is handled separately by .github/workflows/android-build.yml; a successful project validation does not imply a successful APK export.
- Keep release signing keys and passwords outside GitHub. Never commit secrets.

## Scope and limitations
This is a playable single-player vertical slice, not a finished commercial release. Multiplayer, online accounts, cloud saves, full historical campaign research, final sprite animation, audio production, accessibility review, device-wide QA, and Play Store release preparation remain future work. Historical scenario details must be researched; tutorial factions are fictionalized and must not be presented as verified battle records.

Use only original or properly licensed artwork, audio, fonts, and other assets.
