---
from: systems
to: measurer
status: open
slice: income-tax-split 前置量測（第⑤票）
topic: ★一顆小量測,可與①墓碑前置量測並行:現制 collect_member_tax 的稅收母體分佈——①總額②per-team③★居民PRODUCE隊佔多少④被 PERSONAL_COIN_FLOOR 擋掉幾次;★★零 production 改動:record_driver 已記 reason="member_tax"(coin_treasury.gd:94-95),開 driver-ledger 過濾即可;★★★但先做陽性對照確認 ledger 真的抓得到那條(過去有 record_driver tap bug),抓不到就回報「儀器沒開」不要回報 0
---

# 前置量測：現制成員稅的稅收母體分佈

**用途**：⑤票要**廢掉**月抽積蓄稅、改成薪資所得稅。而 `salary_system.gd:31` **居民（PRODUCE）隊早退不發薪** ⇒ **它們將沒有所得稅可抽**。這一顆是要答：**那一格有多大。**

## ★要的四個數字（90 日基準床，同 seed）
```
①member_tax 收到的 coin 總額
②per-team（★母體用 state.teams 全隊名冊，不是印出來的那幾隊）
③★★其中【PRODUCE 隊】佔多少 —— 絕對值 + %
④★levy<=0 continue 的次數(被 PERSONAL_COIN_FLOOR=2.0 擋掉) —— ★現制實際抽得到幾次
```

## ★★做法：**零 production 改動**
`coin_treasury.gd:94-95` 已經走 `ResourceBank.adjust_person_coin(...,"member_tax")` / `ResourceBank.add(...,"member_tax")`
⇒ **`WorldState.record_driver` 已經記了 `reason="member_tax"`**（預設 off）⇒ 開 driver-ledger 過濾即可。

★★★**但先跑陽性對照**：確認 ledger 真的抓得到那條 —— **過去有 record_driver tap bug**。
**抓不到就回報「儀器沒開」，不要回報 0** ——「沒抽到稅」與「儀器沒記」長得一模一樣。
（④那格若 ledger 抓不到「沒發生的事」，就明說 ④ 需要一個 L3 tap，我去派；**不要用總額反推**。）

## 序
★**這顆可與①墓碑的前置量測並行**，不排隊。⑤的動工等這顆。
