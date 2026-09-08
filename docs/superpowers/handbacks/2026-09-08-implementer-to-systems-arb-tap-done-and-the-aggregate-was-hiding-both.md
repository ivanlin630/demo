---
from: implementer
to: systems
status: open
topic: ★tap 做完（branch `feat/arb-kill-tap`，commit `c38f5215`，已 push）｜★★而首跑就照出：那個「不可判」是【聚合造成的】，per-res 一拆，兩個假說【都成立、只是在不同資源上】
---

# ① 做了什麼

```
改名  trade.arb_kill_zero_gain → trade.buyer_reject_priced_too_high
      引用同步：economic_window_4cell_bed.gd、defers.tsv:68（ten-zero-gain-reach）
      ★並在 order_system.gd:469-486 把【它比的是誰跟誰】寫死在註解裡
新增  trade.buyer_reject.ask_sum / mine_sum / mine_zero / ask_zero（5 個純量，照裁定不做分布）
床    economic_window_4cell_bed.gd 直接印出判別（含三分支：兩邊趴 0 ／ 開價脫離 ／ 不可判）
```

# ② ★★首跑（warring_states, BED_DAYS=3, seed 1337）

聚合層：
```
n=211｜平均 ask=2.6712｜平均 mine=1.7372
mine_zero=106 (50.2%)｜ask_zero=106 (50.2%)   ⇒ 判【不可判】
```
★而那兩個 50.2% 剛好等於 food 的筆數（food=106 / material=105）——
**不是雜訊，是兩個母體被摻在一起。**

加 per-res 同一組純量（★仍然只是純量，沒有引入 systems 想避免的取樣機制）：
```
[food]     n=106  mine_zero=100.0%  ask_zero=100.0%  平均 ask=0.0000  平均 mine=0.0000
[material] n=105  mine_zero=  0.0%  ask_zero=  0.0%  平均 ask=5.3678  平均 mine=3.4910
```

⇒ ★★★**兩個假說都成立，只是在不同資源上**：
- **food** ＝「全員過剩、誰都不要」（兩邊都趴 0）
- **material** ＝「賣家開價脫離行情」（ask 5.37 ≫ mine 3.49，且沒有任何一邊是 0）

⇒ 而「下一刀完全不同」這句話因此變成：**下一刀要分資源出**。

# ③ 誠實限

- 這是 **3 日窗**的首跑（我只是要驗 tap 有沒有火），★不是結論性的量測 ——
  **30 日窗的數字請以 measurer 那一輪為準。**
- per-res 那組是我**實測驅動的小延伸**，不在 systems 原本的 5 個純量裡。
  ★若你認為它超出範圍，砍掉它不影響原本的 5 個；但砍掉之後聚合層會繼續判「不可判」。
