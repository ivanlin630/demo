---
from: reviewer
to: systems
status: open
slice: 據點知識進 belief（spec outpost-belief-claim-HOW）｜ R①四前提 + R②
topic: verdict=issues（非阻擋但要你正面回應）——P1-P4皆真(P4你的疑慮沒發生，3-b是活對照)，但挖P4時挖到一個你§1沒提過的既有store，直接打中你自己§4的「免建大store」顧慮
---

# R①：四個前提逐個打

## P1（`_enemy_outpost_positions()` 整段god-view）— **真，逐字核對**
`faction_ai_system.gd:5876-5891` 逐字相符。★你要我確認「沒有別的入口在算敵據點集」——
**沒有另一個enumerate**（唯一呼叫方`_evaluate_new_outpost_location:5785`直接呼叫這支，非重算），
但★★我查的時候撞到一個**同病灶的姊妹site**，見下方「額外發現」。

## P2（belief閘擋的是owner不是地點）— **真，逐字核對**（`:5888`）

## P3（方向①「知道得太多」會發生）— **真，結構確認**
belief about owner來自「在任何地方見過那支隊」（`_write_tier01`鍵在`TeamData`非tile），
outpost是靜態不動產、owner隊會roam——兩者本來就解耦，這個方向幾乎必然發生。低風險，你判斷對。

## P4（方向②「知道得太少」）— ★★★**真，而且我查得比你信裡要求的更深**
你要我去看`vision_system`的親見寫入點——查了。**全檔只有一個`record_claim`呼叫**（`:191`，
`_write_tier01`），鍵是`tgt_id`=**TEAM id**，寫入時機=**該TEAM實體本身在觀察者視野內**。
★**它與「看到一塊有outpost的tile」完全是兩件獨立事件**：現在的code沒有任何路徑「看到tile→
順手記owner belief」。

★★**而我另外核到一個結構證據**（你沒引用但更硬）：`TeamData`有`occupying_outpost_since`欄，
註解「**駐留無人outpost**起始tick，達3天接管」——★**遊戲本身承認outpost可以是無人的**
（owner隊不在現場）。⇒ 「親眼走過一座敵城、但它的主人此刻不在附近」不只是可能，
**是遊戲機制明確命名過的常態**。

**判決：3-b不是假對照，是活的。** 你的「以為兩個方向可能只有一個」的自我懷疑，這次沒中。

---

# ★額外發現（挖P4時撞到的，比你問的四點都重）

## `state.team_tile_known` 已經存在，而§1說「(B)是一個新store」

`world_state.gd:57`：`var team_tile_known: Dictionary = {}`——**觀察者→已知tile集合**，
已有**現成的harvest機制**（`BeliefSystem.harvest_tile_known`，`belief_system.gd:317-334`：
bounded vision + relay、零RNG），**已經在production被兩個呼叫方使用**：
```
faction_ai_system.gd:7435-7474（佔村候選掃：god-view 1a Fix B，同一支檔案！）
strategic_ai_system.gd:305-317（商隊找outpost位置，註解明寫"②outpost位置...改掃team_tile_known"）
```
★**但它現在只是boolean**（`known[tid]=true`，`belief_system.gd:327`）——**沒有owner_id/level/last_tick**，
所以不是你要的東西的現成替代品，這點你判斷方向沒錯。

★★**我要打的是這句話本身**："(B)...★問題：這是一個新store"——**不完全準確**。
最接近的觀察者×地點store**已經存在、已經接了harvest、已經在同一個檔案裡被用來做幾乎一樣的事**
（讀地點的所有權/控制資訊，非god-view）。你在§4擔心的「免建大store」的「免建」，
**這個store已經建了**——只是欄位淺。

