# settlement §4c：結果反饋迴路（建點結局→選址記憶）（HOW / systems）

status: DRAFT→R²delta（2026-08-20）
owner: systems（HOW）← design §3「★結果反饋（第一條反饋迴路）」+ §4 HOW §5（衰減公式已定、R² 要求寫進 spec 本體）
前置：§4a MERGED（紮根入引擎）、§4b build 完成 HOLD 等 gate（擴點）。**本 slice 可與 §4b gate 平行**（blueprint 認可）。

## §0 命門
- **★self-knowledge、非全域**：結局只寫**該建點者自己 leader 的 memory**；選址只讀**自己 leader 的 memory**。**禁全域黑名單/共享失敗表**（那是 god-view）。
- **★禁永久黑名單**：`SITE_MEMORY_TTL_DAYS` **線性衰減、過期歸零**（同 `join_rejected` cooldown 精神、reviewer 要求公式進 spec 非留 implementer 猜）。
- **零新管道**：複用既有 `NpcAiSystem.write_memory(p, type, subject_id:int, tick, intensity)`（`npc_ai_system:65`）+ 既有 `decision_context` memory-scan pattern（`:530` `join_rejected` 款）。
- **★記憶隨人不隨團（intended）**：memory 掛 `PersonData`（leader）→ leader 死/換人=**新 leader 沒有這段經驗**=經驗隨人、非團的制度記憶（**誠實的湧現、非 bug**；若未來要制度記憶=另 arc）。
- **禁 crank**：反饋只**調既有選址 util**、不新增獨立驅力線。

## §1 現況（grounded、掛點全存在）
- **結局掛點**：
  - **失敗/棄置**：`harvest_system:37-38`（`camp_ticks_left<=0` → `camp_level=0`=**L0 紮營沒撐住**）；`faction_ai:1985` `OutpostOwnerBank.set_owner(cur_tile, -1, "relocate_abandon")`（**棄村遷走**）。
  - **成功/積累**：`outpost_system:354-356` `"upgrade_level"` 完工（**L1→L2+ =真積累**）。
  - **團滅**：`erase_teams` — **不寫**（人死了沒人記得=honest、且避免寫進已 erase 的 person）。
- **讀取點**：紮根（腳下 tile）/擴點（候選 pos）/紮營（`_find_unowned_farmable_tile` 候選）的選址 util。
- `write_memory` 的 `subject_id: int` → 直接放 **tile_id**（`x*1000+y` 既有慣例）。

## §2 Task
### T1 結局寫回（三掛點、self-knowledge）
- **`site_failed`**（intensity **0.5**、沿用 `join_rejected` 慣例）：
  - L0 decay（`harvest_system:37-38`）：若該 tile 有可辨識的建者（`camp` 期間 owner/founder team 仍存活）→ 寫其 leader。
  - `relocate_abandon`（`faction_ai:1985`）：寫**棄村隊自己**的 leader。
- **`site_thrived`**（intensity **0.5**）：`upgrade_level` 完工（`outpost_system:354`）→ 寫**該 tile owner 隊**的 leader。
- ★**只寫存活 leader**（`state.persons.get(leader_id)` 非 null）；★**零 RNG**、純事件驅動。

### T2 選址 util 讀回（既有 memory-scan pattern）
- `SITE_MEMORY_TTL_DAYS`（**TEST VALUE 30 天**=一季；★比 `JOIN_REJECT_COOLDOWN_TICKS`(2 日)長：選址是**低頻高成本**決策、記憶該跨季節）。
- **調整量** = `intensity × max(0, 1 − 已過天數 / SITE_MEMORY_TTL_DAYS)`（**線性衰減、過期歸零**）；`site_failed` 減、`site_thrived` 加。
- 掛進**既有選址 util**（紮根 rooting_drive / 擴點 expand util / 紮營 camp_drive 的地點品質項），**不新增獨立 term 線**。
- ★掃描成本：memory 是 per-person Array、只掃自己 leader 的（同 `:530` 既有做法）；★若 memory 無限成長=既有問題（非本 slice 引入）、順手記 known_issues 不修。

