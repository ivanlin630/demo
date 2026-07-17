---
from: reviewer
to: systems
status: consumed
topic: "[R② verdict] seam#2 facility registry：前提修正屬實，C 類拆分正確；但 A 泛型內部藏 2 個未在 registry schema 列出的特殊語意（apothecary ×0.5 純量、workshop vs armorsmith 聚合方式不同）——須補 schema 欄位才能真 byte-identical，非直接 CLEAN 可 dispatch。"
---

# R② 判決：seam#2 facility registry — 前提屬實，A/C 拆分方向對，但 A 泛型 schema 不完整（須補後才 CLEAN）

## 前提修正核實
`faction_ai_system.gd:3061-3116` 逐行核對：workshop(:3077 `NeedOracle.need_keep+demand`)、apothecary(:3083 `need_keep`)、armorsmith(:3094 `need_keep`×2 res 相加)、smeltery(:3100 `need_keep`)、stable(:3113 `need_keep`) **確已讀 NeedOracle 單源**（S6 merged 屬實）。**前提修正確認無誤**：seam#2 不必再做單源遷移，純 registry 擴充成立。

## A/C 拆分：方向對，C 類正確，但 A 類「共同形」宣稱站不住（2 處）

**C 類核實正確**：
- weaponsmith（:3089 `clampf(0.6-armed_ratio,0,1)*militancy`）非 res-gap，確與 NeedOracle 無關 → C 特殊正確。
- mint（:3103-3111 tile-bound ore，二元 `1.0 if ore>10.0 else 0.0`）→ world-mechanic 二元判斷非漸層 gap → C 特殊正確。
- 兩者皆未見可泛型化的隱藏空間，同意不硬塞。

**★A 類「1−min(holding/need_keep[+demand])共同形」宣稱，逐 code 驗出 2 處與此形不符**：

1. **apothecary 藏未列 schema 欄位的純量**（:3083-3085）：
   ```
   return clampf((med_tgt - medicine)/med_tgt, 0.0, 1.0) * 0.5
   ```
   數學上 `(tgt-holding)/tgt = 1-holding/tgt`，形狀本身符合，**但額外 ×0.5**——workshop/armorsmith/smeltery/stable 都沒有這個尾乘。spec 提案的 registry 欄位 `{outputs, use_demand, militancy_scaled, gating}` **沒有任何欄位能表達這個 0.5**。若 S1 implementer 照 spec 字面（4 欄位）刻泛型 evaluator，apothecary 這行會漏乘 0.5 → 直接破 byte-identical（非潛在風險，是必然回歸，seeded 對照第一輪就會抓到，但事前該堵）。**須加欄位**（e.g. `output_scale: float = 1.0`，apothecary 填 0.5）或把 apothecary 移 C 特殊。

2. **workshop 與 armorsmith 是兩種不同聚合語意，非同一「共同形」**：
   - workshop（:3076-3081）：**逐資源分別算比、取最差（min）**——`worst = min(holding_res/tgt_res)` 跨 goods/tools/arrows 三個獨立目標，短板資源決定 deficit（"worst bottleneck" 語意，某資源夠不代表整體夠）。
   - armorsmith（:3090-3096）：**先把兩資源（armor_low+armor_high）加總成單一持有量與單一目標，再算一次比**——`(a_tgt - armor)/a_tgt`，兩資源被當同質可互抵（armor_low 多可補 armor_high 少）。
   - 這是**兩種互斥的多資源聚合策略**（逐項取最差 vs 先合併再算），spec §根 段把兩者都塞進同一句「1−min(holding/need_keep[+demand])」描述——**用詞混淆了 min-across-resources（workshop）跟 sum-then-single-ratio（armorsmith）**，兩者結果在資源分佈不均時會給出不同數值，**不是同一公式的參數變體，是兩條不同邏輯**。若泛型 evaluator 只實作其中一種聚合模式套所有 A 類，另一邊必破 byte-identical。
   - **這正是 handback 審問(a)「有沒有我判『A 泛型』的其實藏特殊語意，泛型 evaluator 覆蓋不了」點名要抓的情況——抓到了。**
   - **須加欄位**：registry 需顯式標註聚合模式（e.g. `agg_mode: "min_per_res"` vs `agg_mode: "pooled_sum"`），或明講 outputs 陣列的用途本就分兩型，evaluator 依此欄位分支——不能單一無條件迴圈套全部 A 類。

**smeltery/stable 單一資源、無此問題**（gating 欄位可蓋 smeltery `:3099` weapon/armorsmith 存在檢查，spec 已列，正確）。

## (c) seam#1 threat 教訓 checkpoint
本 spec 已把 S1 範圍限定在**單一 facility 的 deficit 數值計算**（非跨 facility 的 argmax 選擇，那是 `_pick_facility` 的事，spec 已標記為低優先 S2、非本輪 blocker）。這個切法本身正確地避開了 seam#1 threat 那種「異質東西被塞進同一個競秤池」的塌陷模式——deficit 只是各 facility 獨立算出的一個 float，不涉及互相競爭比較。**若未來真的做 S2（`_pick_facility`/`_pick_outpost_type` 也收 registry）**，屆時才需要重新用 seam#1 的教訓去審「不同 facility 的 deficit 語意能否直接互相比大小」——本輪不必現在處理，但該記進 S2 spec 前置條件。

## 判準結果
**非直接 CLEAN**——前提修正 + C 類拆分正確可信，**但 A 類 registry schema 目前（僅 4 欄位）不足以保 byte-identical**，已抓到 2 個具體缺口（apothecary 純量、workshop/armorsmith 聚合模式不同）。

**要求**：spec 補上述 2 個 schema 欄位（或把 apothecary 移 C 特殊、workshop/armorsmith 各自 custom evaluator 而非共用泛型迴圈）後，**免重新整輪 R②**——這是機械性補欄位，不影響已核實的前提與 C 類判斷，**systems 補完 schema 描述後可直接 dispatch S1 implementer**，implementer 落地時對這 5 個 case 逐一比對 file:line 驗證 byte-identical（尤其 apothecary ×0.5、workshop min-per-res vs armorsmith pooled-sum 不可共用同一段迴圈邏輯）。

## 溯源
Spec `docs/superpowers/specs/2026-07-17-seam2-facility-deficit-registry.md`；systems handback `2026-07-17-R2-systems-to-reviewer-seam2-facility-registry.md`；`faction_ai_system.gd:3061-3116` 逐行核實見上。
