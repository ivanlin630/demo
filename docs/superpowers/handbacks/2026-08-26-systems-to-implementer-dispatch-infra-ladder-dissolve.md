---
from: systems
to: implementer
status: open
slice: infra-ladder-dissolve
tier: behavior
topic: ★★★DISPATCH(R² CLEAN)——★排在你手上倉容票【之後】,別插隊;★★這張票今天【不會改變任何數字】,它防的是未來反向傷害(錢夠時升級 first-match 搶答壓設施);★★★修法=不造新秤:刪段(1)獨立迴圈、把升級收進段(2)逐 tile 的 _pick_facility 當第三個 ok_*;★迭代順序 pin 原樣有效、不解除;★★fixture D 是負向的,別漏
---

# ★★★DISPATCH：`docs/superpowers/specs/2026-08-26-infra-ladder-dissolve-HOW.md`（R² CLEAN）
★**排在你手上那張倉容票【之後】** —— blueprint 准的序，**因為倉容票才是讓「錢第一次夠」可能發生的那一票。**

## ★★①先講死：**這張票今天不會改變任何一個數字**
```
實測 ge_margin = 1，而那唯一一次「錢夠」是 reject_pop 不是 afford
⇒ ★升級【從來沒有上過秤】，不是上秤輸了 ⇒ 買不起的選項在任何秤上都不會贏
```
★★**它防的是【未來反向的】傷害**：
| 時期 | 階梯的行為 |
|---|---|
| 現在（錢永遠不夠） | 升級**永遠輸**（先評，每次不合格就落到設施） |
| ★**未來（錢夠了）** | ★★**升級永遠贏**（先評、first-match、買得起就 `return`）⇒ **設施再也不會被評估** |
⇒ ★★★**兩個方向都不是「秤」。** ★**所以驗收的 organic 層現在必然驗不出東西 —— 那是預期，不是失敗。**

## ★★★②修法：**不造新秤**（★R² 抓到我原稿的洞：我寫 argmax 卻沒定義升級的分數）
```
_pick_facility 本來就在比「怎麼騰出一格來蓋 best」：
  ok_slot_free  有空位 → 直接蓋            代價：無
  ok_demolish   位子滿 → 拆掉 lowest 再蓋   代價：失去 lowest（既有 best > lowest × 1.5）
★upgrade       位子滿 → 擴建多一格再蓋     代價：付升級全費（afford 仍是 applicability gate）
```
⇒ ★★**三者共用同一個分數 ＝ `best` 的 `_facility_score`**，**因為想蓋的是【同一座設施】，差別只在取得那格的代價**
⇒ ★★★**尺度天然可比。** ★**做法＝刪掉段(1)那條獨立迴圈，把升級收進段(2)逐 tile 呼叫的 `_pick_facility`，成為第三個 `ok_*`。**

### ★★★★而【迭代順序 pin 原樣有效，不解除】—— 我原稿寫錯了，R² 抓到
★**我本來寫「本票有意解除那條 pin」，那個論證是針對我【已經放棄的舊形狀】寫的。**
**新形狀下 `for tile_id in state.world.tiles:` 的順序一行不動、first-success `return` 也不動 ⇒ 不需要跨 tile 收集。**
⇒ ★★**pin 保護「哪一格先被掃到」；本票改「在【同一格】上兩個選項誰先被考慮」——不同維度。**
★**`fp` 仍會變，但理由是【upgrade 現在真的會贏，世界從此不同】的行為改變，不是迭代順序改變。**

### ⚠️★★★★★③合併會偷渡一個【行為擴大】—— 這是我順線查出來的，別漏
```
段(1) 升級 過濾：tile.outpost_owner != leader_team.team_id → continue   ←★只有 leader 自有
段(2) 設施 過濾：faction 內【所有 owner】的 outpost                      ←★★寬得多
```
⇒ ★★★**天真合併 ＝「領主可以升級屬下的據點」憑空出現，而那不在 WHAT 授權範圍。**
★**升級的 owner 判定沿用段(1)現況，不得擴大。**

# ★④驗收（★fixture 四格，D 是負向的）
| fixture | 狀態 | 斷言 |
|---|---|---|
| A | `slot_free` | 直接蓋 `best`，不考慮 upgrade |
| ★B | `slot_full`＋`best > lowest × 1.5`＋**升級買得起** | ★**upgrade 贏過 demolish**（★這就是「可觀測後果」那條，直接搬成 fixture，別另編案例） |
| ★C | `slot_full`＋**升級買不起** | **退回 `demolish`**（驗「upgrade 不可達時舊行為原封不動」） |
| ★★D | faction 內、**非 leader 自有**、slot 滿、升級買得起 | ★★★**不得升級** —— **證明範圍沒擴大** |

★★**fixture 必須呼叫真正的 production 決策函式**，不得自己重寫一份比較邏輯再斷言（★同 `storage_fits`）。
★**D 沒有的話，擴大會靜默通過** —— **因為它的症狀是「多了一件好事」，不會有人來報 bug。**

**organic 層**：★**把 `upgrade` 與 `ok_demolish` 的比例照原樣印出來，不預測**（★不打折 ⇒ 兩者同分而拆建多過 ×1.5 一關 ⇒ **upgrade 應該恆贏，那是本票的直接後果不是巧合**）。
**其餘**：對帳仍平；headless（baseline 7）＋憲法閘 PASS；★**`fp` 會變 ⇒ 守恆帳，並【當場重測新基線寫進 handback】。**

# ★⑤誠實限（spec 內有全文）
★**兩個方向相反的誤差我不假裝抵銷**：**不對升級打折 ⇒ 偏強**（打折就要發明 `UPGRADE_MARGIN`）；
**升級的倉容 `+250`／駐軍上限未計入 ⇒ 偏弱**（計入要各自發明價值換算）。**兩個都照原樣留著。**
