---
from: systems
to: implementer
status: open
slice: material-gate-persona
tier: behavior
topic: ★R² CLEAN → 動工:三個 1.5x 建造閘收斂成一個共用判斷 + 人格化;★★★先講最重要的一件:【這張票不會讓任何一次建造成功,而那是預期不是失敗】——cost 50 而 avail 從未超過 20,拔掉緩衝也過不了;★驗收因此驗【形狀】不驗【解鎖】
---

# spec：`docs/superpowers/specs/2026-08-26-material-gate-persona-HOW.md`（R① CLEAN／R② CLEAN）

# ★★★動工前先讀這一段：**這張票不會讓任何一次建造成功**

```
need_1.5x = 75  ⇒ cost = 50
avail     = 0（21 筆）／20（9 筆）   ★從未超過 20
```
★**把緩衝整個拿掉（1.0×，need 50），`avail` 最高 20，仍然過不了。**
⇒ ★★**`build_ok` 依然會是 0，而那是【預期】不是【失敗】。**
**能把 `avail` 推到 ≥50 的是 A（初始庫存）與 B（伐木場），不是這張票。**
★★★**我先講，是因為交件時若沒人講，這個 0 會被讀成你做壞了。**

---

# ①做什麼
**收斂 ＋ 人格化組 A 三個閘**（R① 分的組，**只有這三個**）：
```
faction_ai_system.gd:3823  _dispatch_builder          （新建 outpost）★39/39 卡的是這道
faction_ai_system.gd:3941  _dispatch_upgrader         （升級既有 outpost）
faction_ai_system.gd:4249  _dispatch_facility_builder （擴建設施）
```
★**三份同形碼 ⇒ 收斂成一個共用判斷，再讓 `margin` 由既有人格值連續調變**（慎重厚／大膽薄）。

## ★★形狀（照既有照妖鏡家族，**不是零常數**）
`DiscountedFlow.delta_of`（`DELTA_FLOOR`／`DELTA_CAP`）、`TradeValuation._reserve_factor`（`RESERVE_HOARD_K`／`MIN/MAX`）
＝ **連續調變 ＋ 少量【具名】`TEST VALUE` 常數 ＋ clamp 上下界。**
⇒ ★**要嘛重用既有家族的常數，要嘛新開但【小而具名】並標 `TEST VALUE`。禁裸魔數、禁手抄。**
★★**上下界數字選定後回 reviewer 看那幾行**（不用整輪 R²，他已同意這樣走）。

## ★★★anti-crank 鐵律
> **中性人格必須得到【剛好 1.5】—— 零漂。**
> ★**中性值一旦不是 1.5，這票就從「人格化」變成「偷偷調數值」，而後者要走 blueprint。**

---

# ②順手要修的一行（**它在說謊**）
`faction_ai_system.gd:2236`：
```gdscript
const INVEST_SAFETY: float = 1.5   # 送料安全餘量（鏡射 _dispatch_builder cost×1.5，確保村端 _can_afford 過）
```
★**R① 查過 `_can_afford` 本體（`outpost_system.gd:812`）：它只吃 `1.0×`。這句註解宣稱了一個不存在的耦合。**

★★**而 R² 指出更嚴重的一面**：
> **人格化【之前】，`INVEST_SAFETY`(1.5) 與組 A 閘(1.5) 剛好卡準 ⇒ 那條邊界路徑（owner 不在場、遠端派建）【一直能過】。**
> **之後若 `margin > 1.5`，固定送 1.5× 會【變得不夠】** ⇒ ★★★**本票【新產生】的失效模式。**

⇒ ★**修法**：`INVEST_SAFETY` **改讀組 A `margin` 的【上界】**（clamp 上限）
⇒ **送貨量永遠 ≥ 閘的最高可能門檻。一行、零新常數。**
★★**註解一併改成陳述現況**（送料用上界、村端檢查用 1.0×），**不要複述那個錯的耦合。**

---

# ★③驗收（**兩處都是 fixture，理由已寫死**）

| # | 條 | 層 |
|---|---|---|
| 1 | ★**中性零漂**：造 `{"慎重": 0.5}` **最小 dict**（不受其他維度污染）⇒ `margin == 1.5` **逐位元** | ★**fixture**（★`person_generator` 是 `randf_range(0.35,0.65)` ⇒ **organic 世界不會出現中性人格**，拿 organic 驗＝驗空母體） |
| 2 | ★★**分化真的改變結果**：把 `avail` 擺進 `[cost, 1.5·cost)` ⇒ **慎重擋下、大膽放行**（同 `cost`、同世界，只換人格） | ★**fixture**（★那個帶 ＝ `[50,75)`，`avail` 從未進入） |
| ★ | ★★★**兩處 fixture 都必須呼叫【真正的 production 閘函式】** | **不得在測試裡自己重寫 `avail < cost * margin` 再斷言 —— ★那驗的是測試自己抄的公式，不是那道閘** |
| 3 | **三閘收斂**：`grep -rn 'cost\[k\]) \* 1\.5' scripts/simulation/` ＝ **0** | 結構型、掃全樹 |
| 4 | **零手抄／常數具名**：`estimator-lineage-scan.sh` 綠 | |
| 5 | ★**不驗解鎖** —— **`build_ok > 0` 不是本票驗收** | 見開頭 |
| 6 | **headless 閘** | `bash .claude/hooks/test-ran-floor.sh <輸出>`，baseline 7 |

★**`fp` 這次【會變】**（三閘的門檻從固定 1.5 變成人格相關 ⇒ 真實引數改變）——
★★**照 `01_architect` 那條：由「這次改動會不會改到任何一次呼叫的實際引數」決定，不由 tier 決定。**
★★★**但中性 fixture 那一格必須逐位元不變** —— **兩者不衝突：一個問世界，一個問中性點。**

# ④邊界
★**只動組 A 三閘 ＋ `INVEST_SAFETY` 那一行。** `coin_treasury.gd:46`（組 C）**不動**，spec 已點名它是之後要重查的下游。
