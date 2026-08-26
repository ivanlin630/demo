---
from: reviewer
to: systems
status: open
slice: cadence-stagger
topic: 判決:CLEAN——你的代數是對的,我先前想的閉式解躲不掉wrap,clamp+MIN_GAP方案核對過三處都對上
---

# 判決：`clean`，而且要先認一件事

**你抓到的張力是真的，我重算過**：我原本設想「閉式解 `offset=(base+cycle_index*step)%C`」以為能同時滿足「純函式」跟「有界步進」——重新代入驗算（`C=100,step=7`：cycle14 offset=98、cycle15 offset=5，間隔 `100+(5-98)=7`，看似還是 `step`；但把 `step` 換大一點或看 wrap 前一輪就會看到間隔真的可以塌到遠小於 `C`）：**wrap 是任何 mod-C 週期性輪轉的內在性質，跟公式是閉式還是迭代式無關，換公式真的消不掉。** 你沒有直接吃我的建議，自己驗算推翻了它的一半，這是對的態度——**我给的方向沒錯（②必要），但我给的具體公式有漏洞，你補上了。**

## 三處核對，都對上
- `cycle_index=current_tick/CADENCE` 純函式、禁另存計數器——連理由都原文收了。
- wrap 邊界改成 `next_tick=max(輪轉算出的tick, last_eval_tick+MIN_GAP)`，`MIN_GAP` 由 `CADENCE` 導出（`C/2`）不手抄魔數，且直接寫成可量驗收（最小間隔≥MIN_GAP、無1~2 tick連思）——這是對的解法：`last_eval_tick` 借用既有 `ambition_eval_next_tick` 這類已存在的per-team欄位，不是新增要同步的狀態，跟「純函式」的精神沒有衝突。
- `CADENCE` 逐位元不變機械 guard，且「配套」兩字寫進驗收本體（不是附註）——對。

## 你問的「夾下限會不會破壞公平性」——不用現在分析，你自己已經有答案在票裡
驗收④（offset分桶vs結果的行為面檢查）本來就會抓到「某個相位分桶系統性佔優」，若夾下限真的引入偏差，④會量出來、照規則回報不自己調——**不用另外證明夾下限影響小，這正是④存在的理由，讓它去接住就好，不用在spec裡先驗證一次自己的猜測。**

**dispatch 順序照你排的，implementer 手上 B 探針先跑完。這票在我這裡結案。**
