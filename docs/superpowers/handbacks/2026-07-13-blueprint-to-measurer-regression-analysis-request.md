---
from: blueprint
to: measurer
status: consumed
topic: [★用戶裁定·補回歸驗證] 分析既有main_story_trace_v7.txt+v7_established_3mo.json,查faction協同/飢荒/戰鬥細部有無被今日決策引擎7步改動波及
---

# 補回歸驗證：分析既有log，非重跑模擬

## 背景
用戶對「決策引擎架構重構」四個延續選項裁定：**補回歸驗證**。

今日7步改動（S1需求感測/S2 coeff表/T1-T5正規化/cadence重構/survival-path/dispatch fallthrough/⑦重評收斂）只驗過「決策引擎本身」維度（reeval次數/attrition/established/winner分布），faction協同/飢荒/戰鬥細部這輪沒空細查。

## 已確認：資料在，不用重跑
查過既有產出檔，三塊資料狀況不同：

| 塊 | 狀況 | 位置 |
|---|---|---|
| 飢荒/經濟 | 逐日事件已存在 `[Famine] Team14 餓死 anon 1(famine=7天)`、`[Site] 派工失敗:資源不足`；json有`farming_final`聚合 | `tools/orchestrator/runs/main_story_trace_v7.txt`（29140行）+ `v7_established_3mo.json` |
| 戰鬥細部 | 逐場 `[Combat Start] Team-1000000 vs Team7`；json有`combat.ended_n`/`conq.declared`等聚合 | 同上兩檔 |
| faction外交/協同 | json無外交欄位；txt只有零星`[IndepStrategy]...結盟`——**原始事件密度本身可能就稀薄**，需先查`scripts/simulation/faction_ai.gd`確認是code邏輯本身簡單、還是有邏輯沒打log，才能判斷是否要求補log再驗 | 需查code |

## 請做
1. 從既有 `main_story_trace_v7.txt` + `v7_established_3mo.json` 撈飢荒/戰鬥兩塊事件，統計「今日改動前後」有沒有異常（崩潰次數暴增/戰鬥決策卡死/跟預期不符的模式）——**用當前main HEAD=cef31e2跑出的這份trace跟你認知的改動前基準比**，不是重新跑模擬。
2. faction協同：先查`faction_ai.gd`判斷資料稀薄是設計如此還是漏打log，回報判斷，不用急著補log（除非你判斷這是回歸驗證的必要條件）。
3. 有異常→ handback給systems定位；無異常→ handback回blueprint結案，四選一標記完成。

## 邊界
不用重跑headless模擬（除非你判斷既有log不足以下結論）。這輪目的是「有沒有被今天改動波壞」，非全新可玩性評估。
