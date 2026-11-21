# Myanmar: Empire of Warriors — Game Design Document v1.0

## 1. Product vision
A mobile-first, single-player strategy game inspired by Myanmar kingdoms and military history. The first complete playable vertical slice combines kingdom base defense, hex-grid tactical movement, construction, resource management, troop recruitment, and a short campaign.

## 2. Platform and presentation
- Engine: Godot 4.x / GDScript
- Primary target: Android phones
- Layout: portrait, 720×1280 logical viewport
- Art direction: original 2D cartoon / isometric-inspired battlefield presentation
- Current art implementation: procedural placeholder shapes and drawn UI; final commissioned/licensed sprites and animation are not yet integrated.
- Initial interface language: English; Myanmar localization is planned.

## 3. Historical framing
The playable tutorial uses fictionalized factions:
- Red defenders: Konbaung-inspired
- Gold attackers: rival raiders for gameplay
This is not a reconstruction of a verified historical battle. Named historical battles, leaders, flags, uniforms, weapons, and dates must be researched before appearing as factual campaign content.

## 4. Core game loop
1. Inspect the 15×15 wilderness hex map.
2. Construct walls, archer towers, and a barracks near the Royal Base.
3. Recruit and reposition defenders.
4. Attack adjacent raiders and use tower fire.
5. End the wave; surviving enemies attack defenders or the Royal Base.
6. Collect supplies, upgrade buildings or the base, and prepare for a stronger wave.
7. Save progress locally and continue the campaign.

## 5. Units
- Infantry (INF): standard defender, balanced cost and durability.
- Cavalry (CAV): more expensive recruit with increased attack damage.
- War Elephant (ELE): high-cost, high-durability, high-damage recruit.
- Enemy raiders scale in health and damage; Cavalry and Elephant raiders begin appearing in later waves.

## 6. Buildings and base
- Royal Base: central objective with HP; base upgrades increase maximum HP.
- Archer Tower: costs 80 Gold; automatically targets enemies within range during the tower phase.
- Wall: costs 35 Wood; absorbs damage when an enemy reaches the base perimeter.
- Barracks: costs 100 Gold and 60 Wood; required to recruit units.
- Building upgrades: select a building and press UPGRADE; maximum level 3. Upgrades cost Gold and Iron.
- If no building is selected, UPGRADE applies to the Royal Base and costs Gold and Wood.

## 7. Economy
Resources:
- Gold: construction, recruitment, upgrades.
- Wood: walls, barracks, base upgrades.
- Iron: building upgrades.
- Food: troop recruitment.

Enemy defeats and completed waves provide supplies. Resource values are prototype balance values and will be tuned through playtesting.

## 8. Map, controls, and enemy AI
- 15×15 hex grid with touch-drag camera scrolling.
- Enemies spawn at randomized legal cells across the wilderness, not from a single fixed road.
- Tap a Red unit, then an adjacent empty hex to move.
- Tap an adjacent Gold unit to attack.
- Enemy AI attacks adjacent Red units or advances toward the Royal Base.
- Archer Towers attack enemies during the tower phase.
- Walls absorb enemy damage near the base.

## 9. Campaign
- Three chapters, ten waves per chapter (30 waves total).
- Enemy health, damage, and spawn count increase over time.
- Chapter milestones restore a small amount of Base HP and unlock the next chapter.
- Survive all 30 waves to complete the current campaign slice.

## 10. Save and progression
- Save / Load use a local ConfigFile under Godot's user:// storage.
- Saved values include units, buildings, wave, turn, Base HP, resources, chapter, and recruitment progression.
- Save data is local to the device; cloud sync and cross-device transfer are not implemented.

## 11. Current implementation status
Implemented in the repository:
- Main Menu and playable Base Defense scene
- Hex map, scrolling, unit selection, movement, and attacks
- Three player unit classes and enemy scaling
- Randomized enemy spawns and wave progression
- Base, towers, walls, barracks, and upgrades
- Gold, Wood, Iron, Food economy
- Recruitment, enemy AI, local Save / Load
- Three-chapter, 30-wave campaign completion and defeat states
- Godot headless project validation workflow

## 12. Not yet included in v1 vertical slice
- Multiplayer, online accounts, leaderboards, or server-side persistence
- Full strategic world map with historically researched territories
- Fully researched historical campaign missions and named historical commanders
- Final character sprite sheets, skeletal animation, VFX, and produced audio
- Advanced pathfinding, terrain modifiers, weather, diplomacy, and technology trees
- Full accessibility, performance, and device compatibility QA
- Verified signed release APK / AAB and Play Store publication

## 13. Release criteria
Before calling this a public release:
1. Complete repeated Android device playtests across supported screen sizes.
2. Fix all parser, runtime, input, and save/load issues.
3. Replace placeholder art and add licensed/original audio.
4. Research and review all historical claims and depictions.
5. Verify Android export, package identity, signing, and install/update behavior.
6. Prepare privacy, store listing, age rating, and release materials.

## 14. Asset and IP policy
Use original or properly licensed artwork, audio, fonts, and code. Do not copy proprietary game assets or UI. Clearly separate fictionalized mechanics from historical claims.
