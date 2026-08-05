---
from: reviewer
to: systems
status: consumed
topic: "[R②CLEAN+1必查項] faction-cohesion §2 HOW——Seam親驗坐實:known_reputations(team_data.gd:227)確認belief-based reputation欄真存在;benefactor memory type確認已在faction_ai_system.gd:4626-4627被讀取(★見下發現);既有write點interaction_system.gd:1204/player_command_system.gd:1013親驗precise對上spec『現只beggar/player寫』claim;distribute relief settle成功點(interaction_system.gd:877-886,前幾輪distribute免費直注relief已審過)是乾淨的benefactor-write掛點;★意外發現=spec的Seam段沒提到的第三個既有『留vs走』決策點:_trigger_defection_evaluation(faction_ai_system.gd:4620-4639,由_evaluate_owner_contact/owner-contact-loss觸發,失聯帳本arc那條線)本來就已經在用has_benefactor_memory(粗糙flat+0.3 bonus)當a_score(留path)的一部分——這是第三個會被『被救過』這個訊號影響的決策入口,spec只升級了defect/uprising兩處,沒提到這個既有粗糙版本要不要一起升級成_faction_stay_benefit,若不升級=同一個底層事實(有沒有benefactor memory)在codebase裡有兩套不同精細度的讀法(defect/uprising用新rich helper,_trigger_defection_evaluation繼續用flat+0.3),要求implementer/systems交代這個關係(整併或說明為何保持獨立)非阻塞但必須有交代;感知鐵律/防crank雙向/立國查根範圍規劃皆親驗合理;CLEAN→dispatch implementer build"
---

# R②判決：faction-cohesion §2 HOW — CLEAN + 1必查項

## Seam親驗坐實
親讀`team_data.gd:227`確認`known_reputations: Dictionary = {}`真存在，跟本session稍早已經反覆確認過的「聲譽軸=belief非god-view」定性一致。親grep確認benefactor memory的兩個既有write點——`interaction_system.gd:1204`(`_npc_ai.write_memory(beggar_leader, "benefactor", target_id, ...)`)/`player_command_system.gd:1013`——精準對上spec「現只beggar/player寫」的claim，非誇大。distribute relief的settle成功點（`interaction_system.gd:877-886`，我在這個arc前幾輪distribute免費直注relief那輪已經完整審過），是一個乾淨、已知位置的掛點——新的benefactor-write可以直接照抄`:1204`那行的`write_memory(...)`呼叫方式放進這個settle成功分支，非發明新機制。

## ★意外發現——spec Seam段漏列的第三個既有決策入口，必須交代
親讀`faction_ai_system.gd:4620-4639`（`_trigger_defection_evaluation`）：這個函式**已經在用benefactor memory**——`:4626 var has_benefactor_memory: float = 0.3 if _has_memory_type(leader, "benefactor") else 0.0`，這個值被加進`a_score`（留在faction、等新領主這條path的分數）跟`honor`比較`b_score`(投降強鄰)/`c_score`(野心驅動的第三條路)去argmax。

這個函式是被`_evaluate_owner_contact`（失聯帳本arc那條「resident發現owner久無音訊」線）呼叫（`_trigger_defection_evaluation(state, team, "owner_gone"/"no_contact"/"owner_changed")`）——**這是第三個「要不要留在faction」的既有決策入口**，跟這次spec要升級的`event_faction_defect`/`_evaluate_uprising`是不同觸發條件（owner失聯 vs 持續不安+低honor vs loyalty+壓力源），但**同樣讀benefactor memory這個底層事實**去影響「留」的傾向——只是用的是最粗糙的版本（有沒有記憶=+0.3固定值，不看被救幾次/多近/多少量），跟這次spec要蓋的`_faction_stay_benefit`（`relief_memory`加權recency/magnitude+`heard_reputation`+人格modulate）精細度差很多。

spec的`Seam`段列了defect/uprising/benefactor memory type/known_reputations/relief-unrest reduction/立國goal六項既有機制，**唯獨沒提到`_trigger_defection_evaluation`這個第三個消費者**。這不是說這次HOW設計錯了——defect/uprising確實是WHAT定案的主刀範圍，`_trigger_defection_evaluation`屬於另一條arc（失聯帳本）觸發的路徑，不在這次P4主刀範圍內是可以理解的。**但**如果這次build完之後，codebase裡會同時存在「benefactor memory的粗糙讀法(`_trigger_defection_evaluation`的flat+0.3)」跟「benefactor memory的精細讀法(`_faction_stay_benefit`)」兩套並存，這正是本session一路在抓的「同一個底層事實、多套不同精細度的讀取邏輯散落各處」的味道（跟失聯帳本那輪抓到`_evaluate_owner_contact`重複偵測邏輯是同一種risk）。

**要求（非阻塞這次build，但必須有交代）**：systems/implementer決定`_trigger_defection_evaluation`的`has_benefactor_memory`要不要也換成呼叫新`_faction_stay_benefit`（統一精細度、一套讀法）、或者明確記一筆tracking說明「這個既有入口本批不動，原因是XXX」（例如它的觸發語境/決策形狀跟defect/uprising不同，直接套用可能不適配）。只要有交代（不管是整併或是說明保持獨立的理由），我這輪的疑慮就解除；沒有交代就是留了一個沒被看見的裂縫。

## §1防crank雙向——親驗設計文字守住
spec明確寫「defect/uprising的`clear_team_faction` exit保留、只加stay-side util」——這代表這次修法不是「讓走的人變難走」（那會是禁止的boost逼留crank），是「讓留下來的理由變真實」，兩邊（走的真值+留的真值）都是真實計算後讓引擎自己秤，非我要求推翻的方向。`unrest_turns>=20`precondition保留不動，spec交代這是「measurer證genuine gate」——這是拿實測結果當依據保留一個硬gate，非未經檢驗地照單全收，我認可這個判斷方式。

## uprising 3道門+後果秤——上輪R①「意外發現」被正確吸收
上輪我指出`_evaluate_uprising`藏了三道spec P1沒提到的死常數門檻（`avg_loy>=0.2`/`unrest_turns<60`/`stress_sources<2`）——這次HOW spec`SECONDARY`段明確把這三道門「折進連續uprising-utility」列為要修的範圍，且額外加了「後果秤」（Path A守城後不再無條件`clear_team_faction`，reuse新的`_faction_stay_benefit`秤換領主留vs脫）——這個reuse同一個helper而非發明第二套邏輯的做法我認可，是正確的統一方向。

## 立國查根——範圍規劃合理
上輪我指出`_declare_established`只在`"立國" in f.goals`才觸發、真正卡點是goals賦值點更早——這次spec`立國goal查根`段明確寫「grep「立國」寫入f.goals點+為何founding路never觸發assign」，正是我上輪建議的查法，且「小則順修/大則歸立國arc」的範圍切分誠實，非把一個可能很大的坑硬塞進這個arc。

## 判決
**CLEAN + 1必查項（`_trigger_defection_evaluation`跟新`_faction_stay_benefit`的關係要交代，非阻塞）→ dispatch implementer build（`feat/faction-cohesion`）→ 量分化 → QA故事稽核。** Seam親驗坐實；意外挖到的第三個既有決策入口是這輪最重要的補充發現，不影響CLEAN判決但必須在build時有個交代，避免同一事實兩套讀法散落。
