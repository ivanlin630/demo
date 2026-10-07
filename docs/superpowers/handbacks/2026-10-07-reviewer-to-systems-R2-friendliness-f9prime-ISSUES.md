---
from: reviewer
to: systems
status: open
slice: F9′ NPC 選址讀【已知】敵友據點
topic: R② ＝ **ISSUES,一列**｜★②你優先打的：f(d)從「最近一座」改「每一座都算」後,總分不再被單項上限(≤50)夾住,而是隨【通過距離篩的已知據點數】線性累加,密集據點群會讓這一項量級蓋過其他評分項——這是真的、算得出數字的風險，不是我猜的；★①leader_id查邊讀的是live team.leader_id不是belief記錄,是這個codebase既有的結構限制(relation_edges全部keyed人物id,沒有belief版的「我記得的領袖是誰」)不是F9'新引入的洞,但F9'第一次把它用在「掃描記憶中的據點」而非「正在互動的對象」,staleness風險比舊用法更真；③核過乾淨,全repo只有一個呼叫點
---

# 0 審了哪棵樹

`origin/main` ＝（你信裡cite的spec檔最新版）；核對對象＝faction_ai_system.gd:5940-5981一帶的site-selection函式、diplomatic_ai_system.gd:92-93,114(_edge_intensity_to既有用法)。

# 1 ★②你優先打的——數學上真的會爆,不是假想

```
score += Σ_每筆 g×maxf(0,5-d)×10×w
  單項範圍：g∈[-1,1]、maxf(0,5-d)∈[0,5]、×10⇒單項∈[-50,50]、w=慎重+(1-好戰)∈[0,2]
    (兩個人格值依這個專案一路以來的0..1慣例)⇒單項絕對值上限100
舊公式(只看最近一座)：總貢獻被單項上限夾住,≤50(舊式x10那個)
新公式(每一座都算)：總貢獻＝Σ,上限隨【通過d<5篩選的已知據點數】線性增長,沒有整體上限
⇒ 在密集定居區(例如候選格周圍5格內剛好有3-4座已知的同陣營或敵對據點,在這個遊戲的
  settlement密度下不是極端情境),這一項可以輕易衝到300-400,而同函式裡其他評分項
  (productivity*100最多約100、距離懲罰dist*5很小、TERRAIN_BUILD_BONUS/資源加成都是
  個位數到幾十)全部被這一項量級壓過——選址會變成幾乎只看「已知據點關係密度」,
  資源/地形/距離這些原本的考量實質上失去作用
⇒ 這「是不是我們要的」要你們裁,但至少先把這個數量級落差講清楚：不是「多算幾座更
  精確」,是「主導因子換人了」——如果不是故意要的,可以考慮除以√N或取平均而非總和,
  或對Σ本身再夾一個上限,維持跟其他評分項同一個量級
```

# 2 ①你優先打的——查邊讀live leader_id,是既有結構限制，F9'用法比舊用法更吃staleness

```
diplomatic_ai_system.gd:92-93（既有用法,tribute_accept）：
  feud_i=_edge_intensity_to(leader.relation_edges,"feud",aggressor.leader_id)
  ⇒ aggressor是當下【正在互動】的TeamData參數,它的leader_id就是【現在真的在打交道的
  那個人】,不可能有stale問題(互動雙方都是即時的)
F9'的新用法：owner_id來自known_outposts(belief,可能很舊)⇒要查grat-feud得先
  `state.teams.get(owner_id).leader_id`——這是讀【對方現在的】leader,不是觀察者
  belief裡記錄的那個人
⇒ git grep過,這個codebase沒有任何「belief記錄的領袖身分」機制(known_leader/
  believed_leader之類零命中)——這不是F9'自己發明的洞,是relation_edges這整套機制
  本來就只認得「現在的leader_id」,F9'是第一個把它用在【掃描記憶中的對象】而不是
  【正在互動的對象】的地方,staleness風險第一次真的有機會發生(對方換過領袖,觀察者
  的舊恩怨查到新領袖身上會查無,恩怨憑空消失——不是洩露,是記憶對不上現在的查詢對象)
⇒ 這不是player-facing的god-view洩露,是NPC決策計算的一個準確度小縫,嚴重度遠低於②,
  標出來讓你們知道有這個既有限制,不建議為這張小票另開一條belief-leader追蹤機制
  (那是更大的活),可以先接受這個小誤差
```

# 3 ③核過乾淨

```
git grep _enemy_outpost_positions(全repo：整支函式只有:5947那一個呼叫點,且就是它自己
  要被改名的那個函式——沒有第二個讀者依賴它的舊回傳值或舊語意
⇒ 陌生人從敵變中立這個行為改變,結構上不可能有別的讀者受影響,因為沒有別的讀者
```

# 4 判決

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "②f(d)從最近一座改每一座都算，分數量級是否合理",
     "file_line": "faction_ai_system.gd:5978-5981(f(d)舊式只取最近一座,上限50)；新式§130(Σ每一座,無整體上限)",
     "truth": "密集定居區下這一項可以輕易衝到300-400,蓋過同函式裡productivity/地形/資源等其他評分項(個位數到百位),選址會實質上只看據點關係密度；是量級問題不是精確度問題,建議除以√N或加一個Σ整體上限"}
  ],
  "note": "①是既有結構限制(relation_edges沒有belief版領袖追蹤),F9'第一次踩到但嚴重度遠低於②,不建議為此另開機制。③核過乾淨，全repo只有一個呼叫點。" }
```
