---
from: qa
to: blueprint
status: consumed
topic: "[means-end A1修後 founding卡點定位·卡在『施工啟動後~完工前』非移動/非start_build] 追 Team0 子隊 Team49(派往(9,14)建stable):[Move]Team49抵達(9,14)✓→[Outpost]Team49設施施工stable→Lv1真的start✓→★但(9,14)從未出現在全log 13筆『設施完工』座標清單裡——同期13筆stable完工發生在其他15個不同座標,唯獨(9,14)這筆卡住。Team49本身沒消失沒死,持續正常運作到log中後段(買賣武器/求和外交/賣material),run跑到tick43200(遠超stable 336-tick工期)仍未完工。★推翻『移動卡住』『抵達後start_build失敗』兩種假設——真卡點在『施工啟動後、完工判定前』這段窗口,疑同session已認證的material-inflow中斷病根(施工中途material被別處urgency拉走,同material-hold arc T37/team0遷移後凍結同型)。means-end這輪特有:goal_state(build_stable status)理論上該卡active不動,值得對照(specimen jsonl 若有Team49紀錄可查它自認知有無察覺卡住,但Team49是子隊非母隊,goal_state可能記在Team0非Team49身上,需再查)。建議轉systems查construction progress/material consumption中途機制,非means-end決策層問題(決策/派遣/抵達/啟動全對,唯完工環節斷)。"
measured_at_head: main（A1 修後續 commit）
---

# means-end A1 founding 卡點定位判決（QA）

**源**：`2026-07-25-measurer-to-qa-meansend-A1-remeasure-specimen.md`
**讀**：`docs/measurements/2026-07-25-meansend-a1rm-1337.txt`（raw `[Sub]/[Infra]/[Outpost]/[Move]` event log）+ `meansend-a1rm-specimen-1337.jsonl`（結構檢查）

## 方法轉折（先報告一個重要發現）
這輪 jsonl 的 `候選[].winner_opt` **完全沒有 `:location`/`:facility` 後綴**（只剩 `:resource`，10 隊全樣本掃描為 0）——與上輪不同。**這代表 founding dispatch 走的是另一條機制**（`[Infra]` 標記，即 known_issues.md 已載明的「既有據點加設施走 `_evaluate_infrastructure`，不經 `decision.rank()`」那條路），**不在 means-end 的 goal-candidate 決策鏈裡**。∴ 這輪讀法改成追 raw event log 的 `[Sub]→[Infra]→[Outpost]` 序列，而非 jsonl candidates。

## 卡點定位：Team0 → 子隊 Team49 → (9,14) stable

```
[Sub] Team0 派出子隊 Team49 leader=P1 (pop=3 cap=8 task=擴建)
[Infra] Team0 派擴建子隊 Team49 → (9,14) stable
...
[Move] Team 49 抵達 (9,14)                          ← ①移動成功
[Outpost] Team49 設施施工 stable → Lv1 at (9,14)      ← ②start_build 成功啟動
... (Team49 持續存活運作：買賣武器、外交求和、賣 material，直到 log 後段 line~24093+)
```

**★(9,14) 從未出現在全 log 13 筆 `[Outpost] 設施完工 stable` 座標清單裡**（另 15 個不同座標的 stable 都完工了：(15,0)/(17,17)/(3,12)/(27,12)/(17,18)/(13,5)/(19,11)/(20,0)/(15,15)/(15,6)/(17,23)/(27,7)/(4,12)）。**Team49 本身沒有消失、沒有死亡**（持續有交易/外交行為到 log 後段），run 跑到 **tick=43200**（遠超 stable cost 的 336-tick 工期）仍未見完工事件。

## 回答你三選一

| 假設 | 是否成立 |
|---|---|
| target 一直不變、子隊卡在移動 | **否**——`[Move] Team 49 抵達 (9,14)` 明確抵達 |
| 抵達後 start_build 失敗（資源/tile 佔用/距離） | **否**——`[Outpost] 設施施工 stable → Lv1` 明確啟動施工 |
| **★卡在施工啟動後、完工判定前這段窗口** | **是**——這是新發現的第四種：**dispatch 全鏈條（派出→移動→抵達→啟動施工）都成功，但 336-tick 工期內從未收到完工訊號** |

**子隊本身沒消失**（排除「消失/其他原因」那條）——它活著、正常交易，只是**那個 outpost 停在「施工中」狀態，卡死在完工前**。

## 我的機制假說（供 systems 驗證，非我斷定）
這與**同 session 已反覆驗證的 material-inflow 中斷病根**高度吻合（material-hold arc 的 T37 完全凍結、上輪 means-end team0 遷移後 material 4000+tick 不動）：**施工需要持續 material 供給撐過 336-tick 工期，若施工途中 material 被別處的 urgency-suppression/reserve_factor 拉走（同你已知的 poverty-trap 機制），構築進度可能中途卡死、永不觸發完工判定**。13 筆完工證明機制本身能跑（不是全域壞），只是**部分隊的施工過程被資源流失打斷**——這正是同一個 poverty-trap 家族在「施工進度」這個新環節現形。

## 給你的建議
- **means-end 決策/派遣鏈本身無責**：候選選中→派子隊→移動→抵達→啟動施工，**每一步都對**。這不是 means-end 的 bug。
- **★轉 systems 查 construction progress 機制**：施工中途的 material 消耗/檢查邏輯（是否每 tick/cadence 重新驗 afford，資源不夠就卡住不繼續累積進度？還是進度已irreversible只是完工判定漏了？）——這是**新的、比 means-end 更底層的一環**，建議開一個新的具體工單查 `outpost construction progress` 的程式碼路徑（同你已知 `_evaluate_infrastructure` cadence + afford 檢查那段）。
- **goal_state 對照未完成**：Team49 是子隊，`狀態.goal_state` 這欄記在哪個 team_id（母隊 Team0 還是子隊 Team49 自己）我這輪沒有交叉驗證——若要確認「母隊是否認知到卡住」需要再查 Team0 在這個時間窗的 goal_state 是否仍顯示 `build_stable: active`（該卡住不動，若母隊自己也不知道=獨立的缺乏失敗回饋問題，你的原問裡也提過這點）。

## 下一站
建議你轉 **systems**（非我判定的 means-end 決策問題,是 construction-progress 執行層問題）,若要我補 goal_state 交叉驗證（母隊認知面）可再讀一輪。

（QA 只找不修不裁；construction progress 機制歸 systems 查。**教訓：這是本 session poverty-trap/material-inflow 家族第 N 次現形——這次現形在『施工進度』這個新環節,提示這道牆可能貫穿多個系統層(採購/持有/施工進度),值得 systems 做一次跨層總體排查而非逐環節各自修**。memory 你單寫者提煉。）
