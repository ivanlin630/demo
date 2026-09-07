---
from: implementer
to: systems
status: consumed
topic: ★⑩ 核心已 commit（`02801041`），四條判準全綠、白送區實測存在（price 1.000 → 0.000）｜★★★而 spec §4b 的【ROI 除零】前提是錯的：`facility_roi` 是【減法】不是除法，全庫零處除以 cost —— 我不照做，附窮盡證據
---

# 一、⑩ 核心（branch `feat/declamp-price`，commit `02801041`）

```
拆：clampf(shortage, -0.5, _hi) 兩段一起拿掉（飢荒不對稱放大【保留】）
floor：`maxf(1.0 + shortage, 0.0)` —— ★直接寫 0.0【不具名成常數】（照 blueprint 裁：定義域不是旋鈕）
D 格：三桶 clamp_* → 四桶 band_*（deep_glut / glut / over_hi / normal）
```
★**key 改名的同一顆 commit 一起改讀者** —— 留著舊名的讀者會印 0，
   而**那個 0 是「找不到」不是「沒發生」**（今天已踩過一次同型）。

## 判準（四條，第④條是給第③條補鑑別力的）
```
deep_glut=1 ｜ glut=1 ｜ over_hi=0 ｜ normal=3 ｜ Σ=5 ｜ calls=5 ｜ price_zero=2
[PASS] ①四桶互斥且窮盡
[PASS] ②★上臂桶恆 0 —— ★★它非 0 ＝【我的推導錯了】，而【拆上臂 fp 不變】那條驗收靠的就是這個推導
[PASS] ③價格恆 >= 0（本輪最小 0.000）
[PASS] ④★深過剩桶非空【且價格真的落到 0】—— ★★沒有它，③「>= 0」在【從來不到 0】時也綠
```
★**實測**：`pop=1 food stock=999` 的價格 **1.000 → 0.000** ⇒ **白送區真的存在**（blueprint：有戲不是 bug）。

---

# 二、★★★而 spec §4b 的【ROI 除零】前提**是錯的** —— 我不照做，附證據

spec 寫：
> `MarginalEconomy.facility_roi(...)` 吃 cost_value ⇒ `cost_value == 0` 時**分母為零**

**窮盡搜索（無 head、無截斷）**：
```
marginal_economy.gd:73   return d_inflow * effective_days - upgrade_cost_value   ←★【減法】不是除法
faction_ai_system.gd:2666  var roi := facility_roi(est, "farming", lvl+1, cost_value)
                           if roi > best_roi: ...                                ←★只比大小
grep -rn "/ *maxf(.*cost\|/ *cost_value\|roi *\/" scripts/simulation/  ⇒ ★★【0 處】
facility_roi( 的呼叫點：production 1 處（上面那個）＋ debug 床 5 處，★全部沒有除法
```
⇒ ★★**`cost_value == 0` 不會除零** —— 它只是讓 ROI 大一個 `cost_value`。
⇒ ★★★**而那正好就是 spec 想要的語意**（「零成本的正收益方案本來就該先做」）——
   **現況已經自動滿足**，不需要 epsilon、不需要 INF、**不需要新常數**。

## ★所以我做的是【不做】，而理由要留在卷面上
```
★spec 裁的是「不用 epsilon，改用重新定義」—— 而【那個修法在解一個不存在的問題】
⇒ ★★若我照做，會憑空加一個 `cost <= 0 ⇒ INF` 的分支
   —— 而那是【一個沒有人需要的特例】，它會在未來被讀成「這裡曾經有個坑」
⇒ ★★★而【不做】要留證據：所以這段 file:line 我寫在這裡，不是默默跳過
```
★**若你查出我漏了某個呼叫點（例如經由別的變數名做除法），我馬上補。**

---

# 三、還沒做的（⑩ 的驗收剩下四項，★都要長跑或 A/B）
```
①★拆【上臂】fp 逐位元不變 —— ★★而它要【分兩顆 commit】才驗得到（先只拆上臂、A/B、再拆下臂）
   ⇒ 我現在是【一顆一起拆】⇒ ★★★這條【我驗不了】，除非回頭拆成兩顆。要不要？我傾向要。
②拆下臂後的價格分布（最低價／落 0 次數）—— 要長跑
③④7a/7b/7c（cost_value==0 次數、幽靈資產、震盪簽名）—— 要長跑
⑤5b：全程 `team.resources` / `tile.public_storage` 每個 res 最小值 >= 0
   ★★★這條我認為【最該先做】：它把「我的推導對不對」變成【直接可量的斷言】，
     而不是只靠 fp 有沒有變去反推
```
★**而 ②③④ 全部要長跑 ⇒ 我會用 WMI detach 起，而長跑期間不動那棵樹。**
