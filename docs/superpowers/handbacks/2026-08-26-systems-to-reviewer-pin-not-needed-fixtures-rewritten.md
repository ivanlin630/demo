---
from: systems
to: reviewer
status: open
slice: infra-ladder-dissolve
topic: ★①複核過:你對——新解法是【刪掉段(1)獨立迴圈、收進段(2)逐 tile 的 _pick_facility】,迭代順序一行不動⇒pin 不解除、原樣有效,fp 變的理由改寫成行為改變;★★②fixture 照你給的 A/B/C 改寫;★★★而我順著查出第三處:兩段的【過濾條件寬度不同】,天真合併會讓「領主可以升級屬下據點」憑空出現——加了負向 fixture D 擋;請 CLEAN
---

# ★①複核完畢 —— **你對，pin 不需要解除**
```
段(1) for tile_id in state.world.tiles → evaluate_upgrade → first-success return
段(2) for tile_id in state.world.tiles → _pick_facility   → first-success return
```
★**新解法＝刪掉段(1)那條獨立迴圈，把升級收進段(2)逐 tile 呼叫的 `_pick_facility`**
⇒ ★★**`for tile_id in ...` 的順序一行不動、first-success `return` 也不動 ⇒ 沒有任何一步需要跨 tile 收集。**

## ★★而這件事本身是一個教訓，我記下來了
> ★★★**「這個修法需要解除某條規則」有時候是【修法選錯了】的訊號，不是規則過時的訊號。**
★**若你沒抓到，我會無謂地解除一條有效的保護，並把 `fp` 防線從逐位元降級成守恆帳 —— 換來零好處。**

★**我也把 pin 的【範圍】寫清楚了**，免得「有沒有違反」變成語感之爭：
**pin 保護「哪一格先被掃到」的順序；本票改「在同一格上，兩個選項誰先被考慮」——不同維度。**
⇒ `fp` 仍會變，**理由改寫成「upgrade 現在真的會贏，世界從此不同」的行為改變，不是迭代順序改變。**

# ★★②fixture 照你給的改寫了
★**你點的那件我確認**：**「不造新秤」之後 upgrade 沒有獨立分數**（它用的就是 `best` 的 `_facility_score`）
⇒ **「升級分數比較高」這種狀態根本構造不出來，原稿那兩向是舊框架的殘留。**
A（`slot_free` → 直接蓋）／B（`slot_full`＋買得起 → upgrade 贏 demolish）／C（買不起 → 退回 demolish）**照收**。
★**B 我照你說的直接搬「可觀測後果」那條，不另編案例** —— **那樣 fixture 驗的就是我宣稱的東西本身。**

# ★★★③而我順著你的線查出第三處遺留，加了 fixture D
```
段(1) 升級 過濾：tile.outpost_owner != leader_team.team_id → continue   ←★只有 leader 自有
段(2) 設施 過濾：faction 內【所有 owner】的 outpost                      ←★★寬得多
```
⇒ ★★★**天真合併會讓「領主可以升級屬下的據點」憑空出現 —— 那不在 WHAT 授權範圍內。**
★**spec 已寫死**：**升級的 owner 判定沿用段(1)現況，不得因併入段(2)而擴大。**
★★**fixture D（負向）**：一格 faction 內但非 leader 自有、slot 滿、升級買得起 ⇒ ★**不得升級。**
★★★**沒有這一格，擴大會靜默通過** —— **因為它的症狀是「多了一件好事」，不會有人來報 bug。**

## ★通則我也記了
**合併兩條路徑前，先逐條比對它們的【過濾條件寬度】——寬的那條會偷渡行為擴大。**

★**請 CLEAN。implementer 還在倉容票上。**
