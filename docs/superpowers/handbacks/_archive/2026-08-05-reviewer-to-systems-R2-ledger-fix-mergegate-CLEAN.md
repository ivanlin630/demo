---
from: reviewer
to: systems
status: consumed
topic: "[R②merge-gate CLEAN] 失聯帳本defensive/rescue真consumer fix(baf2a670,修QA REFUTE手不聽腦)——親讀完整diff確認QA挑出的write-only flag真的被接上真世界效果:①defensive→decision_context.gd:237-241親讀確認team.contact_vigilant_until>current_tick時threat_threshold真的被maxf(...-CONTACT_VIGILANCE_THREAT_DROP,0)降低,這條threat_threshold是既有備戰/防衛/求和決策已經在讀的既有機制(周邊comment『threat option的applicable gate讀此』),非新開一條平行旋鈕;②rescue→親grep確認SubteamSystem.dispatch_anon_messenger(subteam_system.gd:70-85)是這整個資訊網arc從herald/scout輪就在用的既有anon信使共用原語(population>=2 gate/leader_id=-1 phantom pattern一致),reuse非發明;_lost_unit_pos親讀確認belief best_estimate優先、缺則退回ledger自己的last_known_pos(dispatch時snapshot),兩條路徑都是self-memory/belief零live god-view;test⑦真的呼DecisionContext.gather()比較threat_threshold改動前後真實輸出非重算公式;test⑧真的掃state.teams找有沒有真spawn出parent_team_id/current_task/move_target都對的子隊非只查flag;determinism byte-identical但≠前一輪inert baseline=確認defensive/rescue真的在warring bed產生行為差異;CLEAN→measurer re-measure(4類全真+分化+98breakdown)→QA新verdict→merge(與cohesion合併里程碑)"
---

# R②merge-gate判決：失聯帳本 defensive/rescue 真consumer fix（baf2a670）— CLEAN

## QA REFUTE的性質——這是「驗執行端」教訓的又一次應驗
上輪我CLEAN了`_apply_contact_reaction`的argmax結構（四類真competing非if/elif），但`defensive`/`rescue`兩類在**當時的spec文字**明確寫「本批不建防禦/救援隊動詞」——那時我讀到這句話，理解成「這是spec自己承認的deferred scope」而非bug，沒有把它標成問題。QA這輪抓到的是更深一層：**就算argmax結構是真的、四類util計算是genuine的，如果選中`defensive`/`rescue`之後什麼世界效果都沒發生，這個「分化」本質上是假的**——慎重高的領主選了defensive，跟野心高的領主選了writeoff，唯一差別只是probe tap名字不同，遊戲世界看不出任何差異。這正是這session一路強調的[[feedback_verify_execution_end]]——candidate生成/util計算是真的≠真的發生了什麼。QA這次抓得對，非我上輪失職，是deferred scope碰上「verify execution end」這條線正好撞在一起，這次補上是正確的下一步。

## defensive——親驗真接上既有threat perception路，非新旋鈕
親讀`decision_context.gd`的`gather()`：

```
c.threat_threshold = ThreatAssessment.THREAT_BASE_THRESHOLD + _caution * 0.3
if team.contact_vigilant_until > state.world.current_tick:
	c.threat_threshold = maxf(c.threat_threshold - CONTACT_VIGILANCE_THREAT_DROP, 0.0)
```

`threat_threshold`是**既有**機制（comment確認「threat option（備戰/迎戰/求和）的applicable gate+eval讀此」）——這次改動只是在既有公式後面加一個條件式的下修，`contact_vigilant_until`過期後這個下修自然消失（純時間視窗，非永久buff）。這是genuine「餵進既有決策路」的寫法，不是另開一個`contact_defensive`旗標讓某個新函式單獨讀（那樣才是「又一個平行旋鈕」）。`_apply_contact_reaction`裡`defensive`分支現在寫`team.contact_vigilant_until = state.world.current_tick + CONTACT_VIGILANCE_DURATION`（親讀確認`CONTACT_VIGILANCE_DURATION=3天`），乾淨的一行set。

## rescue——親驗reuse既有anon信使共用原語，非發明
親grep確認`SubteamSystem.dispatch_anon_messenger`（`subteam_system.gd:70-85`）——這是我在本arc更早幾輪（herald/scout anon化那幾輪）已經反覆見過的共用原語：`population>=2`前濾（跟`can_send_herald`同款冗餘守）、`leader_id=-1`phantom pattern（跟先前herald-carrier那輪驗過的既有pattern一致）。`_apply_contact_reaction`的`rescue`分支呼叫這個既有函式派`TASK_SCOUT`子隊、target=`_lost_unit_pos(...)`，`_equip_envoy_mounts`（既有helper）——整段都是既有機具的組合呼叫，沒有寫一行新的team-spawn邏輯。

`_lost_unit_pos`親讀確認：team-subject優先讀`BeliefSystem.best_estimate(...).tile_pos`（更新鮮的belief），缺則退回ledger自己記的`last_known_pos`（dispatch當下的snapshot）；letter則直接用`last_known_pos`。兩條路徑都是self-memory/belief，零live god-view，跟這個arc一路守住的感知鐵律一致。

## 測試——真integration verification，非查flag
`test⑦`親讀確認**不是**檢查`contact_vigilant_until`有沒有被設就結束，而是真的呼叫`DecisionContext.gather(state, t)`拿到**實際threat_threshold數值**、前後比較確認真的降了——這是對真實決策管線輸出的驗證，非查一個中繼變數。`test⑧`親讀確認掃`state.teams`尋找有沒有一個`parent_team_id==1 and current_task==TASK_SCOUT and move_target==lost_pos`都對得上的子隊真的被spawn出來——這證明rescue反應真的觸發了完整的team建立+移動目標設定流程，非只是呼叫函式沒出錯。

## determinism——byte-identical但刻意標「≠前一輪inert baseline」
commit message寫「determinism 4360AE91≠前inert 9290F462=defensive/rescue真consumer現在warring fire、行為真改」——這句話的意思是：這輪的determinism驗證本身還是3-run byte-identical（沒有引入非determinism），但**跟上一輪(a3c11288)的baseline雜湊值不同**，代表這次修法真的讓世界行為產生了差異（因為defensive/rescue現在真的有效果會被跑進去），而非「改了code但什麼都沒變」的空修——這是誠實地用雜湊差異佐證「真的改到行為」，是我認可的驗證紀律。

## 判決
**CLEAN → measurer re-measure（4類全真+分化+98 breakdown[herald34+scout39+convoy25=98已查無bug、subteam記帳WHAT-mandated下批]）→ QA新verdict → merge（與cohesion合併里程碑）。** 這次修法精準對應QA抓到的「手不聽腦」問題本質——不是重新設計argmax（那部分上輪已驗證genuine），是把選中之後「什麼都沒發生」的兩條路接上真實世界效果，且兩條都reuse既有機制（threat_threshold/anon信使派遣）非新開機制，測試設計也對應升級成真integration驗證。地基KEEP。
