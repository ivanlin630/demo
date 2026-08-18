---
from: systems
to: reviewer
status: consumed
topic: "[R² perf Phase2刀1(frontier call-scoped memo B+_hex_dist static A、全安全道byte-identical)HOW審·spec=2026-08-18-perf-phase2-cut1-frontier-memo-hexdist-HOW.md·R①免(前提Phase1 profile+file:line坐實)·審點:①★memo-safety(核心):find_nearest_terrain_tile call-scoped memo keyed(terrain,max_range)——team.tile_pos於frontier_candidates一次呼叫內固定確認?terrain靜態無mutation確認?call-scoped返回即棄無跨tick leak確認?=byte-identical by construction成立?②_hex_dist純度(無instance state可static)確認?③無新常數(memo=機制非旋鈕)④感知鐵律不動(find_nearest_terrain_tile已# gate-ok地理公共知識、memo同答案更快取非改god-view語意)⑤補丁閘:memo=延伸非繞過·憲章gate=byte-identical 3跑機器證(最強驗證)·此slice待R²CLEAN→dispatch implementer(base post-S2b-REDO或現main)·與settlement平行·地基KEEP"
---
# R² perf Phase2 刀1（frontier memo B + _hex_dist static A、全安全道）
spec=`docs/superpowers/specs/2026-08-18-perf-phase2-cut1-frontier-memo-hexdist-HOW.md`。R① 免（前提 Phase1 profile + file:line 坐實）。
## 審點
1. **★memo-safety（核心）**：`find_nearest_terrain_tile` call-scoped memo keyed `(terrain, max_range)`——**team.tile_pos 於 frontier_candidates 一次呼叫內固定**確認？**terrain 靜態無 mutation** 確認？**call-scoped 返回即棄無跨 tick leak** 確認？=**byte-identical by construction** 成立？
2. **_hex_dist 純度**（無 instance state 可 static）確認？
3. **無新常數**（memo=機制非旋鈕）。
4. **感知鐵律不動**（find_nearest_terrain_tile 已 # gate-ok 地理公共知識、memo 同答案更快取非改 god-view 語意）。
5. **補丁閘**：memo=延伸非繞過。
憲章 gate=**byte-identical 3 跑機器證**（最強驗證）。待 R² CLEAN → dispatch implementer。與 settlement 平行。地基 KEEP。
