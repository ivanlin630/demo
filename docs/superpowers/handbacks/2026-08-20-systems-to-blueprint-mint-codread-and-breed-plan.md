---
from: systems
to: blueprint
status: open
topic: "[②mint code-read 交件(證據非修法)+①breed funnel 已派+我的自糾已入檔·★②結論=mint【不是結構性排除,是三重劣勢疊加】,逐條:(a)allowed_outpost=['civilian'] 只准民村(軍村永不可能)(b)_facility_terrain_fit('mint')=鄰格有 ore_gold/ore_silver→3.0、否則【0.3】(非 0=不是硬排除)(c)_deficit_mint=ore>10 才 1.0、否則 0.0→無礦時 score=0.3×(1+0)×人格(1+貪婪0.4+野心0.2≈1.0-1.3)≈【0.3-0.39】,而 _pick_facility 門檻僅 0.05→【mint 確實有資格進候選】(d)★但它走 argmax 且對手是 farming——farming 有 survival-crush ×(1+SURVIVAL_CRUSH×urgency²),而本輪世界 57-62% 隊 daily_rate 為負→farming 幾乎恆勝(e)★★更硬的一層:mint cost 含 tools=5,afford 要 avail>=cost×1.5=【tools 7.5】,而 known_issues:17 已坐實【tools 全世界 production=0】(沒隊在產:沒 weaponsmith/manufacturing 設施)→就算被選中也【付不起】·∴mint 0% 是【設施鏈斷的下游症狀】:tools 產不出來→需要 tools 的東西全部建不起來→而要產 tools 又需要設施=雞生蛋(established 鏈家族)·★誠實邊界:QA 說『連 candidates 陣列都零出現』,而 _pick_facility 是【建設 option 之下游】的設施選擇,不直接出現在 specimen 的 candidates(那層是決策 option 如建設/買糧/紮根)——所以我不宣稱『candidates 零出現=_pick_facility 沒選它』,兩者是不同粒度;要坐實 mint 在 _pick_facility 層有沒有被評分/落敗,需要一個 facility-score 快照(便宜、可併下輪)·★①breed funnel:evidence-only 已派 implementer(temp 漏斗 tap 逐 gate 計數,禁 fix)·★③④照辦:兩訂正已入 progress consolidate、下輪新基線考規格四項(starve_detail 逐死亡 tap/政治拆兩欄/prefix 修/game_over guard)已記入啟動閘"
---

# ②mint code-read 交件（證據、非修法）＋ ①breed funnel 已派

## ★② 結論：mint **不是結構性排除，是三重劣勢疊加**
- **(a)** `allowed_outpost: ["civilian"]` → 只准民村（軍村永不可能）。
- **(b)** `_facility_terrain_fit("mint")` ＝ 鄰格有 `ore_gold`/`ore_silver` → **3.0**；否則 **0.3**（**非 0 ＝ 不是硬排除**）。
- **(c)** `_deficit_mint` ＝ `ore > 10` 才 1.0、否則 0.0 → **無礦時** score ＝ `0.3 × (1+0) × 人格(1+貪婪×0.4+野心×0.2 ≈ 1.0–1.3)` ≈ **0.3–0.39**，而 `_pick_facility` 門檻僅 **0.05** → **mint 確實有資格進候選**。
- **(d) ★但它走 argmax，對手是 farming**——farming 有 **survival-crush** `×(1+SURVIVAL_CRUSH×urgency²)`，而本輪世界 **57–62% 隊 `daily_rate` 為負** → **farming 幾乎恆勝**。
- **(e) ★★更硬的一層**：mint cost 含 **`tools: 5`**，afford 要 `avail ≥ cost×1.5` ＝ **tools 7.5**；而 `known_issues:17` 已坐實 **tools 全世界 `production=0`**（沒隊在產：沒 weaponsmith/manufacturing 設施）→ **就算被選中也付不起**。

∴ **mint 0% 是「設施鏈斷」的下游症狀**：tools 產不出來 → 需要 tools 的東西全部建不起來 → 而要產 tools 又需要設施 ＝ **雞生蛋**（established 鏈家族）。

## ★誠實邊界（不越級宣稱）
QA 說「連 candidates 陣列都零出現」，而 `_pick_facility` 是**「建設」option 之下游**的設施選擇，**不直接出現在 specimen 的 candidates**（那層是決策 option：建設/買糧/紮根…）→ **我不宣稱「candidates 零出現 ＝ `_pick_facility` 沒選它」**，兩者是**不同粒度**。要坐實 mint 在 `_pick_facility` 層是否被評分/落敗，需要一個 **facility-score 快照**（便宜、可併下輪）。

## ①③④
- **①breed funnel**：evidence-only 已派 implementer（temp 漏斗 tap 逐 gate 計數、**禁 fix**）。
- **③兩訂正**已入 progress consolidate（含**我自己的自糾**：`starve_minor` 那條推論錯、正確證據是 `death.defect_leave=57` 只在 `_apply_reaction` 路徑 bump）。
- **④下輪新基線考規格四項**（`death.starve_detail` 逐死亡 tap／政治拆外交・結盟兩欄／prefix 修／game_over guard）已記入啟動閘。
