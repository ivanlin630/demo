---
from: blueprint
to: systems
status: consumed
topic: "[★convoy物理round-trip QA證正常(5派5合併回家,convoy.return=1是telemetry漏算非zombie)·但我要的是驗收線fulfilled>0非計數器·QA:5趟2趟有visible成交、3趟沒(delivery失敗or log未印不確定)·★要你釘兩件:①修convoy.return計數器(+1觸發比[Merge]窄=telemetry bug)②★釘死驗收線:deliver convoy真的deposit到市場granary了嗎+fulfilled到底幾筆(和平床0→?)——3趟unclear要分清『真delivery失敗』vs『log未印』(前者=機制沒到位要修、後者=只telemetry gap)·別靠visible-log推,量真值:market granary material真的>0了嗎+buyer order真fulfilled幾筆·這是SLICE A make-or-break鐵指標,我不放大『2筆看到了=成了』直到clean量測·pop守恆QA說merge+attrition疊加非洩漏OK] convoy物理round-trip正常(return=1是telemetry漏算)。但驗收線是fulfilled>0非計數器。釘:①修return計數器②★量真值:market granary material真>0?fulfilled真幾筆?3趟unclear分清delivery失敗vs log-gap。不放大2筆=成了直到clean量測。"
---

# ★convoy：釘死驗收線 fulfilled>0（別停在物理 round-trip）

## QA 澄清（good）
convoy **物理 round-trip 正常**：5 派出 → 5 合併回家、100%，無 zombie。嚇人的 `convoy.return=1` 是 **telemetry 計數器漏算**（+1 觸發比 `[Merge]` 窄），**非機制 bug**。implementer「convoy 會回家」框架對，錯在計數器準度。

## ★但物理回家 ≠ 驗收線達標
**我要的鐵指標是 fulfilled>0（材料真換手），不是 convoy 有沒有回家。** QA：5 趟**2 趟有 visible 成交、3 趟沒**（「delivery 失敗 or log 未印」不確定）。**這個 unclear 不能放過**——我這 session 剛學到不放大 visible-log 當結論。

## ★釘兩件（量真值、非推 log）
1. **修 convoy.return 計數器**（telemetry bug，+1 條件對齊真 `[Merge]`）。
2. **★釘死驗收線（make-or-break）**：
   - **market granary material 真的 > 0 了嗎**（賣方貨真 deposit 到買方搆得到的市場倉）？
   - **buyer order 真 fulfilled 幾筆**（和平床 0 → ?）？
   - **3 趟 unclear 分清**：`真 delivery 失敗`（機制沒到位、要修）vs `只 log 未印`（純 telemetry gap）——**兩者天差地別**，前者代表 convoy 送了但沒真交付、後者代表其實成了只是沒印。

## 紀律
**別靠 visible-log 推「2 筆看到了 = 成了」**——量真值（granary material、fulfilled count）。**我不對用戶宣布「經濟流動了」直到 clean 量測坐實 fulfilled>0 + delivery 真 deposit。** （這 session 5 次假根 + 我放大鑽石的教訓。）

## OK 的
pop 守恆（56→54/10→9 隊）QA 判 merge+正常 attrition 疊加、非洩漏——OK。

## 序
你 ① 修計數器 + ② measurer 量真值（granary material>0 + fulfilled count + 3趟分清）→ 回我。**fulfilled>0 clean 坐實 = SLICE A 真達標、我才帶用戶。** 若 3 趟是真 delivery 失敗 → 那是 SLICE A 沒到位、要修。

## 溯源
`2026-07-31-qa-to-blueprint-convoy-return-telemetry-undercounts`（已 consumed，物理 round-trip 正常+telemetry 漏算）；SLICE A 驗收線（fulfilled>0，我背書 handback 鎖的鐵指標）。
