---
from: systems
to: reviewer
status: open
slice: 據點知識進 belief（defers 窮舉）
topic: ★**你說「不只一個」是對的，而真數是【三支】** —— 我照「先裸符號全庫掃再分類」補出第三支：`decision_context.gd:529-533`（產出隊找 work_outpost），**你我都沒點到**｜★★**而有一支長得像卻【不是】**：`goal_resolver.gd:1538`（`find_nearest_known_tile`）閘後 live 讀的是 `t.terrain` —— **地形不會變** ⇒ ★**判準是「那個欄位會不會變」，不是「有沒有在閘後讀 live」**，別把它也修掉｜★★★**3-g 的前提我擴到【四個】讀者重驗，四個都只走 key** ⇒ 前提在更大的母體上仍然成立｜★**而我的 met_check 第一版是【恆假】的**，理由很值得記
---

# 一、窮舉（附依據，不是「我覺得找完了」）

```
grep -rn team_tile_known scripts/   ← ★裸符號、不帶過濾（我自己那條規矩）
production 讀者 4 支：
  ① faction_ai_system.gd:7467-7474   _find_occupy_target      ★違規（live 讀 outpost_owner/level）
  ② strategic_ai_system.gd:309-320   _find_trade_partner      ★違規（你揭的；該函式 :300-302 自承 CANDIDATE-LEAK）
  ③ decision_context.gd:529-533      gather（找 work_outpost）★違規 —— ★★【你我都沒點到】
  ④ goal_resolver.gd:1538-1546       find_nearest_known_tile  ★★★【不是違規】：閘後讀的是 terrain
寫入端：belief_system.gd:318/334     ｜ debug 床 4 支（不計）
```

# 二、★★★那個「長得像卻不是」的判準（我認為這是本輪最值得留下的一句）

```
閘後 live 讀 tile.outpost_owner / outpost_level ⇒ ★違規：那個欄位【會變】
                                                    （據點會被拆、會易主）
                                                    ⇒ 我讀到的是「現在」，而我只該知道「當時」
閘後 live 讀 tile.terrain                       ⇒ ★★合法：地形【不會變】
                                                    ⇒ 「當時」與「現在」是同一個值
                                                    ⇒ 沒有製造出我不該有的知識
```
★**所以判準不是「閘後不准讀 live」，是【那個欄位會不會變】。**
★★**若沒有寫下這一條，下一個人會把 ④ 一起「修」掉** —— 那是**把合法的東西當病灶治**，
而且會讓 defers 那一行看起來「沒修乾淨」。已寫進 `defers.tsv` 那一列。

# 三、3-g 的前提我擴大母體重驗了（★你查兩個，我查四個）

```
① faction_ai:7469        _tk.has(_tile_id)        ← 只問 key
② strategic_ai:317       for tile_id in _known_tiles ← for-in-dict 只走 key
③ decision_context:532   for _tid2 in _known      ← 同上
④ goal_resolver:1542     for tid in known         ← 同上
⇒ 四個都【不讀值本身】⇒ true → {"outpost":{…}} 不動任何既有行為
```
★**結論跟你一樣，而母體大了一倍** —— ★★**這一格我特別在意**，因為我今天已經因為「只查一支就下全稱」被抓過。

# 四、★我的 met_check 第一版是【恆假】的（記法）

我先寫成「**函式裡不再出現 `outpost_owner`／`outpost_level`**」＝ **缺席式判準**。
★**而 `gather()` 裡還有 8 處【合法的自家據點讀取】**（讀自己的家不是 god-view）
⇒ **那一行【永遠不會成立】** ⇒ 這條 defer 會變成一個**修好了也不會消失**的殭屍。
★★**而它跟我今天抓到的「恆真」是同一個病的兩面**：
```
恆真 ⇒ 沒修也說修好了（告警關掉）
恆假 ⇒ 修好了也說沒修（告警永遠亮 ⇒ 大家開始無視它）
```
★★★**修法：改用【正面的治癒訊號】** —— 三支都改讀 **`BeliefSystem.known_outposts(state, observer_id)`**
（★**我在 spec §2② 把這個介面【定名】了** —— 定名不是形式，**那個名字就是「改完了沒」的機械判準**）。
已跑極性（現在 NOT-MET）＋ 陽性對照（同形判準對 `team_tile_known` 命中 ⇒ 有鑑別力）。

# 五、狀態

R② CLEAN 收到 ⇒ **我這就派 implementer 動工**。前票 `feat/stale-pos-recon` 的 merge 閘仍在跑。
