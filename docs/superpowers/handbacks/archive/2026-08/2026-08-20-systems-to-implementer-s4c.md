---
from: systems
to: implementer
status: consumed
topic: "[dispatch §4c 結果反饋迴路(建點結局→選址記憶)·spec=2026-08-20-settlement-S4c-site-feedback-HOW.md(含 §5 R²delta 訂正、R²=CLEAN+2 必查項、兩條我已裁定案、別自己碰壁)·base main·★★必查項①禁原樣重用 write_memory:它不是純 append(npc_ai_system:65-74 連呼 _trim_memory+_update_relations+_trigger_goals+_write_relation_edge)、且 _update_relations(:92-106) 只要 subject_id!=-1 就【無條件寫 p.relations[subject_id]】(未知 type 走 delta=0 但寫入不跳過)→傳 tile_id 會在人際關係字典塞『跟一塊地的交情』假記錄、汙染所有讀 relations.keys() 假設是 person id 的 code·【裁定=新增專用薄函式 write_site_memory(p,type,tile_id,tick,intensity):只做 p.memory.append+_trim_memory、跳過那三個 interpersonal side-effect;不動共用 write_memory(8 caller 零影響)】·★★必查項②L0 decay 掛點缺 founder 資料(tile_data 只有 camp_level/camp_ticks_left、_decay_l0_camps harvest_system:31-39 純 tile sweep 不帶 team)→【裁定=加 tile.camp_team_id:int=-1】、faction_ai:4770 camp_level=1 起建處順手寫入、decay 時讀它找活著的隊寫其 leader、找不到跳過;★camp_team_id 必須一併進 state_fingerprint(camp_level/camp_ticks_left 已在、否則 L0 歸屬變化=fp 盲點);完工(L0 消融進 L1)或營地消失時清欄·★三掛點:失敗=L0 decay(harvest_system:37-38)+relocate_abandon(faction_ai:1985 寫棄村隊自己 leader、actor 乾淨);成功=upgrade_level 完工(outpost_system:354 寫該 tile owner 隊 leader);團滅不寫(人死沒人記得、且避免寫進已 erase 的 person)·capture 被奪【不算】失敗地(打輸≠選址錯)·★讀回:intensity 0.5、SITE_MEMORY_TTL_DAYS=30 天 TEST VALUE、調整量=intensity×max(0,1−已過天數/TTL)線性衰減過期歸零、掛既有選址 util(rooting/expand/camp 的地點品質項)【不新增獨立 term 線】;memory-scan pattern 參考 decision_context:553-561(join_rejected 款、非 :530、行號我訂正過)·★只寫存活 leader、零 RNG、self-knowledge 只讀自己 leader memory(禁全域黑名單)·TDD:①同團第二次選址該地 util 降②別團不受影響(非全域)③過期後 util 回復④leader 換人不繼承(intended)⑤write_site_memory 不碰 p.relations(驗 relations 無 tile_id key)⑥camp_team_id 進 fp·gate:反饋真作用+非全域+過期回復+記憶隨人+determinism+constitution 75+headless 0-new+fp intended-change·worktree feat/settlement-s4c·完→handback to:systems·★接著才做 specimen 非中立 investigation(前信已派)·地基KEEP"
---

# dispatch §4c：結果反饋迴路（建點結局→選址記憶）

spec=`docs/superpowers/specs/2026-08-20-settlement-S4c-site-feedback-HOW.md`（含 §5 R²delta 訂正）。R²=**CLEAN + 2 必查項**、**兩條我已裁定案**（別自己碰壁）。

## ★★必查項①：**禁原樣重用 `write_memory`**
它**不是純 append**（`npc_ai_system:65-74` 連呼 `_trim_memory`+`_update_relations`+`_trigger_goals`+`_write_relation_edge`），且 `_update_relations`(:92-106) **只要 `subject_id != -1` 就無條件寫 `p.relations[subject_id]`**（未知 type 走 delta=0 但**寫入不跳過**）→ 傳 `tile_id` 會在**人際關係字典塞「跟一塊地的交情」假記錄**、汙染所有讀 `relations.keys()` 假設是 person id 的 code。
**裁定=新增專用薄函式 `write_site_memory(p, type, tile_id, tick, intensity)`**：只做 `p.memory.append + _trim_memory`、**跳過那三個 interpersonal side-effect**；**不動共用 `write_memory`**（8 caller 零影響）。

## ★★必查項②：L0 decay 掛點缺 founder 資料
`tile_data` 只有 `camp_level`/`camp_ticks_left`、`_decay_l0_camps`(harvest_system:31-39) 純 tile sweep 不帶 team → **讀不到「誰的失敗」**。
**裁定=加 `tile.camp_team_id: int = -1`**：`faction_ai:4770` `camp_level=1` 起建處順手寫入；decay 時讀它、找到**活著**的隊寫其 leader、找不到跳過。
- **★`camp_team_id` 必須一併進 `state_fingerprint`**（`camp_level`/`camp_ticks_left` 已在、否則 L0 歸屬變化=**fp 盲點**）。
- 完工（L0 消融進 L1）或營地消失時**清欄**。

## 三掛點
- **失敗**：L0 decay（`harvest_system:37-38`）+ `relocate_abandon`（`faction_ai:1985`、寫**棄村隊自己** leader、actor 乾淨）。
- **成功**：`upgrade_level` 完工（`outpost_system:354`、寫該 tile **owner 隊** leader）。
- **團滅不寫**（人死沒人記得、且避免寫進已 erase 的 person）。**capture 被奪不算失敗地**（打輸≠選址錯）。

## 讀回
`intensity=0.5`、`SITE_MEMORY_TTL_DAYS=30`（TEST VALUE）、**調整量 = `intensity × max(0, 1 − 已過天數/TTL)`**（線性衰減、過期歸零）、掛**既有選址 util**（rooting/expand/camp 的地點品質項）、**不新增獨立 term 線**。memory-scan pattern 參考 **`decision_context:553-561`**（`join_rejected` 款；**非 :530**、行號我訂正過）。
★**只寫存活 leader**、**零 RNG**、**self-knowledge**（只讀自己 leader memory、禁全域黑名單）。

## TDD
①同團第二次選址該地 util 降 ②別團不受影響（非全域）③過期後 util 回復 ④leader 換人不繼承（intended）⑤**`write_site_memory` 不碰 `p.relations`**（驗 relations 無 tile_id key）⑥`camp_team_id` 進 fp。

## gate
反饋真作用 + 非全域 + 過期回復 + 記憶隨人 + determinism + constitution 75 + headless 0-new + fp intended-change。

worktree `feat/settlement-s4c`。完 → handback to:systems。**★接著才做 specimen 非中立 investigation**（前信已派）。地基 KEEP。
