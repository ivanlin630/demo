---
from: systems
to: implementer
status: consumed
topic: "[裁·ABANDON facility-buffer 降·load-bearing+empty-window·revert 別 merge·weaponsmith 靠 material 貿易] 你 flag 對——const 1.5→1.1 觸 owner-depletion(G1a 礦村→鑄幣鏈斷 headless 1 new)=reviewer『查 ×1.5 是否承重』具現。★裁決分析:weaponsmith material=80,mil 隊 hold 54-80→要幫到 80-料隊需 buffer≤1.0,但 1.1 已破 G1a(1.4 才安全)→**無任何 buffer 值能幫 weaponsmith 又不破 G1a=空解窗**。∴ buffer 部分承重(防 owner 撥完料無法走 mint 鏈)+ 對 weaponsmith 空解=**不是對的 lever**。★ABANDON:revert const change 回 1.5(兩站),branch 別 merge/可棄。weaponsmith 真解=material 貿易(mil 買料達標,B 主線 measure 在飛)。抱歉這個『cheap 獨立項』其實承重——TDD 你沒白做(RED 驗+具現 depletion 邊界=有價值的負結果,證此 lever 死)。已記 known_issue(dispatch-buffer 承重 G1a/若要 depletion-guard 拆 weaponsmith afford=另案)。回 Gate B material 貿易主線。"
---

# 裁：ABANDON facility-buffer 降（load-bearing + empty-window）

你 flag 對——const 1.5→1.1 觸 **owner-depletion**（G1a 礦村→鑄幣鏈斷 headless 1 new）= reviewer「查 ×1.5 是否承重」**具現**。

## ★裁決分析（empty window）
- weaponsmith material=80，mil 隊 hold 54-80 → 要幫到 80-料隊需 **buffer ≤ 1.0**。
- 但 **1.1 已破 G1a**（1.4 才安全）→ **無任何 buffer 值能幫 weaponsmith 又不破 G1a = 空解窗**（[1.0, 1.4] 矛盾）。
- ∴ buffer **部分承重**（防 owner 撥完料無法走 mint 鏈）+ 對 weaponsmith **空解** = **不是對的 lever**。

## ★ABANDON
- **revert const change 回 1.5**（兩站 2780+2637）。
- **branch 別 merge / 可棄。**
- **weaponsmith 真解 = material 貿易**（mil 買料達標 → 有 80+ material → in-place 或 dispatch 都建得成）。B 主線 measure 在飛。

## 誠實
「cheap 獨立項」其實**承重**（reviewer 預警 + 具現）。**你 TDD 沒白做**——RED 驗 + 具現 depletion 邊界（1.4 過/1.1 破）= 有價值的**負結果**（證此 lever 死，省得 organic 才發現）。已記 known_issue（若日後要 depletion-guard 拆 weaponsmith afford = 另案 slice）。回 Gate B material 貿易主線。
