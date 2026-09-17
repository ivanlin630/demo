---
from: systems
to: implementer
status: open
slice: 兩支姊妹 site 改讀 `known_outposts`（`feat/sister-sites-outpost`）
topic: ★**正式派工**：R② CLEAN（★R① 我判免、reviewer 重 grep 核過同意）｜★★**spec**：`docs/superpowers/specs/2026-09-18-sister-sites-read-known-outposts-HOW.md`｜★★★**兩個【不要修錯】的守衛是會紅的格**（1-d／1-e），而 **1-e 我寫錯過一次、已更正** —— **「別動它」清單是斷言不是豁免**｜★**七格 ＋ 到場點名**（要件③，★expect 記得同步）
---

# 一、做什麼（兩支，第三支前一票已做掉）

```
② strategic_ai_system.gd:309-320  _find_trade_partner
   ★該函式 :300-302 的註解 2026-09-02 就自承 CANDIDATE-LEAK…待 R²＋follow-up
③ decision_context.gd:597-602     gather 裡的 _known 迴圈（找 work_outpost）
兩支都改成列舉 BeliefSystem.known_outposts(state, <觀察者 id>)，讀子記錄的 owner_id／level
```

# 二、★★★三個【不要碰】，每個都有格盯著

```
1-d：goal_resolver.find_nearest_known_tile 逐字未改
     ★它閘後讀的是 t.terrain —— 地形不會變 ⇒ 合法（判準是【那個欄位會不會變】）
1-e：gather() 裡【真的是自家】的 6 處逐字未改：:484／:655／:672／:748／:749／:783
     ★★我原本寫「8 處」是錯的（我拿一個 grep 計數貼上語意標籤、沒有逐處分類）
        ⇒ 那個數字裡混進了【本票要改的 2 處】與【3 處真違規】
§4  ：:811／:813／:824（join_host_flow／occupy_target_flow 讀別隊 live 的 outpost_level）
     ★★★真違規，但【不在本票】—— 已開 defers `join-occupy-flow-reads-live-outpost-level`
     ⇒ 它的閘結構跟本票不同族，混進來會讓驗收失焦
```

# 三、驗收（spec §3，七格）
1-a 知道得太多那半消失／1-b 知道得太少那半消失／1-c 零 god-view／**1-d**／**1-e**／
1-f 世界級（兩支的候選集各印「只有新版有／只有舊版有／兩者都有」三個數）／1-g 到場點名 ＋ expect 釘 `N／N`。

★**1-f 那三個數若有一個是 0 ⇒ 要解釋，不要當成綠**（★前一票那三個數是 297／213／100，**換了一批**才是預期樣子）。

# 四、順序
★**批五（`team-ui` ＋ 3 支釘免疫欄）先做完**，它小；本票接著。
★★**兩票都從 merge 後的 main 開新 branch** —— roll-call 的 merge 閘還在跑，綠了我把 sha 給你。
