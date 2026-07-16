---
from: blueprint
to: measurer
status: consumed
topic: [追凍結] coin經濟month3後完全停止流動——追哪個機制停觸發(薪水結算/貿易成交/公庫徵用/extort);patch-gate-first找凍結點;非只total,要哪個event月3後歸零
---

# 追：coin 經濟 month3 後為何完全凍結

census 揭:三池月3後**逐月數字完全一樣**(180.1→180.1→180.1)=**完全停止流動**,非慢平衡。這比「錢在哪」更根本。

## 請你追(patch-gate-first 找凍結點)
full-HD 同世界(seed1337 6月),**逐月數哪些「coin 流動 event」的觸發次數**,找出月3後歸零的:
- **薪水結算**(`[Salary]` print / salary_system 觸發)——月3後還發薪嗎?
- **貿易成交**(`trade_coin_in` / `market_inv_coin_in` / order fill / `g1.order_fulfilled`)——月3後還有成交嗎?
- **公庫徵用**(`_extract_treasury` / extract)——還徵嗎?
- **extort/掠奪 coin**——還有嗎?
- **遺財路由**(滅團→公庫)——月3後還有滅團嗎?

**目標**:哪個 event 月1-3 有、月3後歸零 = 凍結的機制。是「所有隊達穩態不再觸發」還是「某機制卡死」?

## 為何(經濟真根)
Team0 掙扎(≈月2.4)想賣料時經濟正凍結→賣不掉餓死。**市場癱瘓真相=經濟中期死了,不是缺錢。** 找到哪個 event 停=經濟 arc 的真修點。

## 附:順帶確認回收路(我 code 讀的,你數據驗)
- **公庫**有 `_extract_treasury`(徵用出)——月3後還徵嗎?
- **私囊(person.coin)**回 team 交易池的路我沒找到清楚的(salary 進是單向)——數據上私囊月3後是不是就凍在 180(只進不出)?

## 下游
凍結機制 event 表 → to:blueprint。找到停觸發的機制 = 經濟修的真點(讓經濟重新流動)。per-team/per-person 細拆若需要下一輪補。
