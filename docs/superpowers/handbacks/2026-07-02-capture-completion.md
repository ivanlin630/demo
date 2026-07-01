# Hand Back: capture 完成 depth（征服者 last-mile / 以戰養戰）

branch `feat/capture-completion`（未 merge，等主 session 確認）。
plan `docs/superpowers/plans/2026-07-02-capture-completion-depth.md`。

## 實作摘要（measure-first）

改檔（4）：
- `scripts/simulation/npc_combat_system.gd`：
  - Task0 漏斗探針（`conq.combat_entered`/`combat_decisive`/`combat_retreat`/`win_absorbed`/`win_no_absorb`+原因/`retreat_captured`/`retreat_no_capture`）。
  - `_force_retreat` 加 **loot PAY**：控地勝方掃戰場奪撤退者補給（食+資源）。抽 `_loot_resources` helper 與 `_end_combat` 共用（前僅殲滅 loot；潰逃佔多數戰局卻零 PAY）。
  - 潰逃 capture 呼叫改 `capture_routed_as_captive`（俘擴 healthy）。
- `scripts/simulation/anon_tier_system.gd`：
  - `capture_wounded_as_captive` → **`capture_routed_as_captive`**：潰逃俘擴 = wounded（失能丟下，全 rate）+ healthy（落單者，`rate × HEALTHY_ROUT_FACTOR=0.35`），共用 guard budget。抽 `_capture_from_health` 共用 helper。守恆全走 AnonCohort。
- `scripts/debug/conquest_measure.gd`：漏斗 keys 加進輸出。
- `scripts/debug/headless_test.gd`：`_test_cap_retreat_captures_wounded` 更新為 rout 語意（wounded+healthy 兩桶降 / pop 守恆 / entry=`潰逃-capture` / wnd=0 純 healthy 也俘 / 確定性 / guard 滿 / 有序<潰逃）。

## ★ measure 關鍵發現（別跳過）

**崩點不在戰內，在攻擊→戰鬥（上游）。** warring measure（14400 tick）：

| 漏斗段 | 數 |
|---|---|
| conq.intent（想征服） | 126 |
| **combat_entered（真打）** | **12** |
| combat_decisive（殲滅） | 1 |
| combat_retreat（潰逃） | 7 |
| capture.total | 3（前 ~1） |

- **主崩 = intent 126 → combat_entered 12（~10% 到真戰鬥）**。攻擊派了但追不到/target 消失/不同格 → 沒開打。= **combat_target / targeting 上游（軌2 scope）**，非本軌（本軌只碰 npc_combat absorb/casualty/loot）。
- 戰內兩病（in-scope，已修）：①**戰不決勝** retreat 7 >> decisive 1（連舊教訓）②潰逃只俘 wounded、**5/7 潰逃 wnd=0 → 俘 0**、且 `_force_retreat` 完全不 loot → 主流戰果零 PAY。
- 修後：潰逃兩路皆 PAY（loot + rout capture healthy）；wnd=0 潰逃今也俘（measure 見 Team3 wnd=0 +1、Team21 wnd=0 +3，前皆 0）。

**conqueror specimen 佐證**：野心0.98 好戰0.98，intent_hist 征服=94（強想征服），但**從未進戰鬥**，末態 `task=投靠`（投靠 faction 5）、`combat_target=-1`。→ **survival-trap 自解（Task3）無法演示**：specimen 想征服卻打不到，餓→搶→餵飽鏈斷在「搶不到」的上游，非 capture PAY。

## 交付狀態

- Task0 measure ✓ / Task1 戰內崩點修 ✓ / Task2 loot-PAY 食側閉環 ✓
- Task3 survival-trap 自解 ✗ **上游阻**（軌2，非本軌可解）
- Task5 守恆閘 ✓：headless `=== DONE ===` 無 SCRIPT ERROR、coin_eq 全池守恆、InvariantAudit 0、framework **7/7 PASS 0 DORMANT**、multi 0-error coin 守恆 違反0、潰逃-capture 單元測 PASS。

## 連動風險

- `npc_combat` / `anon_tier`：**與 combat_target 軌（軌2）並行同觸 npc_combat**。本軌只碰 `_force_retreat`/`_end_combat` 的 loot + capture 函數 + `capture_routed_as_captive`（rename）；軌2 碰 combat_target field 寫（不同函數）。**merge 序：本軌 rename `capture_wounded_as_captive`→`capture_routed_as_captive` + `_end_combat` loot 內聯改 helper 呼叫，軌2 若也動 `_end_combat`/`_force_retreat` 需人工對齊。**
- `manpower`：captive→pop 同化鏈未改（複用），僅確認接上。
- `encounter`（玩家戰術層 capture）：未碰（本 spec 聚 NPC 征服）。

## 待主 session 確認

1. **★ 主崩在軌2（intent 126→combat 12）**：本軌把「戰若發生」的 capture 補成 PAY，但 capture.total 仍低（3）因戰鬥本身稀有。**capture depth 真起飛需軌2 補 attack→combat 轉化**（targeting/reachability/combat_target 持有）。建議：軌2 merge 後重跑 conquest_measure 看 combat_entered 是否升 → capture.total 才會顯著升。
2. **以戰養戰「人」側慢**：captive→pop 同化鏈已接（measure 見 revolt=2/flee=1 fire），但 `assimilate` 需 morale 0.25→0.75 = ~25 天連續厚待 + captor 存活；戰局 churn 下 **P1Absorb/P1Assim=0**。→ manpower cadence（`CAPTIVE_INIT_MORALE`/`MORALE_KIND`/`ASSIM_T`）疑太慢，人側以戰養戰難閉環。屬 manpower 平衡（本軌未動，呈報）。
3. **決勝-absorb 亦餓**：唯一 decisive win（Team30 v43）敗方 anon 已被 round-casualty 打光（`no_absorb_no_anon`）→ absorb 0。若要決勝也「真得人」需調 round casualty vs capture 平衡（casualty 吃掉可俘 pop）；本軌聚潰逃主流路，未動 round casualty（動它重塑全戰鬥平衡，風險大）。
4. **seeded harness**：memory 記 warring 已 seed 化（WarringHarness/seeded_warring_bed）；本 worktree 基於 5a8ab9f 用 unseeded conquest_measure。軌3 seeded 若已 merge，建議用其硬斷 capture.total 回歸。
5. **TEST VALUE**：`HEALTHY_ROUT_FACTOR=0.35`、loot 量級沿用既有 `LOOT_RATE=0.3`。measure 未見 over-war（teams 42→103→78 churn，未爆未全滅），但軌2 補上後戰鬥變多，需重驗不 over-war。
