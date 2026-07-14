---
from: systems
to: reviewer
status: open
topic: "[R② 審] 絕境掠奪對準糧源(hunger-weighted prey)——真根=target選擇非yield;守身分=權重;CLEAN才dispatch"
---

# R② 審：絕境掠奪對準糧源

spec：`docs/superpowers/specs/2026-07-15-loot-hunger-targeting.md`
blueprint 意圖：`2026-07-15-blueprint-to-systems-loot-hunger-intent.md`（絕境掠奪該紓飢，殘留 thrash 真根）

## patch-gate-first 挖到底（真根）
- **yield 含 food（非根）**：`npc_combat_system.gd:552 _loot_resources` food 首位按比例搶。
- **真根＝target 選擇**：`_find_weakest_prey` 主排序 `pop_est`（最弱），`food_est` 僅 tie-break → 絕境 looter 鎖最弱隊（常無糧）→ 搶料不解飢 → 殘留 thrash + 假救餓死。

## 修（de-patch）
飢餓 looter 的 prey food_est **權重隨飢餓放大**（保 beatability 硬門檻）：飢餓→選 belief food 高的可打隊；sated→現行最弱（strategic raid 不變）。**身分=權重非路徑切換**（food 權重=f(飢餓度)連續，非 survival flag 切 finder）。belief food_est 非 god-view。不加 food 硬濾（守 ②c 血訓）。

## 請你 refute
1. **真根對嗎**：target vs yield——yield 含 food 我讀對？真根是 target 選擇（weakest-not-food）？
2. **身分=權重守嗎**：food 權重隨飢餓連續調＝守「身分=權重非路徑切換」不變量？還是變相按 survival 身分切路徑？
3. **感知鐵律**：belief food_est（可失真）非 god-view 讀 target 真 food？
4. **不誤傷 strategic raid**：sated looter 仍鎖最弱（財/人力 raid 不退化）？
5. **不違 ②c 血訓**：只加權 food 不加硬濾（無糧目標仍可俘人力，非移除）？
6. **殘留 thrash 真解**：掠奪對準糧→搶到糧解飢→貿易↔掠奪↔idle 震盪源頭消？還是底下還有一層？

## 框外審評估
非新大框（既有 finder 排序改，continuation）→ 標準審。若你覺得「掠奪對準糧」有框問題可指出。
CLEAN → implementer 新分支 `feat/loot-hunger-targeting`。
（寄件 open，你讀後改 consumed。）
