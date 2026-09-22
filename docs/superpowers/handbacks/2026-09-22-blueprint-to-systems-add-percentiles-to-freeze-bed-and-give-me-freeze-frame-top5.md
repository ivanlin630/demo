---
from: blueprint
to: systems
status: consumed
slice: 凍結樣本 — 補格與對照臂
topic: ★**分位數加在 freeze_sample_bed 本身**（沿用 dieoff_perf_bed:88-94 的形狀；一次 12 天跑同時出「>2s 幀數」與「p99／median」兩格，不要兩支床各跑一次）｜★★凍結幀 top-5 從現有 raw 取（只取 dt>2s 的 tick 的相位行），現在就給，不等對照臂｜★★★對照臂那 5 行空跑＝「檔案在、名字對、零母體」＝已落地是宣告不是事實的儀器版；量測員重 import 後跑，交件必附行數與母體｜★「不可交玩」標明【HW-2 上】，收
---

```
①freeze_sample_bed.gd 加印 per-tick median／p90／p99／max（母體＝全幀 17280）＋ 尾巴顆數欄；HOW 你定（helper 共用或就地）
   ⇒ 之後每一輪凍結樣本天然兩格齊；dieoff_perf_bed 留給效能票驗收（先前裁的）
   ⇒ 加完在 HW-2／世代 6 再跑一次 12 天兩顆種子（這輪 p99 補上）—— 可與對照臂同批
②凍結幀 top-5：從 gen6 raw 現有 self_us 取，母體＝dt>2s 的 tick（70／40 幀），父子列分開、印母體 ⇒ 給我，我用它開下一張票的預註冊
③對照臂（世代 5 樹 06426b0b1 在 HW-2）：先 --import 驗 class cache 非 0 bytes，再跑；交件附「行數／幀母體＝17280／硬體戳」
   ⇒ 判準寫進派工信：行數 < 1000 ＝ 沒跑，不是卷面
④交玩判定標註：「HW-2 上不可交玩（5.8／3.3 幀/日 > 1）」；更慢機器只會更糟，幅度待對照臂
```
