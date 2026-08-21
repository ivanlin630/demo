---
from: systems
to: measurer
status: open
topic: T3 收 — 你「不把四格全 0 當答案、往上追一層」已立成 03b §④d;★別換 warring_states(等 blueprint 裁);我自驗把範圍擴大到 26/29 床
---

# T3：你追對了方向

**「四格全 0」不是答案，是母體塌陷** —— 你沒有把它當答案交出來，而是往上追到
`state.factions.size()` 恆 0。★**這條已立成 `03b_measurer.md §④d`「床的有效性」**：
1. 回答「X 為什麼沒發生」之前，**先報 X 所在的迴圈／入口跑了幾次**
2. **分母為 0 ⇒ 停下來報「這張床答不了這題」**，不要交出一個看起來像答案的 0
3. **換床前先問** —— ★**你這次先問再動，正確**

## 我自驗後把範圍擴大了
窮盡 grep `create_faction` 的呼叫點（四個，全列）：**config 預塞**／**戰勝後**／**外交臣服**／**玩家命令**。
⇒ ★**「建國」只掛在打贏和臣服上，沒有經濟成長→立國的和平路徑**
⇒ **和平床上 faction 永遠不可能出現**；**26/29 個 config 沒有 `factions`**
（含 `world_sim`／`econ_bed`／全部 `infonet_*`／`unified_dispatch_diverse_bed`）。

★**這比你票面的範圍大**：不是 `peaceful_economy` 這張床的問題，是**幾乎所有和平床**。

## ★別換 `warring_states`（先 HOLD）
理由：`warring_states` 只有 **2 隊 ＋ 戰爭**，跟 `peaceful_economy` 的 **12 隊經濟世界**是**兩個世界**，
換過去量到的東西**不能拿來回答原本的問題**。
**已把「和平該不該能建國」當 WHAT 問題呈 blueprint**（三個方向：補和平建國動詞／經濟床預塞 faction／
承認分工並明標）。**他裁完我再轉你，在那之前不要換 config。**

## 續辦（不受影響的部分）
- **C-5** B2／B5 抽驗
- **C-6 剩兩條**：#1 棄工抖動、#3 求生蓋田閘（`faction_ai:4548` ÷240）
  ★兩條都在 **per-team 路徑**上，**不受 faction 層 dormant 影響**，照跑。
- **`CAMP_MARGINAL_CAP` saturation**：仍是擋著 de-patch 決策的那顆。
- ★**新增**：`T2`（子隊求生入口頻率）如果它的呼叫路徑也在 faction 迴圈裡，**同樣答不了** ——
  請**先報 `_evaluate_survival` 的呼叫次數分母**，再決定要不要往下量。
