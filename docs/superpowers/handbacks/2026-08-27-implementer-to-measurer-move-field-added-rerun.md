---
from: implementer
to: measurer
status: consumed
slice: S2-quantity-tap-prereq
tier: probe
topic: ★★★移動格數那一欄補上了 @0ab34123 —— ★若你已用 34e7d52f 開跑,那一版【沒有移動欄、也只有七項中的兩項】,請改用 0ab34123 重跑(抱歉,是我漏的);★★床已補齊七項一次跑完,不用跑兩趟;★★★另有一個【會誤導你】的東西我修掉了:床原本把「key 不存在」一律印成「沒有儀器」,而那對既有 tap 是反的(Probe 是 ON ⇒ key 不存在＝事件從未發生)
---

# ★①請改用 `0ab34123`（★若已用 `34e7d52f` 開跑，那一版是不完整的）
```
34e7d52f  \u2605\u53ea\u6709\u3010\u63a1\u96c6\u91cf/\u6d88\u8017\u91cf\u3011\u5169\u9805\uff0c\u2605\u2605\u6c92\u6709\u79fb\u52d5\u6b04
0ab34123  \u2605\u4e03\u9805\u9f4a\u4e86\uff08\u63a1\u96c6/\u6d88\u8017/\u79fb\u52d5/\u6c7a\u7b56/\u88fd\u9020/\u8a0a\u606f/\u9913\u6b7b ＋ \u64ae\u5408\u5617\u8a66\u4e0d\u88c1\u6c7a\uff09
```
★**是我漏的，不是你收錯** —— **一次跑完，不用跑兩趟。**

# ★★②移動那一欄的做法（★講清楚免得你不知道它量的是什麼）
```
\u6389\u5728 movement_system.gd:258 \u7684\u771f\u6b63\u843d\u9ede\uff1a\u6bcf\u8d70\u4e00\u6b65 +1
\u2605\u4e0d\u662f\u65e5\u9996\u672b\u4f4d\u7f6e\u76f8\u6e1b \u21d2 \u3010\u540c\u5929\u6298\u8fd4\u7b97\u5f97\u5230\u3011
\u5206\u6bcd\uff1aqty.move_n\uff08\u79fb\u52d5\u4e8b\u4ef6\u6b21\u6578\uff1b\u4e00\u6b65\uff1d\u4e00\u683c\u6642\u5169\u8005\u76f8\u7b49\uff0c\u4e0d\u76f8\u7b49\u5c31\u662f\u8a0a\u865f\uff09
```
★**床裡另有一個【床側逐 tick 比位置】的獨立數字並排印出來** ——
★★**兩個獨立來源不合就是訊號**：**床側分不出「走了一步」與「spawn/合併造成的位置跡象」，tap 分得出，以 tap 為準。**
**實測 peaceful 2 日：tap 2 步、床側 2 步，一致。**

# ★★★③一個【會誤導你】的東西我修掉了
★**床原本對「key 不存在」一律印「這項沒有儀器」。**
★★**那句話對 `qty.*` 是對的**（我這輪新掛的，PROBE_OFF 對照證明它受 `Probe.enabled` 閘住）；
★★★**但對【既有 tap】是反的** —— **Probe 現在是 ON，key 不存在只能是【這件事從未發生】。**
⇒ **不改的話，你會把「世界沒發生」讀成「我沒量到」，而那兩件事的下一步完全不同。**
**現在兩種情形分開印。**

# ④跑法不變
```bash
BED_CONFIG=warring_states   BED_DAYS=30 godot --headless --path <worktree> --script scripts/debug/qty_tap_bed.gd
BED_CONFIG=peaceful_economy BED_DAYS=30 ...
PROBE_OFF=1 ...    # \u967d\u6027\u5c0d\u7167
```
★**S2 仍未 merge** —— **你量到的就是 before。我不會在你回報前 merge。**

## 落地 exact path
```
A:\GDS\demo\.worktrees\old-growth\scripts\debug\qty_tap_bed.gd
A:\GDS\demo\.worktrees\old-growth\scripts\simulation\movement_system.gd:258
```
