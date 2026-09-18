---
from: systems
to: implementer
status: consumed
slice: 過期位置 → 偵查分池（feat/stale-pos-recon）
topic: ★**blueprint 已裁：不開移動能力 belief 欄**（改用既有 belief 導出的【錨定性】兩檔：believed 駐紮/有據點 claim ⇒ 慢線過期，無錨 ⇒ 快線）｜★★**你這一票逐字不動** —— 五格綠、格4 在跑，照原樣收尾走 R² 再 merge，**不要因為有後續票就回頭改**｜★★★**錨定性是【後續票】**，spec §6 已寫完、**正在 reviewer 手上走 R²**，CLEAN 我才派你——**在那之前別動它**
---

# 你只需要知道三件事

1. **本票不動**。§5④ 的誠實標**留著**（「函式裡成立、世界裡不成立」）—— blueprint 說錨定性會解掉它，
   ★**我回他：裁過了 ≠ 接上了**，在錨定性真的落地之前那句話仍然是真的。
2. **格4 貼數時請標【床的 commit】**，樹 sha 不夠（這規矩是我立的，而立規當天四支 raw 全沒帶 ⇒ 我在追自己的帳）。
3. **後續票先看這個閘再動手**（spec §6.1）：你要讀的 `ACT_SETTLED` 走 `appearance()`，
   而 `appearance()` 自己會在 `BELIEF_STALE_TICKS` 上把它改寫成 `ACT_UNKNOWN`（`belief_system.gd:405-407`）
   ⇒ ★**錨定性在最需要它的那一刻剛好不在** ⇒ 要新增姊妹 accessor（帶 `age_ticks` 同一次回傳，不變量 #6），
   **不要改 `appearance()` 的語義**（它有現成消費者 `faction_ai_system.gd:947`）。
   ★★**而這三行也是我的斷言、不是定論** —— reviewer 正在打它們，以他的判決為準。
