# Hand Back: Outpost 居民派駐 AI

## 實作摘要

- `scripts/data/team_data.gd`：加 `residency_eval_next_tick`、`invite_cooldown` 欄位
- `scripts/simulation/faction_ai_system.gd`：
  - `RESIDENCY_CADENCE`(720) / `RESIDENCY_COOLDOWN`(1680) 常數
  - `_has_resident_team_on_tile`：tile 是否已有 PRODUCE 團
  - `_evaluate_outpost_residency`：cadence 掃自家無居民 outpost（在 evaluate_all per-team loop 呼叫）
  - `_try_dispatch_or_invite`：個性分派（野心/好戰 → dispatch；商業/慎重 → invite）
  - `_dispatch_subteam_settle`：SubteamSystem.dispatch 派子隊 task=安頓
  - `_try_invite_nearby_exile`：DiplomaticAiSystem invite_settle + 拒絕設 7 天冷卻
  - **`_evaluate_subteam` 攔截 安頓 task**（與 spec 差異，見下）
- `scripts/simulation/interaction_system.gd`：`_convert_to_resident` 結尾 trigger 同 tile 子團+生產 try_merge_back
- `scripts/debug/headless_test.gd`：8 個測試（Task1-6）

## 與 Spec/Plan 的差異

1. **安頓 conversion 改 arrival-based（必要修正）**
   Plan 假設「子隊抵達 outpost tile → 既有 安頓 handler → _convert_to_resident」。
   但既有 `_convert_to_resident` 只在 `interaction._try_interact(a,b)` **pairwise** 觸發，
   需 tile 上有 co-located 同 faction team。子隊抵達**空** outpost 無互動對象 →
   被 `_evaluate_subteam` merge_queue 召回母團 → cadence 重派 → **spam（實測 124 派駐 / 1 settle）**。
   修正：`_evaluate_subteam` 攔截 `安頓` task，抵達自家 faction outpost 即 `_convert_to_resident`。
   結果：124→6 派駐、6 settle，spam 消失。

2. **`_dispatch_subteam_settle` fallback 補 named_members**
   `SubteamSystem.dispatch` 要求 `sub_leader_id ∈ parent.named_members`，但
   `PersonGenerator.generate_for_team` 不會加入 named_members。fallback 路徑（named ≤ 2）
   生成新 leader 後須先 `owner.named_members.append(new_leader.id)` 才能 dispatch 成功。

## 驗證

- headless：8/8 Residency 測試 OK，`=== DONE ===`，無新增 assertion 失敗
- multi（CP950 log）：**Residency 派駐 6 + Settle 居民 6 + Market 成交 2**，無 SCRIPT ERROR
- 既有失敗 `game_sim_test 應 5 team，實際=8` 為**既有問題**（config 已長到 8 team，
  assert 仍寫 5），main branch 同樣失敗，非本 feature 造成。

> 註：multi log 為 Big5(CP950) 編碼，需 `[System.Text.Encoding]::GetEncoding(950)` 讀，
> 用 UTF8 讀會誤判 成交=0。

## 連動風險

- `_evaluate_subteam`：`_convert_to_resident`（含 Task6 merge-back loop 可能 erase team）
  現於 `for tid in state.teams` 迭代中被呼叫。實測無崩潰（merge-back loop 多數無 co-located
  子團+生產 對象不觸發 erase），但理論上 dict 迭代中 erase 有風險。主 session 評估是否
  改為 deferred（收集 settle 清單迭代外處理）。
- **邀流亡 invite 路徑**：流亡 faction_id=-1，安頓 conversion 的 faction 守衛
  （`o.faction_id == sub.faction_id`）使流亡無法經 dispatch 同路徑就地安頓；流亡安頓
  仍依賴既有 pairwise + `_execute_settlement`（設 faction）。本 feature 的 invite 只發
  `[Residency] 邀請` 並設 task=安頓，實際轉居民與否依既有路徑。multi 中 Settle 主要來自
  dispatch 子隊。

## 待主 session 確認

- 派子隊掏空母團風險：cadence 每 3 天可能對多 outpost 連續派子隊，`settler_count` 雖
  `clamp(pop/4,2,5)` 且保留至少 1 人，但多 outpost 累積仍可能削弱母團。建議加母團
  pop 下限總控。
- 子隊無法抵達 outpost（pathing 失敗）時仍會被 cadence 重派（`_has_resident_team_on_tile`
  恆 false）。目前實測無此情況，但建議加 in-flight 派駐去重。
- (iii) leader 個性決定留/回（spec 列為 known_issue）未實作。