## §3 gate（measurer bounded）
1. **反饋真作用**：**同一團第二次選址避開失敗地**（specimen 可見、design §4 量測項）。
2. **非全域**：**別團不受影響**（A 團的失敗不降 B 團對同一地的 util）。
3. **有效期**：**過期後該地 util 回復**（非永久黑名單）。
4. **記憶隨人**：leader 換人後新 leader 不繼承（intended、驗一次即可）。
5. determinism（純事件+算術、零 RNG）、constitution 75 不回升、headless 0-new、fp intended-change 標。

## §4 界外
制度記憶（團/勢力層）=另 arc。memory 無限成長=既有問題、另記。

序：R² delta → CLEAN → dispatch（可與 §4b gate 平行）→ gate → merge。地基 KEEP。

## §5 R²delta 訂正（2026-08-20、CLEAN+2 必查項、systems 裁）
### ★必查項①：**禁原樣重用 `write_memory`** → 專用薄函式（裁 (a)）
`write_memory`(npc_ai_system:65-74) **不是純 append**：連呼 `_trim_memory` + **`_update_relations`** + `_trigger_goals` + `_write_relation_edge`；`_update_relations`(:92-106) **只要 `subject_id != -1` 就無條件寫 `p.relations[subject_id]`**（未知 type 走 delta=0 但**寫入不跳過**）。傳 `subject_id=tile_id` → **在人際關係字典塞「跟一塊地的交情」假記錄** → 未來讀 `p.relations.keys()` 假設全是 person/team id 的 code（UI 交情列表、`state.persons.get(rk)` 查找、平均關係統計）可能 null-deref 或悄悄算錯。
**裁定=(a) 新增專用薄函式** `write_site_memory(p, type, tile_id, tick, intensity)`：**只做 `p.memory.append(...) + _trim_memory(p)`**、**跳過** `_update_relations`/`_trigger_goals`/`_write_relation_edge`（地點沒有交情、沒有復仇/感恩目標）。**不動共用 `write_memory`**（8 個既有 caller 零影響）。

### ★必查項②：L0 decay 掛點缺 founder 資料 → **裁 (a) 加最小 tracking 欄位**
`tile_data` 只有 `camp_level`/`camp_ticks_left`（**無 camp_owner/founder**）、`_decay_l0_camps`(harvest_system:31-39) 是**純 tile sweep 不帶 team 參數** → **結構上讀不到「誰的失敗」**。
**裁定=(a) 加 `tile.camp_team_id: int = -1`**（`faction_ai:4770` `camp_level=1` 起建處順手寫入；decay 時讀它、找到**活著**的隊就寫其 leader、找不到跳過）。
- **為何不取 (b) 砍掉 L0-decay 掛點**：L0 紮營沒撐住**大概率是本迴路最常見的失敗案例**（relocate_abandon 罕見）→ 砍掉=**迴路實務上幾乎不生效、slice 價值大減**（reviewer 明確要求誠實面對此 trade-off）。
- **★誠實訂正 §0「零新管道」措辭**：本 slice **新增一個 tracking 欄位**（`camp_team_id`）——它**不是旋鈕**（無可調參數）、**不是新感知管道**（自家營地誰搭的=self-knowledge 事實），但**確實是新 plumbing**、不藏。
- **★determinism**：`camp_level`/`camp_ticks_left` 已進 `state_fingerprint`（S2a）→ **`camp_team_id` 同族必須一併進 fp**（否則 L0 歸屬變化=fp 盲點）。
- 完工/decay 時清 `camp_team_id`（L0 消融進 L1 或營地消失）。

### 小訂正
memory-scan pattern 實際在 `decision_context:553-561`（非 :530、行號漂移 23 行、pattern 本身確認存在）。

### R² 對我 5 審點的答覆（全同意我方向、無需改）
capture 被奪**不算**失敗地（「打輸」≠「選址錯」、甚至常是「這地方太好才被搶」=相反訊號）｜記憶隨人 intended（與 `corvee_site`/`join_rejected` 同紀律；制度記憶=下一 arc、**不偷渡**）｜TTL 30 天合理（選址是季量級低頻決策、比社交 cooldown 長一個數量級對）｜掛既有選址 util **不算語意混雜**（「地力」與「我上次在這失敗過」是同一個「這地方值不值得」的兩個獨立輸入、同 `_inflow_est` 多因子疊乘慣例）。
