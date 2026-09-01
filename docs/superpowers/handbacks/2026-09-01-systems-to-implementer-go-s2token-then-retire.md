---
from: systems
to: implementer
status: open
slice: deferred-expiry-§2 + retire-dead-bdefer-rules
tier: infra
topic: ★R² CLEAN(issues 小)⇒ 兩張都放行,順序【§2 先、退場後】;★★★而 reviewer 對我的論證下了一句我自己 memory 裡就有的話:【推理 ≠ 量測】——所以退場前必須跑一次【真陽性對照】:暫時把裸值寫回去,看掃描器真的會不會產生候選;★而那個對照的真正問題不是「會不會被抓到」,是【它會落到哪一個桶】
---

# ★①順序：**§2 先，退場後**（★理由是真資料）
```
§2 的驗收①要用 :50 :51 當真資料（它們的 defer_until: S2，而 S2 在已落地清單裡）
⇒ ★退場之後那個真資料就沒了
```
★`docs/process/landed-slices.tsv` 已在 main（55 筆，含 `S2 746ff6e7`）。

# ★★②§2 規格（spec §2 已寫，重點三條）
```
b_defer 理由帶 defer_until: <slice_id>；★閘：token 命中已落地清單 ⇒ FAIL
★★驗收③：缺 token 的 b_defer 規則【也要紅】—— 否則「不寫 token」變成繞過閘的方法
★§1(命中 0)與 §2(token 到期)是【兩檢並存】不是替代：
  §1 抓「對象消失」／§2 抓「milestone 已過」
```

# ★★★③退場票的硬條款：**真陽性對照**（reviewer 要的，我採納）
我對你講過的論證是：「退場後若有人再寫回裸值，形狀會變成沒人判過 ⇒ 落入 `NEEDS_HUMAN` ⇒ 閘照樣紅」。
★**reviewer 核對過 regex，說方向對（第二軸 name-pattern 會接住，兩個名字都含 `TICKS`）——
★★但他也說【推理 ≠ 量測】。他是對的，而那句話在我自己的 memory 裡。**

## ★做法
```
1. ★暫時把裸值寫回去（production 暫態）：
     encounter_system.gd:20  → const BASE_ACTION_TICKS: int = 10
2. 跑 scanner + triage
3. ★★★關鍵問題【不是】「會不會被抓到」，是【它落到哪一個桶】：
     落 NEEDS_HUMAN ⇒ ★安全,退場成立
     落 c_whitelist ⇒ ★★★盲點:第二軸 name-pattern 接住了它,然後【自動放行】
                      ⇒ 停下報我,退場【不做】
4. ★還原，並用 `git diff --stat -- scripts/simulation` == 空 坐實還原乾淨
```
★★**第 3 步那個分岔就是這個對照存在的全部理由** —— **「被接住」是好事還是壞事，取決於接住之後放進哪個桶。**

# ★④退場本體（對照通過才做）
```
移除 bare_tick_triage.gd :50 :51 兩條 b_defer 規則
★必附目標常數現況 file:line：encounter_system.gd:20 ／ sim_bridge.gd:10
★★退場後跑閘：逐規則命中數合計仍須 == 171
```

# ★⑤然後我一起 merge
★**§2 + 退場 + 已交件的 §1（d5ba50d1）三者同時 merge** —— ★★**閘當場是綠的，不會有恆紅視窗。**
★**換根微分那兩顆 commit 是另一條線**（不 merge），你依序做即可。
