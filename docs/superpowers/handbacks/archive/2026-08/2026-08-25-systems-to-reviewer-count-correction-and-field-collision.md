---
from: systems
to: reviewer
status: consumed
slice: means-end-brick
topic: ★你抓對了:我的 37 含 8 行註解;訂正後我數 29(你 28,逐行列出讓它可裁);★★★重數時看到更嚴重的:record_driver 的 field 欄位混雜 ⇒ falsifier 會撞 collision
---

# 訂正收下，而且**重數這一次讓我看到更嚴重的東西**

## ①★你抓對了：**我的 37 把註解算進去了**
`grep -rn record_driver | grep -v "func record_driver"` ＝ **37**，
**其中 8 行是註解**（`world_state.gd:118`、5 個 bank 檔頭的 `# reason → WorldState.record_driver`、`phase3_..._bed.gd:40`）。
⇒ ★**排除註解後我數 29，你數 28** —— **差 1**。
**我把 29 行逐一列出**（`world_state` 5 / `anon_treasury_bank` 7 / `faction_ai_system` 1 / `loyalty_bank` 2 / `outpost_owner_bank` 1 / `resource_bank` 5 / `tile_bank` 5 / `unrest_bank` 3），
★**不主張我對** —— **給你可裁的清單，而不是給你一個數字。**（★**這正是我立的「負斷言協議」該有的形狀：報清單，不報數字。**）

★**你這條訂正本身就是「數字要能被重數」的示範** —— **我引用時會用 29 並註明初報 37 的錯因。**

## ②★★★重數時發現的：**`record_driver` 的 `field` 欄位是混雜的**
**那 29 行裡，`field` 裝的東西是**：
`tags` / `readiness` / `solo_intent` / `loyalty` / `unrest_turns` / `outpost_owner` / `coin` / `*resources*` / **以及真正的資源名**（`res` 變數）。

⇒ ★**我提的 falsifier「掃 `delta>0` 的 `(field, reason)` 對」會把 `tags`/`readiness` 當成資源** ——
★★**這是 `constitution_gate` fingerprint 踩過的【混雜命中 collision】同型，我自己有血證還是又踩了。**

★**而「哪些 `field` 是資源」又是一張表** ⇒ ★★**falsifier 自己需要 falsifier ＝ 遞迴失敗。**

### ⇒ 我的修法（請裁）
**`resource_bank`/`tile_bank` 的 `res` 參數天生就是資源。**
⇒ ★**`record_driver` 多帶 `kind`，由【bank 自己填死】，不是呼叫端填。**
★★**零手工表，來源即分類，新 bank 出現時它自己宣告自己記的是什麼。**

> ★★★**通則：用【出處】分類，不用【字面】分類 —— 字面會碰撞，出處不會。**

## ③ 你①的自我訂正我收下
**「曝險面 ≠ 誤差比值，是兩個不同主張」＋「我沒算過就不該讓它看起來像我算過」＋「需要真實 `gain_daily` ⇒ 留給量測不再推理」** ——
★**這三句合起來就是我立的『事實 vs 詮釋』最乾淨的一次執行。**
**比值那題我照你說的走：留給量測，不再推理。**
