---
from: implementer
to: measurer
status: consumed
topic: produce_need demand-responsive — measure（製造 bootstrap 子根②·死常數人格化）
branch: feat/produce-demand-responsive
commit: 50337300
spec: docs/superpowers/specs/2026-07-23-produce-need-demand-responsive.md
---

# produce_need demand-responsive — 做完，量測請收

## 改動（2 修，製造 bootstrap 子根②）
子根②：「生產」util `produce_need`=死常數 0.3/0.6（不隨市場）→ workshop 隊沒選生產 → 產 0
（measurer：0 個 manufacture.* probe = 從沒上 TASK_MANUFACTURE）。

- **① `decision_context.gd` gather 加 `c.produce_pull`**：自家可造 outputs（tile facility level>0 的
  RECIPE_GROUPS）的 worst-shortfall ratio = `max clampf((need_keep(out)+demand(out)−hold)/target,0,1)`。
  僅 `has_manufacturing_facility` 算否則 0；hold=`team.resources+public_storage`（對齊 manufacturing:139）。
  ★感知鐵律：`demand()`=`_trade_demand` 讀 `team_known` 親聞單（非 global order book）。
- **② `terms.gd` produce_need**：死常數 → `return ctx.produce_pull`（opt≠生產→0）。
- **觀測**：`decision_engine` 加 tap `produce.wanted_not_chosen`（`produce_pull>PRODUCE_WANT_THRESH`=0.3
  但 rank[0]≠生產→task-competition 輸；Probe-gated observe-only 零行為變）。

## 自驗（皆綠）
- TDD `produce_demand_test` **6/6**。RED 確認：①neuter produce_pull→0.90→0 / ④term 回死常數→0.6≠0.7。
  **★⑤god-view fixture**：他隊(99)有 tools 買單但本隊(1)`team_known` 沒聽到 → produce_pull=0（感知鐵律硬驗，god-view 讀 global 會 >0）。
- headless 0-new（3 baseline：p2a join weight / combat_target 197 / rung intent）。
- gate PASS sites=75（無新閘；produce_pull demand-responsive=utility 非 scripted gate）。
- determinism seed1337×2mo×2 跑 byte-identical MD5 `a2835d99`（純 utility 無 RNG）。
  ⚠ 註：digest 與 tools-demand 同=2mo warring 場景**無行為變**（workshop 幾乎沒建=bootstrap ① 仍閘 workshop-BUILD）——正是本 measure 要坐實的（②修 responsiveness，①workshop-建 是否為剩閘）。

## 量測請抓（spec §驗收，餵 QA 判故事）
1. **`manufacture.*` probe 出現數**（0→?）：路徑是否終於觸發（noop_no_material/no_worker/overflow 各分因）。
2. **選 TASK_MANUFACTURE 隊數**（0→?）。
3. **tools+goods 全域產量**（0→?）。
4. **produce_pull 分布** + `produce.wanted_not_chosen`（想產但 rank 輸→揭②後是否仍卡 task-competition）。
5. **★weaponsmith 建成**（②解後、有 workshop 就通 or 揭子根①傳播是下閘）。
6. 回歸：doom-delta / 無餓死 / **goods 不亂產**（無人要時 produce_pull=0 驗，§④b：有無 workshop 空產）。
7. **★感知鐵律驗**：workshop owner 只對**聽到**（team_known 親聞）的 tools/goods 買單升 produce_pull——
   civ 沒聽到 tools 單（produce_pull=0）= 揭子根①（訊息傳播/市場可達）是下 thread。

床：`godot --path .worktrees/produce-demand` 對 branch 50337300 跑（★禁原地 checkout）。

## 完成判定 = systems + reviewer（merge-gate R²）。做完 → to:QA 判故事：
workshop owner 聽到 tools 好賣 → produce_pull 升 → 選生產 → 產 tools → 進市場 coherent；
**若 civ 沒聽到 tools 單（produce_pull=0）= 揭子根①傳播（下 thread）**。v2b(coin) 續 DEFER。
