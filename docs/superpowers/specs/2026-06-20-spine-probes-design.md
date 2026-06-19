# 因果脊椎探針（Spine Probes）— 設計 spec

> 系統(HOW)spec。量測 instrumentation，觀測 G1/G2/G3 + 既有功能行為，供 measure-first 平衡判斷。純觀測層，不碰因果（零行為變）。

## 1. 目的

因果脊椎 ①G2 ②G1 ③G3 全 merged，閉環落地。要量魂訊號（誘殺/scout 查證/識破率/線人漲跌/野心升降/訂單履約…）+ 各 TEST VALUE feel，回呈藍圖平衡 pass。現有觀測：`TeamTrace`（移動+經濟基礎+leader 心理，watched [0,1,2,4]）、headless print log、coin_eq、InvariantAudit。**缺** G1 訂單/貿易、G2 關係/野心/vendetta、G3 belief/識破/scout 的結構化探針 + 獨立 named 追蹤 + 跑完彙總統計。

## 2. 範圍

- **兩層**（user 定）：(A) 時間軸取樣（看演化）+ (B) 跑完彙總（看 feel 數字）。
- **Host = `game_sim_test.gd`**（確定 7200-tick 全功能場景：5 team 全 archetype 統領/商隊/敵軍/生產村/流亡 + 2 faction + 玩家指令時程；已有取樣鉤 @:150）。
- **純觀測**：探針只讀+計數，不改遊戲 state。`Probe.enabled` flag 預設 off（一般跑全 no-op），game_sim_test 開。
- **OUT**：改遊戲行為、新平衡值（探針只**揭露** feel，調值是藍圖平衡 pass）、UI 視覺化（純 text log）、game_sim_multi 整合（unseeded drift 不可重現，本探針走確定 game_sim_test）。

## 3. 代表選擇

- **代表 team**：`WATCHED = [0,1,2,3,4]`（擴現 [0,1,2,4] 補 Team3 生產村 = G1 訂單/需求消費端）。涵蓋全 archetype。
- **代表 named**：5 隊 leader（統領/商隊長/敵軍將/村長/盜匪頭）+ **auto-pick** 全場最高 `計謀` named_member（謀士，G3 識破/說謊）+ 最高 `野心` named_member（爬升者，G2 階梯）。按屬性選，適應場景非寫死 id。

## 4. Layer 1 — 時間軸取樣（`spine_trace.gd`）

仿 `TeamTrace.dump(state, tick)`：每取樣點對 watched team/named 印結構化行（有訊號才印，免噪）。現 `TeamTrace` 行保留（base 狀態）。新增分脊椎行：

- **`[G1]` Tx**：`order_target_id`/`order_task`、coin/food/material/goods、商隊套利動作（買單/撲空）、鑄幣（自有 outpost）。
- **`[G2]` Tx**：`ambition_rung`/`archetype`/`cap`、relation_edges 計數（feud/gratitude/protect/trust）、`vendetta_target`。
- **`[G3]` Tx**：belief claim 總數 + 對關鍵目標（best uncertainty / claim 源數 / 最高 cred 源型別）、scout 狀態（task=偵查 reason scout）、`known_reputations`（trust）min/max/avg、最近識破 flag（is_suspicious 數）。
- **`[Named]` <leader/member>**：skills(統領/偵查/計謀/戰術/商業)、values(慎重/野心/好戰/殘忍/貪婪/信義)、ambition rung（所屬 team）、relation_edges 摘要、loyalty/stress/fear。

格式：一行一實體一脊椎，prefix `[G1]/[G2]/[G3]/[Named]` + `d<day> T<id>` 對齊 TeamTrace，方便 grep 分類。

## 5. Layer 2 — 跑完彙總（`probe_stats.gd` = `Probe`）

static 累計器：`Probe.enabled:bool`、`Probe.counts:Dictionary`、`Probe.bump(event:String, n:=1)`（gated）、`Probe.note(event, value)`（記分佈/峰值）、`Probe.summary()`（結尾印）、`Probe.reset()`。事件點插 1 行 `Probe.bump(...)`。

統計項（事件點打點）：
- **G1**：`g1.order_placed` / `g1.order_fulfilled`（→履約率）、`g1.trade_exec`、`g1.arb_attempt`/`g1.arb_hit`、`g1.mint`、`g1.shortage_buy`。
- **G2**：`g2.ambition_promote`/`g2.ambition_demote`、`g2.vendetta_trigger`、`g2.feud_formed`、`g2.faction_found`/`g2.faction_conquer`。
- **G3**：`g3.scout_dispatch`/`g3.scout_converge`/`g3.scout_timeout`、`g3.detect_信假`/`g3.detect_生疑`/`g3.detect_裁決`、`g3.trust_up`/`g3.trust_down`、`g3.ambush`（攻信弱實強 / 攻方敗）、`g3.claim_peak`（note 峰值）。
- 既有（combat/death/coin_eq）不重複，沿用。

summary 印：各計數 + 衍生率（履約率=fulfilled/placed、scout 收斂率=converge/dispatch、識破分佈）。

## 5a. 誘殺判定（g3.ambush）

事件點 = 戰鬥結算。`ambush` = 攻方發起攻擊時其 belief 認為 prey 弱（best_estimate armed/pop 低）但 prey 真實力高（actual armed/pop 顯著高於 belief）且攻方敗。打點在戰鬥解算處比對「攻方對 prey 的 best_estimate」vs「prey 真值」vs「結果」。TEST VALUE 門檻（belief 低估比例 + 敗北）。

## 6. 隔離 / 檔案

- `scripts/debug/spine_trace.gd`（新，`class_name SpineTrace`，static dump；不依賴 production 寫端，純讀）。
- `scripts/debug/probe_stats.gd`（新，`class_name Probe`，static 累計器）。
- 事件點鉤 ~12-15 處各 1 行 `Probe.bump(...)`（belief_system 識破/trust、faction_ai scout/野心/vendetta/誘殺、message/order 訂單、merchant 套利、mint）。**flag gated**（`Probe.enabled` 預設 false → 一般跑 no-op）。
- `game_sim_test.gd`：開頭 `Probe.enabled=true; Probe.reset()`；取樣鉤加 `SpineTrace.dump`；結尾 `Probe.summary()`。

## 7. 影響 / 風險

- **行為零變**：bump 只計數不改 state。守恆/AI/決策不動。回歸（headless_test/multi）不受影響（flag off）。
- **perf 可忽略**：gated bool 檢查 + 偶爾 dict++。
- **風險 = 打點精度**（放錯位置計數不準），非遊戲破壞；審 diff 可捕。
- game_sim_test 確定場景 → 探針數字可比較（非 multi unseeded drift）。

## 8. 驗收

- `game_sim_test` 跑完無錯 + 既有不變量/coin_eq 維持（flag on 不破）。
- Layer1：`[G1]/[G2]/[G3]/[Named]` 行出現、可 grep 分脊椎讀演化。
- Layer2：`[ProbeSummary]` 印各計數 + 率；至少 scout/識破/野心/訂單 有非零取樣（脊椎在動）。
- flag off：headless_test 全綠零行為變（探針 no-op）。

## 9. 給實作（plan 拆）

- Task1 `Probe` 累計器 + flag + summary（+ 自測 bump/summary）。
- Task2 事件點打點（G1/G2/G3 各系統 1 行鉤，gated）。
- Task3 `SpineTrace` 時間軸 dump（G1/G2/G3/Named 行 + named auto-pick）。
- Task4 game_sim_test 接線（enable/dump/summary）+ 回歸（flag on 場景跑通、flag off headless 零變）。
