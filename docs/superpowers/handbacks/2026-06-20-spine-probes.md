# Hand Back: 因果脊椎探針（Spine Probes）

branch: `feat/spine-probes`（已 push origin）

## 實作摘要

純觀測量測探針，兩層：Layer1 時間軸 dump（SpineTrace）、Layer2 跑完彙總（Probe counts/rates）。flag gated，預設 off → 一般跑 no-op，只 game_sim_test 開。零行為變。

新檔：
- `scripts/debug/probe_stats.gd`（`class_name Probe`）：`enabled`/`counts`/`peaks` + `bump`/`note`/`reset`/`summary` + `ambush_check`（誘殺判定 helper，信弱實強→計數）。
- `scripts/debug/spine_trace.gd`（`class_name SpineTrace`）：對 WATCHED team[0-4] 印 `[G1]`/`[G2]`/`[G3]` + auto-pick named（最高計謀/野心）印 `[Named]`。純讀。

事件點打點（各 1 行 `Probe.bump`，gated，置既有事件分支內，不改邏輯）：
- `belief_system.gd`：`record_claim` 尾 `note("g3.claim_peak")`；`reconcile_firsthand` 兩處 `bump("g3.trust_up/down")`。
- `message_system.gd`：識破分支依 `DETECT_*_MULT` 分級 `bump("g3.detect_裁決/生疑/信假")`。
- `faction_ai_system.gd`：scout dispatch/converge/timeout（g3）、arb_attempt（g1）、vendetta_trigger/faction_found（g2）。
- `encounter_system.gd`：攻方(發起者)戰敗 → `Probe.ambush_check`（誘殺檢測）。
- `order_system.gd`：`post_order` `bump("g1.order_placed")`；短缺買單 `bump("g1.shortage_buy")`。
- `outpost_system.gd`：`_tick_mint` 實鑄 `bump("g1.mint")`。
- `ambition_ladder.gd`：demote/promote `bump("g2.ambition_demote/promote")`。
- `npc_ai_system.gd`：feud 邊寫入 `bump("g2.feud_formed")`。

接線：
- `game_sim_test.gd`：開頭 `Probe.enabled=true; reset()`；取樣鉤旁加 `SpineTrace.dump`；結尾 `Probe.summary()` + `Probe.enabled=false` 還原。

測試：`headless_test.gd` 加 4 個 unit（accumulator/ambush_check/g1g2_hooks/spine_trace_dump）。

## 與 spec 的差異

1. **`g1.order_fulfilled` / `g1.arb_hit` 未打點（無乾淨事件點）**：現行 G1 訂單只 expire，**從不標記 fulfilled / 不 decrement qty_remaining**（半-inert，對齊 invariant「撲空=副本過期/失真」）；interaction trade 非 order-aware（只認 herald `order_task`，不認 G1 trade order）。故「履約」「成交」在允許 scope（belief/message/faction_ai/encounter/order/outpost/ambition/npc_ai）內**無真實事件點**。未硬塞假點。後果：summary `訂單履約率=0.0%`、`套利命中率=n/a`（den 有值/無值，num 恆 0）——此即誠實觀測，揭露訂單迴路目前不閉環。
2. plan Task1 commit 只列 probe_stats.gd，但我把 `ambush_check`（Task2 Step3a）一併寫進 Task1 的 probe_stats.gd（減少二次改檔，gated 且 Task1 不引用→無行為風險）。

## 驗證結果

- **flag off 回歸**（`headless_test.gd`）：`=== DONE ===`、無 SCRIPT ERROR、InvariantAudit population/faction/subteam OK、coin_eq 測試通過。既有測試零變動。
- **flag on 場景**（`game_sim_test.gd`）：跑通無 SCRIPT ERROR、`ALL INVARIANTS PASSED (violations=0)`、`[G1]/[G2]/[G3]/[Named]` 共 1812 行、`[ProbeSummary]` 印出。關鍵計數非零：
  - `g1.order_placed=157`、`g1.shortage_buy=134`
  - `g2.ambition_promote=15`、`g2.ambition_demote=6`
  - `g3.detect_信假=84`、`g3.detect_生疑=6`、`g3.trust_down=2780`、`g3.trust_up=2042`、`g3.claim_peak peak=4`
  - 脊椎在動（G1 訂單 / G2 野心 / G3 識破+信任 全活）。

## 連動風險

- **無行為連動**：所有 bump/note/dump/ambush_check `if not enabled: return` gated，預設 false。`Probe.summary` 還原 `enabled=false` 防同進程污染。對遊戲 state 零寫入。
- `game_sim_test.gd` 是唯一開 flag 處；multi/正式跑/headless（除 probe unit 測自身 toggle）全 no-op。

## 待主 session 確認

1. **訂單履約 / 套利成交無事件點**（見差異 1）：若要量「履約率/命中率」非 0，需先讓 G1 訂單迴路閉環（decrement qty_remaining 或 interaction trade 認 order）—— 屬 ③G3 之外的 G1 後續 task，非本探針 scope。目前 summary 0%/n/a 已誠實反映迴路狀態，建議當作 measure-first 訊號（訂單發了沒履約）。
2. **未觀測到的計數**（本場景）：`g3.scout_dispatch/converge/timeout`、`g3.ambush`、`g3.detect_裁決`、`g2.vendetta_trigger`、`g2.feud_formed`、`g2.faction_found`、`g1.mint` 在此 config 場景未自然觸發（=0/缺）。非打點漏（unit 測已驗 helper/accumulator 正確）；若要驗這些脊椎，需設計對應觸發場景（誘殺/血仇/立國/鑄幣 config）。
3. **TEST VALUE**：`Probe.AMBUSH_UNDEREST=0.5`（誘殺低估門檻）。
