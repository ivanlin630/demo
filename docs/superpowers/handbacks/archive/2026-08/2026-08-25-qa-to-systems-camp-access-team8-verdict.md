---
from: qa
to: systems
slice: camp-access
status: consumed
topic: "[QA故事稽核:camp-access重量令]★join.accept_check逐筆交叉確認完全吻合(8筆reject全部accept_util<0.3門檻,無可疑案例)——不需再驗;★team8新outpost故事讀出來但訂正measurer的機制猜測:不是靠『遷移找糧』這個特定winner label,是靠覓食(0命中遷移找糧)→紮營(連續在多個候選tile試,[11,7]→[10,7]→[10,6]→...最終落[13,6])→建設/紮根連續成功,delay修法真正幫到的可能是紮營/紮根這段的持續嘗試,非遷移找糧分支本身"
---

# QA 故事稽核：camp-access 重量令 — join交叉確認 + team8 outpost故事

## join.accept_check ＝ **交叉確認完全吻合，不需再驗**

11筆完整母體逐一核對：8筆 reject 的 `accept_util` 最高只到 `0.238`（`feed_ok=0.567` 那筆），全部低於 `ACCEPT_UTIL_THRESHOLD=0.3`，**沒有一筆是「明顯有食力卻被門檻卡住」的可疑案例**——跟我上輪 code-read + team10 案例坐實的「host側 genuine」方向完全吻合。**這條可以結案，不需要我再額外驗證**。

## team8 新 outpost（`tile[13,6]`）＝ 故事讀出來了，但要訂正一個機制細節

逐 tick 讀 team8 動作序列（tick4560→7610）：

```
tick4560-6610：task=覓食 winner=覓食（tile 在 [10,6]↔[9,6]↔[11,6]↔[11,7]↔[12,6] 間游走覓食，ef 在 0-12 間震盪）
tick6790-7300：task=紮營 winner=紮營（連續嘗試多個候選 tile：[11,7]→[10,7]→[10,6]，ef 掉到 0，target 多次跟 tile 不完全對齊，像是在幾個候選點間找地）
tick7600：task=紮營 winner=紮營，tile=[13,6]==target=[13,6]（★終於落在這格，ef=2.50）
tick7610：task=建設 winner=紮根，tile=[13,6]（★這一刻紮根真的贏了 argmax，對上 outpost 普查記錄的新增座標）
```

**★訂正 measurer 的機制猜測**：**全程 team8 一次都沒有用過「遷移找糧」這個 winner_opt**（我搜了整份 team8 trace，`遷移找糧` 零命中，全部都是普通的 `覓食`）——所以「是不是真的靠遷移找糧找到地」這個問法的答案是**不是那個特定分支**。

**真正的故事**：team8 是靠**覓食（尋常那款，非遷移找糧變體）撐過飢餓 → 紮營在好幾個候選 tile 之間試（連續 6790/6800/6900/7000/7200/7300 這幾筆，target 換了 [11,7]→[10,7]→[11,6] 好幾次）→ 最終在 tick7600 真正抵達 [13,6] 並紮營 → 緊接著 tick7610 紮根成功**。這是連貫、真實的 motive→action→outcome（餓→找地→紮營試探→紮根），**但 delay 修法(`e927be2f`)真正幫到的環節，比較可能是「紮營/紮根這段能撐過連續幾個 tick 的候選試探而不被打斷」，不是「遷移找糧這個特定分支」本身**——這是個值得訂正的細節，免得下一輪往錯的 code 路徑查。

**後續驗證**：紮根成功後 team8 靠 `貿易/build_workshop:resource` 持續進行，ef 從 2.50 一路衝到 tick8810 的 `66.00`（雖然後面 tick12480-17800 有一段又跌回 0 掙扎，但 tick19000 起又靠貿易回彈到 20-36）——跟前幾輪抓到的「一旦有據點，貿易/build_workshop 能撐起食物」的模式吻合，不是孤例。

## 結論

- **join reject**：CONFIRMED，結案。
- **team8 outpost**：CONFIRMED 是真實紮根（非巧合/非別的路徑），但**訂正機制歸因**——不是「遷移找糧」分支，是「覓食撐住 + 紮營候選試探撐過去 + 紮根接上」這整段流程，建議下輪 code-read `e927be2f` 具體改了哪個函式的哪段邏輯，對照這個訂正後的故事再確認 delay 修法命中的是哪一步。

地基 KEEP。
