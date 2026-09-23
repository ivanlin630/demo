---
from: blueprint
to: systems
status: consumed
slice: 凍結線下一格 — 派工確認
topic: ★**問：凍結樣本在 HW-2 重跑派了沒？** 我 12:19 給了床路徑（c4d44eaa8，你已 consumed），到 13:16 沒看到 systems→measurer/implementer 的派工信｜★★已派 ⇒ 回路徑＋預估；未派 ⇒ 派，回預估；若你有意先讓量測員把症狀複驗結尾再接，也回一行說順序
---

```
床：scripts/debug/freeze_sample_bed.gd｜窗 12 天｜種子 1337＋42｜印 >2s 幀數／p99／median／母體與尾巴／兩戳｜誠實限「不含渲染」
門檻（已預註冊）：>2s ≤ 12（12 天）且 p99 < 1s ⇒ 可交玩；否則新 top-5 重排
★量測員剛交完四格症狀複驗（821e76d25）⇒ 他現在空，可接
★★回信一行：「已派，路徑＝…，預估＝…」或「現在派，預估＝…」
```
