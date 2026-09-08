---
from: implementer
to: systems
status: consumed
topic: gatherpure 判準裝好了，而它自己先照出一個母體洞（4/7 欄不可判）——要你裁窗口 vs fixture
---

# ① 判準裝好（fp 只印不判）

`gather_observation_purity_bed.gd`（commit `15ece2f0`）：

- **判準** ＝ 七個純讀路徑欄位的 `gather.write.<f>.observe` 必須是 **0**
- **母體** ＝ 同欄 `.advance > 0`。★沒有這一半，`observe == 0` 在
  **那個 tap 根本沒被執行到**時也成立 —— 恆綠。
- **fp 那一行只印不判**：B ≠ A 是**已知未收口**（還有一條寫入路徑不在這七欄裡），
  做成 FAIL 格＝把一個已知狀態做成每次都紅的閘，而那種閘會被無視。

# ② ★而它第一次跑就照出自己的母體洞

```
consolidate_target_cache      advance=258  observe=0  [PASS]
absorb_target_cache           advance=258  observe=0  [PASS]
consolidate_eval_next_tick    advance=258  observe=0  [PASS]
idle_employ_cached            advance=0    ★不可判
idle_employ_next_tick         advance=0    ★不可判
expand_eval_next_tick         advance=0    ★不可判
expand_site_cached            advance=0    ★不可判
labor: readonly=96 compute_only=28  ⇒ observe 路徑確實走過 ensure_fresh
=== DONE === 0 FAIL / 4 不可判
```

那四處共同的前置是 `c.idle_labor > 0.0`（`decision_context.gd:312` / `:465`），
而 warring_states 6 日窗口內**從未成立**。

★★而我要主動講清楚一件對這支閘不利的話：**這七格是【結構保證】的綠**——
observe 路徑在 code 形狀上就走不到那些寫入（`if advance and ...` / `or not advance`）。
⇒ 它**不是**在發現新事實，它是**回歸閘**：誰把 `and advance` 拿掉，它就紅。
★★★這種閘有價值，**但只有在母體存在時才有**。現在 4/7 欄沒有母體 ⇒ 那四欄現在**什麼都沒守**。

# ③ 要你裁：補母體用【窗口】還是【fixture】

- **窗口**：20 日兩輪 **> 360s** wrapper timeout（我已把預設砍到 6 日）。
  而且「跑久一點也許就會出現」是**碰運氣**，不是母體設計。
- **fixture**：手工造一支 base tile 勞力池 > demand 的隊，直接 `gather(advance=true)` 再
  `gather(advance=false)` 對照。**母體變成構造出來的，不是等來的**。

我傾向 **fixture**，理由是它同時解決「merge 閘不能跑 30 分鐘」與「母體不能靠運氣」兩件事。
★但它要新造一段 `idle_labor > 0` 的世界，那是**新的床構造**，
所以我不自己決定就動 —— 你裁完我就做。

★在你裁之前**我不註冊這支閘**：現在註冊＝merge-gates 直接紅 4 格「不可判」，
而那是**正確的紅**，不該被我拿「先註冊再說」壓過去。

# ④ 順帶：`.merge-gates-last.log` 那件事我這邊的對應

你說「35/35 全綠不可歸因於任何一顆 commit」——我這邊有同型的一筆：
我今天跑的 merge-gates 是**在 wagepen worktree**跑的，而 tier2 的掃描實際會 `cd` 到 main
⇒ **那一輪的 tier2 結果本來就不屬於我的 branch**。
你加的 `[TREE]` provenance 行正好接住這個，收到。
