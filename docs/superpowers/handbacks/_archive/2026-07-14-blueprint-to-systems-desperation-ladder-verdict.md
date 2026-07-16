---
from: blueprint
to: systems
status: consumed
topic: [WHAT裁定] 真根修方向=A+B+C(買糧look-before-leap+絕境遷移找糧+連貫窮死);執行鎖廢;D經濟供給題defer觀察/gen重校arc;連Team18
---

# WHAT 裁定：真根修 = A + B + C（連貫絕境階梯）

你挖到底＋自省對。真根＝**買糧海市蜃樓（applicable 不驗真買得到）+ 隊困死選項（不遷移）**＝「慾望不配現實」的系統級版，正是決策模型 v2 該防的。我裁方向,你 spec HOW。

## 裁定：A + B + C 一起（這才是完整的「死前奮力求生」）

**A. 買糧 look-before-leap（收）**：applicable 加「真買得到」gate——有 coin>0 且**在場/可達食物賣方**,或**可達 barter 對象有糧且要我的貨**。海市蜃樓時不入候選。鏡射 Fix4。**這是「慾望配現實」在求生層的落地**：買不到就別把「買糧」當慾望目標。

**B. 絕境遷移找糧（收，新行為）**：當地求生選項全不可 fulfill（無糧市/無野味/無 barter 對象）→ 隊**移動去找糧**（最近野味 tile / 有供給的糧市 / 已知賣方）。**這是「奮力求生」的核心**——困死選項＝坐著等死＝你否決的;真正奮力＝**離開死市集去找活路**。加進絕境階梯（覓食→**遷移找糧**→乞食→掠奪→併入）。

**C. 連貫窮死（收，當驗收準）**：真四方無糧（覓/買/搶/投靠/遷移全落空）→ 餓死＝合法悲劇（判準表 窮死 ✅）。**但 winner 必須連貫**——「拼命找糧、四處落空」的 trace,**非「死守買糧海市蜃樓」**。故事 QA 驗此。

**A+B 是機制,C 是驗收**。三者合＝隊不再守幻覺、會奮力遷移、真絕境才連貫地死。

## 執行鎖：廢
`feat/survival-execution-lock` 的執行鎖治錯層,**廢**（真根修好→買糧不選海市蜃樓→隊 fall through 到可 fulfill 選項或遷移→thrash 自然消,執行鎖不需要）。**觀測 infra（交易/威脅 tap、bed 死亡偵測修）cherry-pick 進 main**（純有用,留著）。

## D 經濟供給題：defer，非現在
「餓世界食物不流通（無賣方）→ 買糧本就該罕見」＝真問題,但 **A 已處理即時面**（無賣方→買糧非 applicable→隊改覓食/遷移/搶）。**「要不要做食物市場供給（settled 隊更願賣糧）」＝經濟 arc/gen 重校題**,且 **full-HD 一開 breed/reactions 後糧供給動態全新** → 這題**併進 full-HD live 觀察 slice**（先看糧到底怎麼流,再決定供給要不要補）。我跟用戶提了,他要碰再拉。**本修不解 D。**

## Team18 同根
孤隊卡 31 天買糧迴圈 death-limbo＝**同海市蜃樓根**（買糧永不出貨→永吃不飽）+ 可能死亡判定沒觸發。A+B 修好應一併解（買不到→遷移或連貫死,非卡 limbo）。重跑驗證時一起看 Team18。

## 下一站
系統：patch-gate-first 重 spec 真根修（A+B,C 當驗收準）→ **reviewer R②**（這次挖到底＋大框改求生路,升異質框外審都可）→ dispatch → measurer 重跑（Team20+Team18+新死隊 specimen）→ QA 故事複判連貫性 → 我批 merge。執行鎖廢、tap/bed cherry-pick main。D 併觀察 slice。
