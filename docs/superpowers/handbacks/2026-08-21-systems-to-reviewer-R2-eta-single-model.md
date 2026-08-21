---
from: systems
to: reviewer
slice: eta-single-model
status: open
topic: "[R② 審設計·ETA 與真實移動成本合成單一模型·spec=docs/superpowers/specs/2026-08-21-eta-single-model-HOW.md·起因:implementer 診斷推翻所有人(含 QA)的『凍結』讀法——porter 一直在走,只是【一格要走 144 tick】,判斷週期遠短於 144·★真缺陷=同一件事兩套獨立模型:eta_ticks 只吃疲勞、_move_cost 吃隊速/地形/疲勞/超載/車輛且 clamp [BASE/3,BASE×3];porter 永遠超載(BASE_CARRY=10/人、pop=1 背 30-200)⇒ 每格吃 MAX=3×BASE ⇒ 預估系統性低估 3×·★★致命算術:T3 預算=MULT(3.0)×eta=3×BASE×格數=【真實路程時間本身】⇒ 餘裕恰好為零,而那個『恰好』是兩個獨立常數相乘的巧合、檔面上完全看不見·★我要你打三點:①爆炸半徑我查到『eta_ticks 全樹只有一個 production 消費端(_estimate_eta_to→_stamp_return_eta)』⇒ 判定 convoy-scoped;這個窮盡夠不夠?有沒有間接消費(例如有人自己算 path.cost×BASE)? ②我明令禁止『調大 MULT 來補』(用常數 paper over 模型分歧),但反方論點是:改 eta_ticks 會動到 find_path 的語意面、風險比調常數大——你判 ③gate 4 我寫『stranded 應顯著減少但不預設歸零,若歸零反而要查 T3 是不是變成永不觸發』,這個雙向判準夠不夠"
---

# R②：ETA 與真實移動成本合成單一模型

**spec**：`docs/superpowers/specs/2026-08-21-eta-single-model-HOW.md`

## 起因：implementer 的診斷**推翻了所有人**（含 QA）
「porter 相鄰卻不走最後一步」——**它一直在走，只是【一格要走 144 tick】**，判斷週期遠短於 144。

★ **真缺陷 ＝ 兩套獨立模型**：`eta_ticks` **只吃疲勞**；`_move_cost` 吃**隊速／地形／疲勞／超載／車輛**且 **clamp `[BASE/3, BASE×3]`**。
**porter 永遠超載**（`BASE_CARRY=10/人`、`pop=1` 背 30–200）⇒ **每格吃 MAX ＝ 3×BASE** ⇒ **預估系統性低估 3×**。

★★ **致命算術**：**T3 預算 ＝ `MULT(3.0) × eta` ＝ `3 × BASE × 格數` ＝ 真實路程時間本身 ⇒ 餘裕恰好為零。**
**那個「恰好」是兩個獨立常數相乘的巧合**，**檔面上完全看不見**。

## ★我要你打三點
1. **爆炸半徑**：我查到 `eta_ticks` **全樹只有一個 production 消費端**
   （`_estimate_eta_to` → `_stamp_return_eta`）⇒ 判定 **convoy-scoped**。
   ★ **這個窮盡夠不夠？有沒有【間接】消費**（例如某處自己寫 `path.cost × BASE_MOVE_TICKS`）？
   —— **今天我已經因為「以為只有一處」錯了三次**（`release()`／`post_order`／七份產生器）。
2. **我明令禁止「調大 `MULT` 來補」**（用常數 paper over 模型分歧）。
   ★ **反方論點我自己也想得到**：**改 `eta_ticks` 會動到 `find_path` 的語意面、風險比調常數大**。**你判。**
3. **gate 4 的雙向判準**：我寫「`stranded` 應**顯著減少**，**但不預設歸零**；
   **若歸零反而要查 T3 是不是變成永不觸發**」。**這個雙向夠不夠？**

## 附帶
`invariants` 已升〈**同一個物理量不得有兩套獨立模型**〉，含「**留一個持續可觀測的比值**（`eta_vs_actual`），
**讓『兩套模型是否同步』變成可量的東西，而不是修完就忘**」。
