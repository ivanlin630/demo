---
from: systems
to: implementer
status: open
slice: belief-freshness-per-field（第③票）
topic: ★R² CLEAN,③可動工——定案【只做 tile_pos,不一次做完】(理由是讀code:其餘欄位鎖步刷新⇒沒借新鮮度;真同病的 resource_scale/combat_target_est 目前【無讀取端消費】);★三項機械緩解是硬要求:①欄位名焊進時戳名 tile_pos_tick(禁 observed_tick)②四個既有讀取點各補一行「這個 last_tick 不管 tile_pos」③§6 具名;★★驗收#2 要印「多少次 belief 因此變過期」——那會讓數字變差,我要它被看見不要被解釋掉
---

# ③新鮮度洗白：**GO**

spec 已按 R² 補完：`docs/superpowers/specs/2026-09-05-belief-freshness-per-field-HOW.md`

## ★你問的「兩種形狀，我不挑」——**答案是它不是兩個選項**
B 照字面做會**清空**未觀察欄位（只看到位置的目擊會把資源估計抹掉）；B 的合理版本＝逐欄位保留舊值＋各自時戳＝**就是 A**。⇒ **A 或 A 的偽裝。**

## ★★範圍：**只做 `tile_pos`**（R² 讀 code 判的，不是省事）
```
vision_system.gd:142-157 六欄【鎖步寫入】(population_est/tile_pos/last_tick/tags_seen/activity/in_combat)
   而 belief_system.gd:388-399 appearance() 讀的正是這組 ⇒ ★它們共用 last_tick【語意正確】,不是借新鮮度
★★真正同病的是條件寫入的 resource_scale(:177)／combat_target_est(:163)
   ⇒ ★★★但全部四個新鮮度讀取點(:135/:140/:393 + faction_ai_system.gd:356)【都不看它們】
⇒ 先做 tile_pos 不會漏掉一個【現在有人在讀】的洞;一次做完 = 先蓋機制還沒人用
```

## ★★★三項機械緩解（硬要求，不是建議）
1. **命名＝`tile_pos_tick`** —— **欄位名焊進時戳名**。★**禁** `observed_tick` 這種泛用字（泛用名會被下一個人誤認成「也能拿來判別的欄位」）。
2. **四處各補一行註記**：`belief_system.gd:135`／`:140`／`:393`／`faction_ai_system.gd:356` —— 明寫「此處 `last_tick` 管**鎖步欄位**，**不管 `tile_pos`**；`tile_pos` 查 `tile_pos_tick`」。★★**下一個人一定會走到這四個點**，所以提醒要放在那裡，不是放在 spec 裡。
3. `resource_scale`／`combat_target_est` 寫進 §6 具名 + **註明未修理由是「無讀取端消費」不是遺漏**。

## ★驗收裡我特別放的一格
**#2 要印【多少次 belief 因此變成「過期」】** —— 有些隊會因此**放棄 JOIN／徵收**。★★**那是預期內的，但它會讓某些數字變差** ⇒ **我要那個數字被印出來被看見，不要被解釋掉。**

## 序（第一批，已含用戶新加的第⑤票）
```
④ try_set 擋因具名  ✅ done
③ 新鮮度(tile_pos)   ←★你現在這張
⑤ 團內稅分軌(用戶新定 WHAT)  ←★spec 我這輪寫,R² 後給你
② 徵收 broad-thin
① 墓碑(★前置量測可與上面並行)
```
★**批次紀律不變：全批落地後【同 seed 重跑一輪】對比 90 日基準＝成效驗收，不逐票重跑。**
