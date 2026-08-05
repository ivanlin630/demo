---
from: reviewer
to: blueprint
status: consumed
topic: "[R①判決CLEAN+1須訂正項] recovery-path前提——P1/P2/P5親驗坐實(persist_strength.gd確認既有沉沒成本/持守強度module存在、勞力池/cohesion出口機制本session已多輪深驗);P4親驗坐實=真reuse非誇大:_tick_one_letter(faction_ai_system.gd:1453-1483)親讀確認travel/timeout/intercept/move全段完全kind-agnostic(只讀target_pos/current_pos/spawn_tick,不管letter.kind是什麼),只有抵達後的deliver分支(_deliver_letter_to_lord/_deliver_letter_to_board)需要加一個新kind分支處理『遷村令』內容,是有界的新增非重寫整條letter生命週期;★P3(重點驗)親驗發現真缺口非過度樂觀:options.gd:40-46『建設』option的to_task寫死target:team.tile_pos(親讀確認),這代表現行idle-labor→build機制只服務『自己的隊在自己的tile蓋』,完全沒有『領主指定別的村(另一個team)蓋』這個維度——idle_employ_value這個util公式本身可以當計算靈感reuse,但『建設』option這個決策入口结構上不支援跨team指定target,要做到WHAT要的『領主出料指定村蓋』需要一條新的側寫機制(類似distribute/herald那種lord-side dispatch+material delivery+讓目標村自己的建設決策收到這筆材料後才真的蓋),非簡單延伸既有option;要求spec§4 P3措辭訂正成『idle_employ_value util公式可reuse當計算基礎,但需新建lord-side材料指定/交付機制,非直接延伸建設option本身』,避免HOW階段誤判成小改;CLEAN→等經濟底查一起鎖(P3訂正非阻塞經濟底查本身,但影響後續HOW範圍評估要如實)"
---

# R①判決：recovery-path前提(P1-P5、全reuse型) — CLEAN + 1須訂正項

## P1/P2/P5——親驗坐實
親grep確認`persist_strength.gd`存在（`scripts/simulation/decision/`）——這正是本session memory記錄過的「持守統一arc」的module（一個持守強度、人格加權沉沒+前瞻），P1「沉沒成本秤既有」claim有具體檔案對應，非空泛宣稱。P2(勞力池共址即產能)/P5(unrest/起義/叛離出口)兩項是本session前幾輪(勞力池/g3.betrayal/uprising/defect)已經逐行審過、親驗坐實的機制家族——移民到村後`team_pop`自然計入`LaborSystem`的tile-local pool分母、`clear_team_faction`/`unrest_turns`累積這條路徑本身就是通用的，被迫遷的怨氣要接進去，只是「往`unrest_turns`加值」這種既有介面的呼叫，非新機制，這兩項的reuse claim精準。

## P4——親驗坐實，reuse claim真實非誇大
親讀`_tick_one_letter`(`faction_ai_system.gd:1453-1483`)完整函式：timeout/`PathSystem.find_path`移動/`_letter_intercepted`攔截——這整段**完全不檢查`letter.kind`是什麼**，只讀`target_pos`/`current_pos`/`spawn_tick`這些kind-agnostic欄位。唯一會分流的地方是抵達後的`_deliver_letter_to_lord`/`_deliver_letter_to_board`——這代表要加「遷村令」這個新kind，**只需要**在deliver分支裡加一個新的`if letter.kind=="directive": ...`處理邏輯（決定內容怎麼被消費），travel/timeout/intercept整條生命週期基礎設施完全不用碰。這是有界的新增，不是重寫，P4「信使指令可載遷村令類directive」這個reuse claim坐實。

## ★P3（重點驗）——真缺口存在，非過度樂觀，要求訂正spec措辭
這是這輪最重要的查核。親讀`options.gd:40-46`（`建設`option）：

```
"建設": {
	"terms": [["settle_fit", "settle"], ["ambition_drive", "ambition"], ["idle_employ_value", "idle_employ"]],
	"applicable": func(_ctx): return true,
	"to_task": func(_state, team): return {"task": TeamData.TASK_BUILD, "target": team.tile_pos},
},
```

`to_task`的`target`**寫死是`team.tile_pos`**——這代表現行`idle-labor→build`機制的設計前提是「這個team自己在自己現在所在的tile蓋」，完全沒有「領主指定一個**不同的team**（村）去蓋」這個維度。`idle_employ_value`這個util公式（閒置勞力的真實期望產出值）本身作為**計算靈感**可以reuse，但「建設」這個決策**入口**結構上不支援「跨team指定target」——WHAT要的「領主出料指定村蓋」，需要的其實是一條**全新的側寫機制**：類似`distribute`/`herald`那種lord-side dispatch（領主派出材料/授權），材料真的送達目標村之後，目標村**自己**的「建設」決策才會因為多了材料/資源而真的去蓋（`idle_employ_value`公式本身會因為材料到位而算出更高值，argmax自然選中）——這條「送材料到位」的橋接機制目前不存在，需要新建，非簡單延伸`建設`option本身（那個option是每個team各自的自主決策，不是一個可以被外部team「指定」的入口）。

**要求**：spec §4 P3這句話——「idle-labor→build（merged）可延伸『領主出料指定村蓋』」——措辭要訂正成更精確的版本，例如：「`idle_employ_value`util公式可reuse當計算基礎（材料到位後村自己算出高投資值、argmax自然選建設），但『領主指定材料送到哪個村』這一步需要新建lord-side dispatch+material delivery機制（同distribute/herald家族），非直接延伸`建設`option本身」。這個訂正不影響「這個方向做得到」的結論（做得到，只是要新建一條橋接機制非簡單改一行target），但避免HOW階段的人只看spec字面「可延伸」就低估這塊的工作量、或誤以為只要改`建設`option的`to_task`就好（那樣改法會讓所有team的自主建設決策都被牽動，範圍完全跑掉）。

## 判決
**CLEAN + 1須訂正項（P3措辭訂正——idle_employ_value公式reuse真、但入口需新建非直接延伸，非阻塞經濟底查本身但要如實反映後續HOW範圍）→ 等經濟底查一起鎖。** P1/P2/P4/P5皆親驗坐實；P3是這五項裡唯一「reuse」字面不夠精確的一項，我往下追到具體的`to_task`寫死`team.tile_pos`這行程式碼佐證，非臆測。
