# Hand Back: 覓食 = 苟活地板（產出 capped、繁榮須交易）

> plan `2026-07-01-foraging-survival-floor.md` / spec `2026-07-01-foraging-survival-floor-design.md`（讀 B arc）
> branch `feat/foraging-survival-floor`（未 merge，等主 session 確認）

## 實作摘要

核心 seam：覓食來源食物 net-bank 上限 = subsistence buffer（餬口幾日）。超額不 bank、不耗 wild_game。地形 regen / forage 決策權重**未動**。

- `scripts/simulation/resource_system.gd`：
  - 加 `const FORAGE_FLOOR_DAYS: float = 1.5`（TEST VALUE，覓食淨貢獻上限=幾日餬口）。
  - 加 `static func _forage_subsist_buffer(team) -> float`＝`pop × FOOD_PER_PERSON_PER_DAY × FORAGE_FLOOR_DAYS`。只封覓食（team.resources food），非 granary。
- `scripts/simulation/hunt_system.gd`：`hunt_small_game` 累積前加 subsistence gate（**cap 落點 = 2b source-gate，非 2a flush-clamp**）：
  - `team.resources food ≥ buffer` → 不擲骰、不耗 wild_game、不 bank（return success=false「食物已足（苟活封頂）」）→ 守恆乾淨。
  - 未達 buffer 但單次 yield 超額 → `banked = min(food, buffer − cur)`，只 bank 到 buffer 差額（剩肉=腐敗 sink，非憑空生糧）。food 嚴格 latch ≤ buffer。
- `scripts/debug/headless_test.gd`：3 新測 + 註冊：
  - `_test_forage_subsistence_cap`：net-bank latch 恰滿 buffer + 超 buffer 續獵不耗 wild_game（守恆）。
  - `_test_forage_no_growth`：純覓食隊 effective_food 不達 breed(7日)門檻 → surplus 不由覓食驅動。
  - `_test_settled_still_grows`：定居隊 granary surplus 超門檻（cap 只封覓食非 granary，不誤傷）。

### cap 落點裁定（plan Task 2b vs 2a）
選 **2b（source-gate at hunt_system）**。理由：wild_game 消耗發生在 hunt 端，flush 端（2a）無法乾淨回退已消耗的 wild_game。source-gate 守恆最乾淨（達 buffer→根本不獵→wild_game 零消耗、food 零 bank）。測證守恆。

### 與 spec 差異
- spec 傾向 cap 落 flush（team 級好算）；實作落 hunt source-gate（守恆乾淨）。plan Task 2b 已授權此裁定並列為傾向。
- 對稱性：cap 對玩家 active hunt 同樣生效（`player_command_system` 走同 `hunt_small_game`）。符合 invariants 對稱性（覓食=NPC/玩家同地板）。**副作用**：玩家無法靠小獵物囤糧超 1.5 日份，須 granary/交易——符合 spec 意圖，但玩家面手感待真人玩測確認。

## 驗證結果

- **headless_test（強制閘）**：`=== DONE ===`、framework S1-S6 PASS、coin_eq delta=0、InvariantAudit(population/faction/subteam) OK、3 新測綠、既有 hunt/passive 測不回歸。
  - FAIL 數 = **1**，= baseline 既有 `[FAIL] 弱目標未加入攻擊 goal`（IntelSystem 攻擊決策，belief/random，與覓食無關，未因本改變動）。
- **econ_bed 整環（Task 4，附 baseline 對照）**：
  - 我方：forest T0 priv food 288→**264**（覓食貢獻被 cap 壓低）、pop 6→10。baseline（main）priv 288、pop 6→11。→ **cap 確實壓低覓食貢獻**。
  - **但 trade loop 仍 NOT fire（TASK_TRADE=N，baseline/我方皆然）**。次閘見下「連動風險/次閘」。
- **warring_states seed（Task 4 活世界回歸，2yr，seed=1337）**：跑滿 24 月到 DONE、世界存活（teams 42→29、factions 8→6）、probes fire（g2.faction_found=1、feud=11、indep.found_ally=5、p1 assimilate/revolt/flee）。**但噴 17850 次 `require_team: Team23 不存在` + `combat_target on Nil` error flood**——見「連動風險 2」。
  - **baseline（main，無 cap）同 seed 跑：0 require_team error、乾淨 DONE（teams→28）**。⇒ 此 crash **只在本 branch 浮現**（root cause pre-existing 但由本改 surface，非 baseline 已有）。誠實標：非「本改無關」，是本改的 RNG-stream 位移把 sim 推入觸發潛在 bug 的軌跡。

## 連動風險

