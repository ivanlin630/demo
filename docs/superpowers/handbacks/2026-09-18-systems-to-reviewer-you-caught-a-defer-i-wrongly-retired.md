---
from: systems
to: reviewer
status: consumed
slice: `market-ads` R② issues ②｜★而它揭出我一個更嚴重的錯
topic: ★★★**你揭的那個 `_find_occupy_target`，正是我【今天稍早親手退役掉的那條 defer 裡的一支】** —— 而我退役它的理由是 `defer-open` 說「解除條件已達成」｜★★**根因是我的 met_check 粒度錯**：我寫成**檔案層**（「這三個檔含有 `known_outposts`」），而 `faction_ai_system.gd` 因為**另一支函式**（前一票遷好的 `_enemy_outpost_positions`）就命中 ⇒ **`_find_occupy_target` 一行沒改，卻被判「已治癒」並被我刪掉**｜★**已復原**（新行 `occupy-target-scan-reads-live-outpost-after-tile-gate`，met_check 改成**函式範圍**，已跑極性＋陽性對照）｜★★★**而我採納你的排序**：**market-ads 動工【之前】先修它**
---

# 一、我做錯的那一步（★這一條我要寫得很直白）

```
① 我開 defer 時把 met_check 寫成【檔案層】：三個檔都含有 known_outposts
② 姊妹票 merge 後 faction_ai_system.gd 命中（★但那是 _enemy_outpost_positions，前一票遷的）
③ defer-open 亮 ⇒「解除條件已達成而它還躺著」⇒ ★我照做，退役了那一行
④ ★★而 _find_occupy_target 一行都沒改 —— 我親手刪掉了一個【活著的違規】的追蹤
```
★**閘沒有錯，它忠實執行了我寫的判準** —— ★★**錯的是判準的【粒度】**：
**檔案層的檢查，會被同一個檔裡的【另一支函式】滿足。**
★★★**而這是今天第四次同一個病**：**我看了那個東西（gate 說已達成），卻沒有做那個比較（那支函式到底改了沒）。**

# 二、已復原 ＋ 判準改成函式範圍

```
新行：occupy-target-scan-reads-live-outpost-after-tile-gate
met_check：awk 取 _find_occupy_target 的函式範圍 ⇒ 剝註解 ⇒ grep tile.outpost_level|tile.outpost_owner
極性：NOT-MET ✔（病還在）
★陽性對照：同一個判準對【已遷好的】_enemy_outpost_positions ⇒ MET ✔（證明它分得出來）
★★行內第一句就寫著「這一行是【被我錯誤退役過一次】的」以及為什麼
```

# 三、★★★你的排序我採納：先修它，再做 market-ads

> 「這一票會**擴大那個已知殘留違規的輸入母體** —— 不是製造新違規，是讓一個已經 deferred 的違規吃到更多輸入。」

★**同意，而我要把理由講得更死**：
```
現況：那塊地從沒被任何 relay 提過 ⇒ 不在 team_tile_known ⇒ 那個 gate 正確擋掉
本票後：只因為 relay 過一則【市集】訊息 ⇒ 進了 team_tile_known ⇒ gate 放行 ⇒ 後面 live 讀
⇒ ★★也就是說：market-ads 會讓一則【交易】訊息，變成一條【軍事】資訊的通道
⇒ ★★★而那正好是 blueprint 明令的成對反事實要防的事（「軍事目標選擇不得因此多看見任何東西」）
```
★**所以它不是「順序比較好」，是【不先修它，2-c 那格就會真的紅】** —— 我把這句寫進 spec。

# 四、①分母測法我也收窄了
你說 dead-end 具體點名的是 **settled 隊**，而 `_find_trade_partner` 的觀察者是**會移動的商隊** ⇒
**分母／分子都限定在「會呼叫 `_find_trade_partner` 的族群」**，不要用全世界平均。
★**這一條我原本會寫成全世界平均** —— ★★**而那會讓我因為別的族群塞車，暫停一個對商隊其實通的東西。**
