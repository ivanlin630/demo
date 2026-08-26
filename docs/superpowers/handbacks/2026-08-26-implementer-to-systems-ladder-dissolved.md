---
from: implementer
to: systems
status: open
slice: infra-ladder-dissolve
tier: behavior
topic: ★做完:升級收進 _pick_facility 當第三個 ok_*,段(1) 獨立迴圈刪除,四 fixture 全綠(含負向 D);★★organic 層照你預告【逐格與改動前相同】(77/180/1、ok_upgrade=0);★★★而 fp 也【沒變】——不只是「哪張床」的問題,是【機制根本沒 fire ⇒ 世界一模一樣】;★另附:床加了自我解釋,否則 upg.call 258→0 會被讀成路又斷了;@c378546d
---

# ★①做完了

```
_pick_facility 三個 ok_*（★共用 best 的 _facility_score，不造新秤）
  ok_slot_free  有空位      代價：無
  ok_demolish   拆 lowest   代價：失去 lowest（且要多過 ×1.5 一關）
★ok_upgrade     擴建一格    代價：升級全費（afford 是 applicability gate，不是分數）
段(1) 那條獨立升級迴圈：★已刪除
```
★**迭代順序 pin 仍有效、未解除**：`for tile_id in state.world.tiles` 一行沒動、first-success `return` 沒動。
★★**pin 保護「哪一格先被掃到」；本票改「同一格上兩個選項誰先被考慮」——不同維度**（照你訂正後的說法）。

## ⚠️★★★你揭的那個行為擴大，我用【呼叫端決定】擋掉
`allow_upgrade` **是參數，不是函式自己判**：
```
若在 _pick_facility 內只判 outpost_owner == team.team_id
  ⇒ lord_scan 傳的是 owner_team ⇒ ★憑空多出「屬下升級自己的據點」
lord_scan 實際傳：owner_team.team_id == leader_team.team_id   ←★只有 leader 自有
```
★**D fixture 釘的就是這一條，而它綠了。**

# ★★②四 fixture（★全部呼叫真正的 `_pick_facility`）
```
pick_facility 同一把秤 OK（A 直建／B upgrade 贏／C 退回舊行為／D 範圍未擴大）
```
★**slot 填充不手抄欄位名** —— 從 `FACILITY_DEF[f].current_level_key` 讀（**我第一版手抄 `workshop_level`，那個欄位根本不存在，當場崩**）
⇒ ★★**日後設施改名／新增，fixture 不會 stale 成假綠。**

---

# ★★★③organic 層：**逐格與改動前相同**，照你預告的
```
ok_slot_free 77（29.8%）｜empty_slot_full_margin 180（69.8%）｜ok_demolish 1（0.4%）
★ok_upgrade 0（0.0%）
★七類對帳 258 == entry 258 ✅；八類 0 == upg.call 0 ✅
```
★**與上一輪【一個數字都沒差】** —— **錢從來不夠，而買不起的選項在任何秤上都不會贏。**

## ★★而 `fp` 也【沒變】——理由比「哪張床」更前面一層
```
spec：「fp 會變 ⇒ 守恆帳」
實測：fc9abb6ed8156f4dc45abdd3ca8fd12f   ←★與上一票逐位元相同
```
★**因為 `ok_upgrade` 從未 fire ⇒ 世界【一模一樣】。**
⇒ ★★**這跟上一票的教訓同族，但又前面一層**：
**上一票學到「`fp` 預期要連【床】一起寫」；★★★這一票是「還要連【機制有沒有 fire】一起寫」。**
★**一個從未 fire 的機制，不管改得多大，`fp` 都不會動。**

---

# ★④床加了【自我解釋】，因為它會誤導下一個人
`upg.eval_entry / own_tile_seen / upg.call` **現在全部 0** —— ★**那不是「升級路徑又斷了」，是分母搬進了 `_pick_facility`。**
⇒ 我在該段印出：
```
★★★注意：本段【全 0 是預期的】——階梯溶解之後，升級不再有獨立的評估迴圈，
   它變成 `_pick_facility` 的第三個出口 `ok_upgrade`（見下面那張表）。
   ★沒有這一行，下一個人會把「upg.call 258 → 0」讀成【升級路徑又斷了】。
```
★★**這正是我們一路在防的那個形狀（0 分不出「沒發生」與「沒接上」），只是這次它出現在【我自己剛剛搬走的分母】上。**

# ★⑤閘
| | |
|---|---|
| headless | ✅ **7 vs 7 PASS** ＋ 四 fixture 綠 |
| 憲法閘 | ✅ **PASS (sites=74)** |
| ★命中的那一行 | `_can_upg` 裡的 `tile.outpost_level < 3` ⇒ 標 `gate-ok: world-mechanic: outpost level cap (>=3)` —— ★**與 `evaluate_upgrade` 內那條是【同一個世界機制】，不是新門檻**（我逐行掃出來確認的，沒有照單全收「新增 1 個閘」） |
| 對帳 | ✅ 七類 258 == entry；八類 0 == `upg.call` |

# ★⑥誠實限（照你 spec 原樣留著）
★**不對升級打折 ⇒ 偏強**（打折就要發明 `UPGRADE_MARGIN`）；
★**升級帶來的倉容 +250／駐軍上限未計入 ⇒ 偏弱**（計入要各自發明價值換算）。
★★**兩個方向相反的誤差我沒有假裝抵銷，也沒有任何一邊被我悄悄補上。**
