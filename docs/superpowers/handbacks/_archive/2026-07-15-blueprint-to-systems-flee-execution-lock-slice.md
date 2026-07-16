---
from: blueprint
to: systems
status: consumed
topic: [藍圖意圖·觀察後首個真問題] survival/逃跑路徑缺執行鎖=真bug(QA故事驗:Team1逃跑決策128天re-commit3080次,75%人生churn);=aggregate逃跑巨量根因非情緒太高;連backlog survival-latch同根,升slice;patch-gate-first
---

# 藍圖意圖：survival/逃跑執行鎖（live 觀察後第一個真問題）

full-HD 觀察 + 故事 QA（修好 tracer churn 現形）揪出的**第一個真設計問題**。這是「先有結果→讀故事→定真問題」的兌現。

## QA 故事驗證的真 bug（非我猜）
Team1 全生命讀：前半連貫好戲（貿易→掠奪打輸→逐格戰損死），**後 75% 人生（day51.7-180,128 天）= churn**：
- task="逃跑" 鎖死,`threat_id:7`/target `[-1,-1]` **一路到 day180 沒變過**。
- 抽樣 11 筆逐欄核:util 到小數點後 15 位**完全相同**、threat 資料**凍結**(非活威脅)、每 tick 重觸 `capture_decision result:"committed"`。
- **同一決策原封不動 re-commit 3080 次**。

## 真根（QA 定位,patch-gate-first 你挖到底確認）
**survival/逃跑路徑缺執行鎖**——不像 buy/trade 路徑（早前驗證會鎖住→靜默→heartbeat 頂）。逃跑觸發後**每 tick 無條件重 commit,永不解除**（對比 Team0 的 return_home 也 re-commit,但 6 天到家就解除轉靜默＝有終點）。逃跑沒有終點/鎖/relatch。

## ★這解釋了 aggregate「逃跑巨量」
`N1_flee 20966/9422`(次於服從第二大反應)**大機率不是「危險世界」,是這 bug**:任一隊觸發逃跑不解除→每天疊 24 筆重複→Team1 一隊 128 天貢獻 3080 筆。**光這 bug 就撐起 aggregate 大半逃跑數。** ∴ 我原疑「情緒太高」被推翻——是 churn 虛高。

## 願景意圖（WHAT）
**逃跑/survival 決策 commit 後該鎖住執行(靜默/relatch 週期重評),不是每 tick 無條件重 commit。** 跟 buy/trade 同一套保護。有終點（到達安全/威脅解除→轉靜默）或 relatch cadence（週期重評非每 tick）。

## 連 backlog（同根,升 slice）
早前 Team26 我 backlog 的「survival-latch:`_evaluate_survival` 別同快照重觸」**跟這同根**（survival/逃跑缺鎖）。當時判非致命 backlog——**現在證據升級**:75% 人生 churn + aggregate 虛高。**升為 slice,現在做。**
- 註:這不是回頭撿被 scrap 的「執行鎖」——那次 scrap 是因買糧真根是海市蜃樓(執行鎖治錯層)。**這次診斷不同**:QA 故事驗證逃跑路徑**真的缺鎖**(對比 buy/trade 有鎖),執行鎖是**對症**。同概念不同 path,診斷坐實才做。

## 驗收
- Team1 式逃跑 churn 消(re-commit 不再每 tick,有終點/relatch)。
- **重量測 N1_flee**（中性 full-HD）→ 應大幅回落(若真是 churn 虛高)。回落多少=衡量這 bug 佔 aggregate 多少。
- 故事 QA:逃跑隊的一生連貫(逃→到安全/解除→轉別的,非終身 churn)。
- 全生命 specimen(修好 tracer)判。

## 邊界
- 只治 survival/逃跑執行鎖。不碰內政/經濟(另線)。
- **別 tune 掉真戲**:Team0 全程、Team1 前半是好戲,aggregate 對應數字別動。

## 下一站
系統:patch-gate-first 挖逃跑為何缺鎖(對比 buy/trade 的鎖機制)→ spec → R² → impl → 中性 full-HD 重跑(N1_flee 回落 + 故事連貫)→ QA → 我批。
