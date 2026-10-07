---
from: measurer
to: systems
status: open
slice: infonet_scout_test 首次入Tier2就紅——逐格分類
topic: ★只有1個FAIL格（④斥候帶need回領主，got=2非預期的1）。分類＝③以上皆非（不是①床過期、不是②世界回歸）：原本的行為(order_id=700的真買單)仍然正確觸發，紅是因為後來新增的「firsthand catastrophe-care合成訊息」(order_id=2000000002)也滿足測試的計數條件，而測試fixture裡那支子民隊population=0剛好踩到那個新機制的門檻。②桶=0格，不附fp計數。
---

# 一、跑一次的結果

```
樹：3bd40a6a1（本地main，GitHub推送現在500，本次交件照舊先commit本地）
跑法：.\tools\godot.ps1 --headless --script scripts/debug/infonet_scout_test.gd
結果：3 PASS，1 FAIL（①②③全綠，④紅）
①util統領vs野心分化：PASS
③ctx scout fields（領主gather子民belief陳舊）：PASS
④斥候co-loc子民帶need回領主：FAIL（got=2，測試斷言==1）
（檔頭②applicable REGISTRY測：_initialize()裡沒呼叫，不是FAIL也不是PASS——
  檔內註解自己寫明「Part2(a)偵察脫主argmax→side-dispatch，已移到infonet_sideaction_test」，
  函式體還留在檔裡但從未被跑，不計入本次FAIL/PASS分類）
```

# 二、唯一一格FAIL：逐項答三個判準

```
它讀的符號／欄位今天還在不在？
  state.team_known[tid]／MessageData.type／.params.origin_team／.params.order_id
  ——全部還在，型態與語意都沒變。★不是①床過期。

它佈置的前提今天還成不成立？
  fixture：lord(team1)／sub(team2,active_orders帶一張food買單oid=700)／scout(team3,co-located於sub)
  ——前提本身仍然成立且仍然觸發「斥候co-loc→_deposit_help_need寫order_id=700買單回領主」這條★原本要測的行為。

世界那條行為（偵察到場、帶need回領主）在fp世界裡有沒有發生？
  有，而且發生了【兩次】（不是沒發生）：
    order_id=700（qty=50）←_deposit_help_need，fixture設的那張真買單，照原邏輯正確寫入
    order_id=2000000002（qty=1）←faction_ai_system.gd:2613-2638新增的「care-loop firsthand觀察」
      區塊（檔內註解標「P4核心」，比這支test晚加）。這段在co-location分支內會另外合成一筆
      distress order_buy訊息，條件是effective_food/burn < DESPERATION_DAYS。
      ★驗證：fixture的sub從未呼叫AnonCohort.add或設leader_id，population=0
      （已用隔離腳本印出：population=0｜resources全0）⇒ _vfdays=0/0.001=0，必然<DESPERATION_DAYS
      ⇒ 這個新機制在這個fixture裡【必然】額外觸發一次，無關seed/隨機。
```

# 三、分類

```
③以上皆非（2格中唯一那格）——不是①（符號還在）、不是②（原行為仍發生、沒有退化）。
真因：測試的計數斷言「got==1」寫在這段care-loop機制加入之前，當時type==order_buy+
origin_team==2只會對到一筆訊息；新機制加入後，同一個fixture意外地也滿足它的觸發門檻
（population=0是測試fixture本身的疏漏，不是生產code的bug），導致同一個計數謂詞現在對到兩筆。
②桶＝0格，不附fp世界Probe計數（派工信條件式要求，②非0才附）。
```

# 四、落地

```
驗證腳本：scripts/debug/infonet_scout_fail_probe.gd（唯讀，複製④的fixture後逐筆印出
  state.team_known[1]裡符合計數謂詞的訊息，印出order_id讓兩筆的成因可以分辨——不修
  infonet_scout_test.gd、不改世界，純觀察）
跑法：.\tools\godot.ps1 --headless --script scripts/debug/infonet_scout_fail_probe.gd
```

# 五、不下的結論（交你判）

```
這格該怎麼修（把斷言改成"==1且限定order_id<2e9"，還是把fixture的sub補上population，
還是乾脆分兩個斷言各驗一個訊息來源）——本床不判，純分類交件。
```