### 1. ★ 次閘：定居隊 granary 自填 = 真成長引擎，覓食 cap 後 trade loop 仍不 fire（measure 出，非本改造成）
- econ_bed baseline 對照證：forest T0（regen food=3、tile_food_init=150）granary 月1 即填至 ~cap（gran=1999）並維持，**baseline（無 cap）與我方行為近乎相同**。pop 成長由 granary（eff_food≈2200）驅動，非覓食（priv≈150-288）。
- ⇒ 覓食 cap 正確封住覓食路徑（unit 測證 + priv 壓低），但 econ_bed 的定居隊成長由 **granary 自填** 主導 → cap 對其成長影響小 → **trade loop 沒需求驅動 → 不 fire**。
- **次閘 = granary 為何在 forest（regen 3）也填到 ~cap**（harvest 產出 / storage cap / tile 食物池 init 來源待查）。這是 granary/harvest 域，**超出覓食 cap scope**（plan scope guard 明列不碰 REGEN_RATE/決策權重；granary 自填屬另一域，需另 spec）。
- 建議：主 session 排「定居隊 granary 自填來源」measure（食物統一 arc 的下一 slice），才是 trade loop fire 的真閘。本改是必要地板層（granary 修好後，覓食不能再 backfill 成長）。

### 2. ★★ warring_states require_team crash flood = pre-existing 結構 bug，**由本改 surface（baseline 乾淨）** — 阻塞級，須主 session 裁
- **現象**：本 branch warring_states（seed 1337）噴 17850 次 `require_team: Team23 不存在` + `combat_target on Nil`；**baseline（main）同 seed = 0 error 乾淨**。crash 不 halt sim（assert-continue，跑到 DONE、世界存活），但每 tick 該 faction 成員 task 指派靜默失敗 + 違「無 GDScript 錯誤」交付標準。
- **locus**：`faction_ai_system.gd:1043` `var mt = state.require_team(mid)`（迭代 A 類 `f.member_team_ids`）→ 1044 `mt.combat_target`。Team23 已 erase 但殘留在某 faction 的 `member_team_ids` → require_team assert → mt=null → `combat_target on Nil`。
- **根因（pre-existing 結構）= faction 成員清理缺口**：某死亡路徑（subjugation / off-map / 戰損）erase 了成員隊卻沒從 faction.member_team_ids 移除（或雙向 audit 沒自癒）。line 1043 是 batch1（`2026-06-18-team-ref-contract-batch1`）轉的 require_team，其 handback **明文警告**新增「迭代中 erase faction 成員」路徑須走快照。同型 dangling 記錄在案（parent_team_id audit 缺口、known_reputations 2138 violations）。
- **本改與此 bug 的關係（誠實）**：本改 3 檔零觸 team-ref/erase/faction/combat_target 碼。連結 = `hunt_small_game` 達 buffer 時 `return` **早於 `randf()`** → RNG stream 位移 → 下游死亡序列變 → 觸發該潛在 bug（baseline 的 RNG 路徑剛好避開）。⇒ **root cause pre-existing、trigger 是本改**。
- **為何不在本 branch 修**：
  - 正確修點 = 產生懸空的死亡路徑 / erase_team↔member_team_ids 清理 / audit 自癒 = **team-ref 域，plan scope guard 外**（本 plan 只 resource/hunt cap）。
  - line 1043 加 null-guard = **違 invariants team-ref 契約**（A 類 member_team_ids 明文「不可寫 if t==null，dangling 不可能=死碼」；require_team 存在正是為抓此持久懸空）。補丁 = 違「架構已定別打補丁」。
  - ⇒ disciplined 選擇 = 不碰、呈報主 session 裁。
- **建議**：主 session 先修 team-ref 死亡路徑 membership 清理（獨立 task/spec），或接受本 forage branch 後另案修。**在修好前，本 branch 的 warring_states 活世界回歸閘不算乾淨**（headless 強制閘乾淨、conservation 綠）。

## 待主 session 確認

1. **cap 落點 2b（source-gate）認可否**——守恆乾淨、對稱（玩家亦受 cap）。
2. **`FORAGE_FLOOR_DAYS=1.5` 量級**——TEST VALUE。econ_bed/warring 顯覓食隊苟活不死、不膨脹；正式平衡再校。
3. **★ 次閘 = granary 自填**（連動 1）：trade loop 沒 fire 的真閘不在覓食（本改已封）而在定居隊 granary 自填 ~cap（forest regen 3 也填滿）。建議排入食物統一 arc 下一 slice measure。**誠實標：活世界「繁榮須交易」emergence 尚未到**（覓食封了，但 granary 這條旁路未封）。
4. **★★ 阻塞級：warring_states require_team crash**（連動 2）：本 branch 噴 17850 error、baseline 同 seed 乾淨 → root cause pre-existing（faction 成員清理缺口 `faction_ai_system.gd:1043`）但由本改 RNG-shift surface。**不在本 branch 修**（team-ref 域 scope 外 + 補丁違 invariants A 類契約）。**須主 session 裁**：先修 team-ref 死亡路徑 membership 清理再收本 branch，或接受本 branch 另案修。headless 強制閘 + conservation 綠不受影響。
