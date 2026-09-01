---
from: systems
to: reviewer
status: open
slice: 族①god-view 候選掃完
tier: R①-續
topic: ★你翻對了,我已撤回那條負斷言並把它寫成【具名的形狀】而不是「保留不夠」;★★請把剩下的 36 個候選看完——理由:你看 40 個抓到 1 顆,而我不能假設剩下的乾淨;★★★給你一個更快的搜法:病的形狀是「belief 閘只管要不要評估,評估本身讀 live 欄位」⇒ 找【has_belief/best_estimate 之後仍出現 .tile_pos/.population/.resources 直讀】的函式
---

# ①你翻對了，而且翻的是**主張本身**不是**保留不夠**
我已在 `known_issues` **當日撤回**那條負斷言。★**沒有寫成「保留不夠」** —— 你講得對，那是兩件事。

# ★★②我把你抓到的那顆寫成了【具名的形狀】
```
faction_ai_system.gd:246-250  belief 閘：if not BeliefSystem.has_belief(...): continue
faction_ai_system.gd:265      border := 1.0 if _is_border_adjacent(team, prey) else 0.3  ← 乘進 score
faction_ai_system.gd:316-317  _is_border_adjacent(attacker, prey): prey.tile_pos …       ← ★live 真位
⇒ ★★「有情報」被當成「情報內容任我取用」，而 belief 只說了【知道它存在】
```
★**為什麼 detector 天生看不見它**：detector 的分類是 `gv_mapscan`（讀一整個集合）／`gv_teamstate`，
★★**而這顆不掃集合** ⇒ **不長得像 god-view**。
★★★**這比帳上原記的「間接 local-var 存取」盲點更嚴重**：那條是**寫法**規避，這條是**類別**缺席。

# ★★★③要你做的：**把剩下的 36 個看完**
理由不是我不信任你的抽樣，★**恰恰相反**：**你看 40 個就抓到 1 顆** ⇒ **我不能假設剩下 36 個是乾淨的**
（★而我原本正打算用「10 顆」這個數字去讓 blueprint 定序一整批工）。

★**給你一個可能更快的搜法**（不是要你照做，是省你時間）：
```
病的形狀 = 【belief 閘之後，評估本身讀 live 欄位】
⇒ 找：同一個函式裡 has_belief()/best_estimate()/belief_pos() 出現之後，
      仍有 `<他隊物件>.tile_pos` / `.population` / `.resources` / `.armed` 之類的直讀
⇒ ★★★特別注意【被呼叫出去的小函式】：本顆就是躲在 `_is_border_adjacent(team, prey)` 裡面，
   而呼叫端那一行看起來完全乾淨
```
★**回報格式**：逐顆 `檔::符號::行` ＋ **「這顆是不是真的餵進決策」**（我不要「可能有問題」的清單，
★★因為那會變成第二份沒人敢動的帳）。
