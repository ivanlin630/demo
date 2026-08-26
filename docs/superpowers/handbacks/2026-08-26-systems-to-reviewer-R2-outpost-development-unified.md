---
from: systems
to: reviewer
status: open
slice: outpost-development-unified
tier: behavior
topic: R²:這條 arc 的第一張【修東西】的票(前面九顆全是儀器);★★★而我要你特別看驗收 3——faction 路徑在 peaceful_economy 上【驗不了】(那張床零 faction),我用 warring_states 補,你判那夠不夠
---

# R²：`docs/superpowers/specs/2026-08-26-outpost-development-unified-HOW.md`

**WHAT**：blueprint 裁 YES，**且明講是既有法延伸適用**（用戶 2026-07-16「獨立隊也發展生產＝YES」），
★**接法指定「進統一秤，非平行特例」。**

## ★病（一句）
`_evaluate_infrastructure`（faction 版）有 **(1) 升級 ＋ (2) 設施** 兩段；
★**獨立版只有 (2)** ⇒ **獨立隊 `pick_empty = 180`（slot 滿），而拿到第 3 格的唯一出口它根本沒有。**

---

# ★★★①要你特別看的：**驗收 3 的可達性**

**「faction 路徑不得被改壞」** —— ★**而本床（`peaceful_economy`）零 faction，這條在它上面【驗不了】。**
⇒ **我用 `warring_states` 補：`fp` 逐位元不變。**

★★**要你判**：
1. **`warring_states` 真的會走到 `_evaluate_infrastructure` 嗎？**（★**若它也沒有 faction，那我這條回歸防線是空的** ——
   **而那就是今天第四條不可達驗收**）
2. **`fp` 逐位元不變是對的判準嗎？** ★**我的推理**：**faction 路徑的行為一行不該改，所以同床同 seed 應該逐位元同。**
   ★★**但若抽共用體會改變【呼叫順序或 RNG 消耗】，那條就會假紅** —— **那正是你上一票用 `randf()<0.0` 打回我的形狀。**

---

# ★★②第二件：**我沒有預設兩條路可以完全統一**

**已知差異**：faction 版**掃所有自有 tile**、獨立版用 `_find_own_outpost`（**單格**）；guard 也不完全一樣。
★**spec 寫的是**：**差異做成【參數或前置】，不得做成共用體內的 `if faction_id == -1` 分支**（★**那是 WHAT 明令排除的平行特例**）。
★★**要你判**：**這個要求會不會逼出一個比原本更糟的形狀**（例如一個吃五個旗標的共用函式）？
★★★**若你認為某個差異【本來就該保持兩份】，說出來** —— **我寧可 spec 明寫「這一段不統一，理由是 X」，也不要為了統一而造一個誰都讀不懂的東西。**

---

# ★③第三件（小）：**我刻意不動 `FACILITY_SLOTS` 與 `DEMOLISH_MARGIN`**
★**它們是這條閉環上看得見的兩個數字**，★★**而我判它們是 tuning，這張票修的是接線。**
⇒ **先讓路存在，再談路上的門檻。** ★**你若認為不動它們會讓驗收 2（`pick_empty` 下降）不可達，說一句。**

# ★狀態
**implementer idle，等你 CLEAN。** ★**這是這條 arc 的第一張修東西的票 —— 前面九顆全是儀器。**
