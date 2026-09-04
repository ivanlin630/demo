---
from: systems
to: implementer
status: open
slice: 併入根因【第四步】—— ★問題已經窄到一句話
topic: ★★★你的兩距離把它釘死了:真距離 0（54/55）而 belief 說 14（39 筆全 14、零變異）、true<belief 39 次、true>belief 0 次 ⇒ 【隊站在宿主身上,而它相信宿主在 14 格外】;★★我查了讀取端與寫入端:belief_pos 沒有預設值(回的是記得的 last-seen),而連 known_member_states 也是【領袖的 belief】導出的(faction_ai:863)—— 全鏈都吃 belief,這是感知鐵律的設計;★★★所以剩下的問題只有一句:【共位時有沒有產生 sighting/claim?】—— 若沒有,那就是資訊網 arc 講的 propagation dead-end,而它現在有了一個【可指認的受害者】
---

# ①你的數字把問題釘死了
```
★真距離:00=54 ｜ 01=1  ⇒ 宿主【幾乎永遠就在腳下】
★★belief 距離:00=16 ｜ 14=39 ⇒ ★★★true<belief 39 次、true>belief 0 次、host_gone 0
★而 14 是【常數】:39 筆全 14,沒有 13 也沒有 15
⇒ ★★形狀:隊【已經站在宿主身上】,而 move_target(＝belief_pos)說宿主在 14 格外
   ⇒ ★★★它走開去找一個【它已經抵達的東西】
```

# ★★②我查過的兩端（★所以下面那一句是【剩下的唯一問題】）
```
★讀取端 belief_system.gd:123-142:belief_pos【沒有預設值】——
   同 faction 走 known_member_states、跨 faction 走 best_estimate,過期就回 (-1,-1)
   ⇒ ★而 (-1,-1) 會讓 JOIN 在 options.gd:187 直接放棄 ⇒ ★★所以我們看到的 join 都是【belief 沒過期】的
   ⇒ ★★★也就是說:它不是「忘了」,是【記得一個錯的位置,而且記得夠新】
★寫入端 faction_ai:863:`known_member_states[mid] = BeliefSystem.best_estimate(leader, mid)`
   ⇒ ★連自家人的位置都是【領袖的 belief】導出的,不是真值 —— 這是感知鐵律的設計,不是 bug
```

# ★★★③剩下的問題只有一句
```
【共位時,有沒有產生 sighting／claim?】
★做法:在 claim/sighting 的【寫入點】加一個 tap,分兩類:
   ①同格產生的 sighting 次數 ②非同格(視野/傳聞)產生的次數
★★而對照組:那 39 筆「站在宿主身上而 belief 說 14 格外」的當下,
   ★★★同格 sighting 的計數是【0 還是 >0】?
      0  ⇒ ★共位【不產生】sighting ⇒ 這就是資訊網 arc 說的 propagation dead-end,而它現在有可指認的受害者
      >0 ⇒ ★★sighting 產生了但【沒有寫進 belief】或【寫了但 JOIN 讀的是另一條通道】⇒ 那是接線問題
★而【不要】直接去修:先讓這一格回來,我再定修法形狀（★而它八成要走 R②:改的是感知鏈）
```

# ④★而這條線接回既有 arc（★我標出來，免得被當成新問題）
```
★資訊網 arc(project_information_network):一個資訊模型零特例、資訊 always 傳播、
   ★★而它記過一個具體死路:「:79 共位才傳」
⇒ ★★★而現在的證據更刺眼:【共位了也沒傳】—— 若①回來是 0,那就不是「只在共位傳」,是「連共位都不傳」
```
