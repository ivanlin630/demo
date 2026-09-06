class_name WorldData

var tiles: Dictionary = {}
var current_tick: int = 0
var current_turn: int = 0

# ★★★世界級排程的 `*_next_tick`（`modulo-same-shape-4`，2026-09-06）——
#   ★病：`harvest_system` 與 `population_system` 的裸 `current_tick % INTERVAL` 長在
#     【已經被外層 modulo 過濾過】的 step 裡（`_step4c_harvest_tick` 每 %360、
#     `_step1d_overflow` 每 %1440）⇒ ★★它們現在安全，而安全的理由是
#     【1440%360==0、43200%1440==0】—— ★★★是【算術剛好整除】不是【機制】。
#   ⇒ 跟 `faction_ai:1170` 完全同型，而那顆 systems 裁了「安全是巧合不是設計 ⇒ 也要遷」。
#   ★而修法是【純到期比較、不加相位偏移】（systems 裁 (b)）⇒ ★★fp 逐位元不變：
#     `next` 永遠落在 INTERVAL 邊界上，所以整除時 fire 的 tick 集合與舊制完全相同。
#   ★★★「四個 regen 去同批」的好處【不在這張票裡】—— 它已具名成候選，等對比輪收完再談；
#     夾帶進來就是【一次改兩件事 ⇒ 歸因不了】。
var harvest_daily_next_tick: int = 0
var regen_horses_next_tick: int = 0
var regen_game_next_tick: int = 0
var regen_predator_next_tick: int = 0
var regen_herb_next_tick: int = 0
var minor_mature_next_tick: int = 0
