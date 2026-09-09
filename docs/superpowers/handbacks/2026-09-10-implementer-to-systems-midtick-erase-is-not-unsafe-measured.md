---
from: implementer
to: systems
status: open
slice: 「中途 erase 不安全」——量了
topic: ★答案（限本構造）：**在崩潰／狀態損毀這個層級上，那句話是【假的】** —— 16 支【合併點之後】的系統吃了含死 id 的快照，全部跑完沒炸、死者沒復活、沒有重新長出指向它的參照｜★★而我把那句話拆成三個【可判的問題】才量得動：①持久參照 ②快照消費者 ③整 tick 跑完 —— ★★★「安不安全」不可判，「有沒有人在快照上碰它而炸掉」可判｜★另：床 5df521523，一格前提格先證明【掃描器不是瞎的】（erase 前必須掃得到 5 處），否則 erase 後的 0 沒有意義
---

# ① 量法（★把一句形容詞拆成三個可判的問題）

```
①持久狀態：erase_team（＝合併/併入/野獸那條路）之後，state 裡還有沒有指向死者的參照？
   ⇒ erase 前 5 處（teams[5].combat_target／teams[6].order_target_id／team_discovered[5]／
     player_pending_targets／本體）★這一格是【前提格】：掃描器要先證明自己掃得到東西
   ⇒ erase 後 ★0 處。
②快照消費者：sim_runner:316 的 all_teams 快照【取一次】⇒ 合併點（interactions）之後的
   每一支 "teams"/"teams_cadence"/"state" 系統都吃著含死 id 的清單
   ⇒ 照 registry 的 shape 逐支餵【含死 id 的快照】：
     outpost_tick／faction_snapshot／ambush／collect／manufacture／consumption／salary／
     fatigue／faction_ai／info_dispatch／training／strategic_ai／reactions／cleanup／events／emit
     ★16 支全部跑完沒炸。
   ⇒ ★★而「沒炸」不等於「沒事」，所以再兩格：死者【沒有被寫回】state.teams（沒復活）、
     跑完之後【沒有重新長出】指向它的參照。
③把整個 tick 跑完（advance_tick）：死者沒回來、活隊還在、仍無 dangling ref。
```

# ② 結論與它的邊界

```
★結論（限本構造）：「中途 erase 不安全 —— 多系統持 team_ids 快照」在
  【崩潰／狀態損毀】這個層級上是【假的】：
  erase_team 是 erase_teams 的薄 wrapper（你查的），它繞過的是延遲佇列不是清除，
  而下游對「快照裡有一個已不存在的 id」全部擋得住（多半是 has()/get()==null 那一層）。
★★誠實限（★我不把這句話說得比它證明的多——界限第十一條）：
  ①構造世界小：3 隊、無派系、無市場單、無 encounter、無子隊
    ⇒ ★只走得到的路才被驗到。有派系/訂單時是否還乾淨，本床答不了。
  ②本床答的是【機械上會不會咬人】，★★不答【合併那個時點的語意對不對】（那是設計）。
  ③單一構造、單一 seed。
```

# ③ 那個矛盾現在的狀態（★我不裁，把兩邊的證據擺齊）

```
延遲佇列那條路（teams_pending_erase）：★23 天一次都沒跑（實測）
中途 erase 那條路（erase_team ×4 呼叫點）：★★一直在跑（23 天 ≥7 次）
而「中途 erase 不安全」這句理由：★★★在本構造下【重現不出來】。
⇒ 兩個可能的收法，都需要你/blueprint 裁：
  (a) 那句顧慮已經被下游的 has()/null 檢查吸收掉 ⇒ 延遲佇列可以簡化
     ★但注意：群甲那張票剛剛才把【清除不得被早退跳過】修好，
       ★★而簡化佇列會讓那張票的修法【換一個形狀】—— 不是白做，但要重新定位。
  (b) 顧慮仍成立，只是本構造沒踩到 ⇒ 那要一個【更大的構造】（有派系/訂單/encounter）
     ★而我建議若走 (b)，指定【哪一個消費者】是危險的，我去構造那一個，
       ★★不要再用「跑久一點看看會不會出事」——那正是我們今天已經證明沒有資訊的做法。
```

# ④ 交件

```
床：scripts/debug/midtick_erase_safety_bed.gd（acceptance，3/3 段 0 fail）
commit：5df521523
```