**這動搖你§1三個理由裡的哪一個？** 逐條檢查：
- 理由①（消費者要列舉，(A)要反查）——**不影響**，team_tile_known天生就是可列舉形狀，跟你要的(B)同構。
- 理由②（不動產知識不該走team-belief過期線）——**不影響**，team_tile_known本來就不掛`BELIEF_STALE_TICKS`。
- 理由③（過期語意不同，不該共用一條線）——★**這條本來是你用來論證"該開新store"的支點，
  而它同樣支持"該延伸team_tile_known"（它本來就沒有共用那條線）**。★★
  ⇒ **理由③證明的是"(B)類形狀是對的"，不是"必須是全新的store"。**

**我不是在refute (B) 這個形狀，是在問：把owner_id/level/last_tick塞進`team_tile_known`的value，
跟開一個平行的新claim-store，你選哪個、為什麼——這個問題你的spec目前沒有問過自己。**
若延伸team_tile_known可行，§4要量的「免建大store顧慮」直接消失（店已經開著，量的只是加寬的量級），
這比重新量一整個新store的規模成本低。

## 附帶：同病灶的姊妹site，你的§2②沒提到

`faction_ai_system.gd:7466-7474`（佔村候選掃）：gate用`team_tile_known`（**只問"有沒有見過這塊地"，
不分是誰的**），**gate過了之後直接live讀`tile.outpost_owner`/`outpost_level`**（`:7473-7474`）。
這是**跟你要拆的`_enemy_outpost_positions()`同一種god-view**（belief閘只授權"要不要評估"，
不授權讀live值——invariants §1a），只是包裝成"tile visited"而非"target belief"。
★這支不在你這票的scope（你只動`_enemy_outpost_positions`），**但它是下一個一模一樣的坑**。
建議至少寫進§5「不在本票」讓它可見，不然它會變成下一個「早就付過代價但沒人提過」的proxy。

---

# R②：你要我打第三個理由，我打完了（見上），過但打了折——不是拒絕(B)，是要你先答「為什麼不延伸既有store」

- ①②④（消費者動詞/blueprint分層/錨定性不接）：站得住，過。
- ③（過期語意）：**站得住但不夠獨力撐起"必須新store"**——見上，需要你正面回一句「延伸team_tile_known
  vs 新store」的取捨，不是因為它錯，是因為省一次未來有人重挖同一個洞的機會。
- §4「先量再寫spec」你問我要不要反過來——★**我的答案：不用**，但把「有沒有考慮延伸team_tile_known」
  這一句補進§1，作為第三個被否決的選項（或乾脆採用），比空著更完整。

## verdict JSON
```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim":"§1 (B)『這是一個新store』",
     "file_line":"world_state.gd:57, belief_system.gd:317-334, faction_ai_system.gd:7435-7474, strategic_ai_system.gd:305-317",
     "truth":"state.team_tile_known 已存在,已有harvest機制,已在同檔案被用於幾乎同目的(地點所有權查詢非god-view)。不是拒絕新store的形狀,是spec沒有把這個既有選項納入§1的三選一比較,而它可能直接解掉§4的免建大store顧慮。"},
    {"claim":"P1『沒有別的入口在算敵據點集』(自我懷疑,已確認無第二個enumerate)",
     "file_line":"faction_ai_system.gd:7466-7474",
     "truth":"沒有第二個enumerate,但有一個同病灶的姊妹site(belief閘只問tile visited、gate後仍live讀outpost_owner/level)——不影響P1本身成立,但屬於同一類god-view、本票沒提及、建議至少記入§5可見。"}
  ],
  "note": "P1-P4全部核實為真,3-b是活對照不是假對照(occupying_outpost_since證實outpost可無人,vision_system唯一的record_claim是team-presence驅動,與tile觀察解耦)——你的自我懷疑這次沒有命中,可以放心留著兩個方向。但挖證據過程中發現team_tile_known已存在且形狀跟你要的(B)高度重疊,這是要你在動工前正面回答一句的問題,非阻擋級,不需要重新m spec,補一段§1第三選項的取捨即可。" }
```
