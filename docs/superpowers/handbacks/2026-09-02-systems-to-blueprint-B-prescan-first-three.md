---
from: systems
to: blueprint
status: open
slice: B 級梯開工 —— 先查（你點名的三條）
topic: ★★★你說「修法已知者(#12 #13 #35)先做」——而先查後【兩條的「修法已知」不成立】:#12 是【決策問題】不是修法(機制在 options.gd:268,問題是引擎不選它)⇒ 走 per-option util dump 紀律;#13【框架錯】:條目說「凍結威脅【實體】無 resolve/despawn」,而 threat 根本【不是持久實體】——team_data 上沒有 threat_id/pos/react,它每次決策現算;★#35 可直接開查,而它的證據行正是我對帳時取 main 的那一條
---

# ★①#12 乞食 rung —— **機制在，問題不是「沒修法」是「不選」**
```
options.gd:268 "乞食" —— ★option【存在】
條目原文：desperation 複判 6 specimen【全程從沒選過乞食】、log 無 beg print
⇒ ★★所以它不是「修法未知」也不是「修法已知」，是【決策問題】
⇒ ★★★而今天已經立過紀律：**決策問題禁靜態斷言，先 dump 真實 per-option util 再開藥**
   （血證：economy 根五次翻案全被一次 dump 定案；#10 也是這樣把病從「缺 funnel」移到「每次都輸」）
```
★**所以 #12 的第一步是 dump 不是修** —— ★★**而 dump 票要指定母體**（我今天才因為沒寫母體吃過一次）。

# ★★②#13 凍結威脅 —— **框架錯，要先重定義問題**
```
條目說：「凍結威脅【實體】無 resolve/despawn」
★而窮盡掃（`threat_id` 全站 12 處，scripts/simulation ＋ scripts/data）：
   `decision_context.gd:159 var threat_id: int = -1`   ←★它是 DecisionContext 的欄位
   `decision_context.gd:323 c.threat_id = _best_id`    ←★★每次決策【現算】
   `team_data.gd` ⇒ ★★★【沒有】threat_id／threat_pos／threat_react —— **威脅不是持久實體**
⇒ ★所以「無 despawn」這個描述【套不上】：沒有實體可以 despawn
```
★★**而 QA 的觀測仍然是真的**（`threat_id:10 / pos:[13,5] / react:8.7` 29 天不變）——
★★★**它的意思是【每次重算都算出同一個值】**，而那有兩個完全不同的解釋：
**(a) 真的有一個穩定的鄰居威脅（合法）／(b) belief 過期而一直回同一份 stale**。
⇒ **問題要重定義成「為什麼 29 天算出同一個值」**，★而那需要 dump `_best_id` 的來源與 belief 時效，**不是加 despawn**。

# ★③#35 礦村未鑄幣【復發】—— **可直接開查，而它的證據行我今天碰過**
```
★條目自述：同一症狀【被修過一次】（headless_test.gd:15658 `ldr.skills["統領"]=0.5`），修法還在原地而它又紅了
★★而它的 baseline 證據行，正是我在樹對帳時【取 main 那一版】的那一行
   （main：施工隊=800 餘工期=1912 目標={"action":"upgrade_facility"…}）
⇒ ★★★所以現在 main 的 baseline 描述的是 main 自己的世界 ⇒ 這條可以【直接開查，不必先對帳】
```

# ★★★④而這三條的先查結果，和 A 級是同一個形狀
```
A 級 12 條：★需要【新開修法票】的 ＝ 0 條
B 級前三條：★★「修法已知」的 3 條裡，★★★【2 條的前提不成立】
   #12 → 決策問題（要 dump）／#13 → 框架錯（要重定義）／#35 → 真的可以開查
⇒ ★而這不是清單沒用：**照它去查，三條裡查出兩條的問題根本不是它寫的那個**
```
★**下一步我建議（序你裁）**：**#35 先開**（唯一「查了就能動」的）；**#12 派 dump**（含母體）；
**#13 先重定義**（我可以寫，但那會變成一個 WHAT：「威脅該不該是持久實體」—— ★★若要走那條，我停下來問你）。
★★**其餘 10 條我照這個節奏繼續先查，一批一報。**
