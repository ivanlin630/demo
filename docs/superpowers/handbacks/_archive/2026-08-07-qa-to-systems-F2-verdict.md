---
from: qa
to: systems
status: consumed
topic: "★F2 treasury域模組切收sufficiency判=足夠merge(結構track第一刀示範成功)——這輪用最強驗證手段:直接side-by-side diff舊faction_ai_system.gd被removed的5函式body vs 新coin_treasury.gd的body,逐行核對coin_need(material/food雙need計算式)/_extract_treasury(stress/loyalty懲罰+emergency分支)/_extract_buffer(prudence-lerp)/_consider_extraction/_collect_member_tax(greed/prudence稅率clamp)——全部逐字相同,只instance→static+8 const隨body搬,零一行logic差異,比R2/R3/F1任何一輪的口頭/organic驗證都更直接更強。全caller exhaustive核對diff:production(player_command:248/resource_system:177/faction_ai loop:835,836)+debug/test(extraction_need_driven_test全篇/material_hold_test×2/unified_commerce_test×2/headless_test:8521)全數改呼CoinTreasury.xxx,一處未漏。額外交叉驗證:reviewer R²報告獨立抓到並要求補上headless_test:8521這個關鍵entrypoint caller(CLAUDE.md交付標準指定的headless本體,若漏會讓fp驗證連起跑點都到不了)——我自己diff核對此caller確實已補上,兩條獨立查核路徑(我的diff+reviewer的R²)收斂到同一結論,互相印證非各自表述。裁定:純code-move坐實(非信claim,親diff核對)+caller exhaustive坐實(親diff核對)+reviewer R²獨立交叉驗證一致+零反向耦合(reviewer已核non-treasury helper呼叫)——四線證據比前幾輪都紮實,足夠F2收官merge,推進F3+剩模組逐切。unified_commerce_test 5 FAIL pre-existing claim未逐一重跑驗證(無執行環境),但reviewer/systems雙方皆未提出矛盾證據、且明確歸因市場order非treasury範圍,信任度合理"
---

# ★F2 treasury 域模組切收 sufficiency 判 — 足夠 merge

裁：**純 code-move 坐實、caller exhaustive 坐實、足夠 F2 收官 merge**，這輪驗證強度是目前最紮實的一次。

## 直接 side-by-side diff 核對（比讀 code「看起來對」更強）

用 `git diff feat/framework-F1 feat/framework-F2 -- scripts/simulation/faction_ai_system.gd` 直接拿到**被刪除的舊 5 函式完整 body**，逐行對照 `coin_treasury.gd` 的新 body：

- `coin_need`：material-buy afford×1.5 缺口計算式、food-buy DESPERATION 判斷式——**逐字相同**。
- `_extract_treasury`：stress/loyalty 懲罰係數、`is_emergency` 分支、print 訊息——**逐字相同**。
- `_extract_buffer`：`lerpf(EXTRACT_BUFFER_MIN, EXTRACT_BUFFER_MAX, prudence)`——**逐字相同**。
- `_consider_extraction`/`_collect_member_tax`：need-guard/greed-prudence 稅率 clamp——**逐字相同**。

只有 `instance→static` + 8 個 const 隨 body 搬走，**零一行 logic 差異**。這不是「讀起來合理所以信」，是把新舊兩段文字並排比對出來的。

## Caller exhaustive 親 diff 核對

同一份 diff 裡確認全部 caller 改呼 `CoinTreasury.xxx`：production（`player_command_system.gd:248`/`resource_system.gd:177`/`faction_ai_system.gd` loop `835,836`）+ debug/test（`extraction_need_driven_test.gd` 整篇/`material_hold_test.gd`×2/`unified_commerce_test.gd`×2/`headless_test.gd:8521`）——**一處未漏**。

## ★交叉驗證：我的 diff 核對跟 reviewer R² 獨立收斂到同一結論

讀 `2026-08-07-reviewer-to-systems-R2-F2-treasury-CLEAN-correction.md`：reviewer 獨立抓到並要求補上 `headless_test.gd:8521`——**這條是 CLAUDE.md 交付標準指定的 headless entrypoint 本體**，若漏補，build 完直接炸、fp 驗證連起跑點都到不了。我自己的 diff 核對確認**這條真的已經補上**（`CoinTreasury.extract_treasury(state, team, 0.3, "貪婪驅動")`）。兩條獨立查核路徑（我的 diff + reviewer 的 R²）收斂到同一發現同一結論，互相印證，不是各自表述。

## 未能逐一重跑驗證的部分

`unified_commerce_test` 5 FAIL pre-existing 這條——我沒有執行環境重跑 main 分支核對是否同 5 個失敗，但 reviewer/systems 雙方皆未在各自報告裡提出矛盾證據，且明確歸因「市場 order 機制、非 treasury 域」（跟這次搬移的 5 個函式完全不重疊），信任度合理，不影響本輪 F2 的核心判斷（純 code-move 是否乾淨）。

## 裁定

純 code-move 坐實（親 diff、非信 claim）+ caller exhaustive 坐實（親 diff）+ reviewer R² 獨立交叉驗證一致 + 零反向耦合（reviewer 已核 5 函式呼叫對象全是已模組化外部）——四線證據比 R2/R3/F1 任何一輪都紮實（那幾輪很多是 organic/unit-test 層級間接證據，這輪是直接文本比對）。**足夠 F2 收官 merge**，推進 F3+ 剩模組逐切，可作為②結構 track 第一刀的合格示範。

---
*QA 驗收官 · 2026-08-07*
