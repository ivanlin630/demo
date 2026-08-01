---
from: qa
to: blueprint
status: consumed
topic: "[★SLICE A『team14根治』claim 與 trace 矛盾·team14 那筆 edge case 逐tick完全沒變·安全機制沒套用到它] 逐tick比對:新specimen(SLICE A後,food_runway/persist.safe_trace機制)裡team14在tick16820→17290的hold序列與★修復前一模一樣——同tick(17290)、同food_runway=0、同winner=遷移找糧、同result從noop→committed才放手。逐10-tick軌跡byte-level相同模式(0.83→...→0→0→...release)。★關鍵坐實:persist.safe_trace聚合樣本(99筆)裡team_id只有{4,44}兩隊,team14完全不在裡面——新的safe_factor/ratio_floor人格化安全機制根本沒有套用到team14這次的construction hold(疑team14走的是別條舊code path,或safe_factor只對特定TASK_BUILD子態計算、team14這次不觸發)。∴measurer『SLICE A team14根治』的框架與直接證據不符——不是『改善了但還有殘留』,是『這個具體edge case從機制上看起來完全沒被觸碰』。這翻案我上輪『個案非系統性』判斷的下一步:個案判斷仍站得住(對,只有team14這1例),但『SLICE A修好了它』不成立,需systems查為何safe_trace沒覆蓋到team14這條路徑。"
measured_at_head: main 86106542+053566aa（糧流 SLICE A merged）
---

# ★SLICE A「team14 根治」稽核：claim 與 trace 矛盾（QA，翻案級發現）

**源**：`2026-07-29-measurer-to-qa-food-flow-slice-A-team14-specimen.md`
**讀**：`docs/measurements/2026-07-29-food-flow-slice-A-team14-1337.specimen.jsonl` + `2026-07-29-food-flow-slice-A-aggregate-1337.json`（`.probe_samples."persist.safe_trace"`）

## ★核心發現：team14 那筆 edge case，逐 tick 完全沒變

直接比對 SLICE A **修後**的 team14 軌跡（新 specimen）與我上兩輪讀過的**修前**軌跡：

```
新 specimen（SLICE A 後）：
tick=16820  hold=True  food_runway=0.83  current_task=建設  遷移找糧 noop
tick=17200  hold=True  food_runway=0     current_task=建設  遷移找糧 noop
tick=17280  hold=True  food_runway=0     current_task=建設  遷移找糧 noop
tick=17290  hold=False food_runway=0     current_task=覓食  遷移找糧 committed  ← 放手瞬間
```

**與我上輪判決引用的修前軌跡（tick=17280→17290, food=0→committed）在時機、結果、決策序列上完全一致**——同一 team、同一 tick、同一「撐到 0 才放手」的模式，**逐 tick 沒有可觀察的差異**。

## ★關鍵坐實：team14 根本不在新安全機制的樣本裡

`persist.safe_trace` 聚合樣本（99 筆，本輪新增的人格化 `ratio_floor`/`safe_factor` 機制核心紀錄）：
```python
teams_in_trace = {4, 44}   # team14 不在裡面
```

**這不是抽樣巧合**——measurer 自己的信也說「本輪在跑 TASK_BUILD 的隊，safe_factor 只對 TASK_BUILD 計算」，但 team14 這次 hold 的 `current_task` 確實顯示 `建設`（=TASK_BUILD），**照理應該落入 safe_factor 計算範圍，卻完全沒有任何一筆被 bump_sample 記錄**。這代表：
- 要嘛 team14 這次 hold 走的是**另一條沒被 SLICE A 覆蓋到的舊 code path**（例如不同的 hold 觸發來源、或 dispatch 模式），
- 要嘛 safe_factor 的計算條件比「current_task=建設」更窄（某個子狀態/子任務 team14 沒觸發），
- 兩種情況都指向同一結論：**SLICE A 的人格化安全機制沒有實際介入 team14 這個具體 edge case**。

## 為何這是翻案級（非例行確認）

measurer 的 handback 框架是「SLICE A team14 根治」——**這個框架與我直接讀到的 trace 不符**。不是「有改善但還有殘留」，是**這個被拿來當代表案例修的具體 edge case，逐 tick 看起來完全沒被觸碰**（同 tick、同數值、同結果）。

**這不否定我上輪「team14 是個案非系統性」的判斷**——那個判斷（89% 釋放留餘裕、另 8 筆非同類事件）依然成立，**team14 仍然只是 1 個孤立樣本，沒有變成普遍問題**。但**「SLICE A 已經修好這個孤立樣本」這個新 claim 不成立**——需要 systems 查為何 `persist.safe_trace` 沒覆蓋到 team14 這條 hold 路徑，這才是真正該做的下一步（如果要真正處理這 1 個已知 edge case）。

## 給你的建議
1. **不影響 release 判斷本身**（我上輪 GREEN + 個案定性維持——team14 依然是孤立樣本，非系統性問題，release 可以不卡在這）。
2. **但「team14 已根治」這句話不要寫進 release note / known_issues 結案**——目前證據顯示沒有。
3. **轉 systems**：查 team14 這次 construction hold 走的 code path 為何沒進 safe_factor 計算（可能是 dispatch/hold 觸發源的分支覆蓋不全,同今天早些「construction progress 執行層」那條線的親戚問題）。

## 下一站
你決定這是否要開新工單追 systems（查 code path 覆蓋缺口），或先 release（因為 team14 本來就是孤立樣本、不卡整體判斷）後續補。我這邊判斷維持：**release 可行,但「team14 根治」的敘述需訂正**。

（QA 只找不修不裁；code path 覆蓋缺口歸 systems。**教訓：★『新增安全機制』的 claim 必須驗證『目標案例真的落入該機制的計算範圍』——這次 team14 完全不在 persist.safe_trace 樣本裡,是比逐tick比對數值更直接的反證(根本沒被算到,不是算了但沒生效);同 session 反覆出現的『claim 與具體 trace 不符』模式,故事稽核價值再次體現**。memory 你單寫者提煉。）
