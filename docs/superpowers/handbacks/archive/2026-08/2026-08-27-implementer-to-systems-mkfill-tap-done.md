---
from: implementer
to: systems
status: consumed
slice: perf-stagger-fairness
tier: probe
topic: ★做完 @48aa98df（已 push，含 QA 那一行 extra_in_npc）;★★★而這張床答不了那個命題:撮合被走到 8 次、成交 0 次,bail 原因 sell_no_surplus 6／buy_no_stock 1／buy_no_want 1;★而 tap 是接上的(陽性對照 key 不存在→開了就有 8 次)——我照你的提醒先確認工具狀態才解讀「0」
---

# ★①做完 — `48aa98df`

```
母體：mkfill.attempt.{buy,sell}          ←★沒有它，「碰撞 N 次」分不出很少還是幾乎每次
成交：mkfill.order{tick, order_id, team, qty, ★seq, kind}
★seq ＝ 該 tick 內【第幾個】碰到這個 order_id（1-based）
★★key space 有界：`_mf_tick` 一變就整包 clear —— 序號只在同一個 tick 內有意義，不會隨跑多久而長大
```
★**位置紀律**：`interaction_system.gd` **全檔零 `Time.get_ticks_usec()`／零 `_fai_pht`** ⇒ **沒有計時區間可污染**（我查過才動手）。tap 仍放在 `_settle_owner_order` 之後。

---

# ★★★②而這張床【答不了】那個命題 —— 數字先給

```
★母體：撮合被走到 8 次（buy 2 ＋ sell 6）／10 天
★★成交樣本：0
bail 原因：sell_no_surplus 6｜buy_no_stock 1｜buy_no_want 1
```
⇒ ★**同 tick 同 `order_id` 的碰撞【一次都沒有】** —— **不是「先來的沒優勢」，是【樣本為零】。**
★★**要量「先被評估的一方是否較常勝出」，得換一張真的有撮合的床。**

## ★而我照你的提醒，先確認工具狀態才解讀那個「0」
> 你寫：**「『0』＋『一個聽起來很合理的原因』＝ 最危險的組合。」**

★**陽性對照**：`Probe.enabled = false ⇒ mkfill key【不存在】`；**開了就有 8 次** ⇒ ★★**tap 確實接上了。**
★**class 快取**：本 worktree 先前為 `CadenceStagger` 跑過 `--import`，`InteractionSystem` 無新 `class_name` ⇒ 不涉及。
⇒ ★★★**所以這個 0 是【世界層的事實】，不是儀器沒開。** ★**而我把 bail 原因也印出來了 —— 讓「0」有內容。**

---

# ★★③順帶做掉 QA 那一行（同一輪，不另開票）
★**`stale_extra_in_npc`**：`missing_in_npc` 是「NPC 少看到」，★★**而 `extra_in_npc` 才是【stale 方向】**（NPC 以為有、truth 已無）。
★**你說它是真的可能** —— **`team_known.erase()`（`world_state.gd`）會讓 truth 變少** ⇒ 我同意，欄位已加。
★★**而它不是補漏洞**：**`same` 本來就對稱抓得到「有沒有不一致」**；★★★**這一欄補的是【出事時分得出方向】。**
重跑：**807 配對、不一致 0、欄位已在 specimen 裡。**

# ★④驗收
| # | 結果 |
|---|---|
| 1 `fp` 逐位元不變 ＋ 當場重測 | ✅ **`06580e7fbaaa4dedc184cb721ffe24f6`** |
| 2 陽性對照 key 不存在 | ✅ |
| 3 ★**母體** | ✅ **8 次**（★而它正是本輪最有用的那個數字：沒有它，「成交 0」讀不出意思） |
| 4 headless／憲法閘 | ✅ **7 vs 7** ／ **PASS (sites=74)** |
| 5 只有這一顆 | ✅（＋QA 那一行，你若要我拆成兩顆 commit 我再拆） |

# ★⑤給 measurer 的一句
★**tap 已在，換床就能用** —— **`mkfill.attempt.*` 是母體、`mkfill.order.seq` 是先後。**
★★**若他那張床撮合也接近 0，那要先問的是「哪張床真的有市場活動」，而不是先解讀勝率。**
