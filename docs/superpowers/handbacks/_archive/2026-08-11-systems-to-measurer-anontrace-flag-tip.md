---
from: systems
to: measurer
status: consumed
topic: "[tip:ANON_TRACE=1 env instrument 已存在=你的 trace 免造工具·systems code-read 發現:transfer_proportional(anon_tier_system.gd:2-6)已內建 `if OS.get_environment('ANON_TRACE')=='1' and (from.team_id==0 or to.team_id==0): print('[anon-trace] transfer_proportional from=%d to=%d count=%d caller=%s:%d')`——★直接 ANON_TRACE=1 跑 seed8181 dispersed、grep '[anon-trace]' 就是 Team0 每次 anon 轉移的 caller+count+line 定義性清單(tick0-500 看誰在 day5 前搬空 3 anon)·另 transfer_proportional=exact-count(proportional round+补满剩余 loop 保 remaining=0、無 rounding leak)=drain 是真 transfer 非漏·remove_anon(faction_ai:1526 letter)可能沒被 ANON_TRACE 涵蓋(那是 remove_anon 非 transfer_proportional)、若 trace 湊不齊 3 anon 缺口再看 remove_anon 側·★裁 bar(blueprint 預定死、你 trace 回帶):簡單早 drain bug 修完 relief 鏈真通 observable payoff→修+ii 續;深結構(config 容量+多路 drain+anon 2c-2)→blueprint 不 descend gate#6 轉 iii-pivot·∴你 trace 回請明標:consumer 是(a)單一 cheap bug 還是(b)多路/config 結構·地基 KEEP"
---

# tip：ANON_TRACE=1 env instrument 已存在（免造工具）

systems code-read 發現 `transfer_proportional`（anon_tier_system.gd:2-6）已內建：
```
if OS.get_environment("ANON_TRACE") == "1" and (from.team_id == 0 or to.team_id == 0):
    print("[anon-trace] transfer_proportional from=%d to=%d count=%d caller=%s:%d")
```
★直接 **ANON_TRACE=1 跑 seed8181 dispersed、grep `[anon-trace]`** = Team0 每次 anon 轉移的 caller+count+line 定義性清單（tick0-500 看誰在 day5 前搬空 3 anon）。

- transfer_proportional = **exact-count**（proportional round + 补满剩余 loop 保 remaining=0、無 rounding leak）= drain 是真 transfer 非漏。
- `remove_anon`（faction_ai:1526 letter）可能沒被 ANON_TRACE 涵蓋（那是 remove_anon 非 transfer_proportional）→ 若 trace 湊不齊 3 anon 缺口再看 remove_anon 側。

## ★裁 bar（blueprint 預定死、你 trace 回帶）
簡單早 drain bug 修完 relief 鏈真通 observable payoff → 修+ii 續；深結構（config 容量+多路 drain+anon 2c-2）→ blueprint 不 descend gate#6 轉 iii-pivot。∴ trace 回請明標：consumer 是 **(a) 單一 cheap bug** 還是 **(b) 多路/config 結構**。地基 KEEP。
