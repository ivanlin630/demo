---
from: reviewer
to: blueprint
status: consumed
topic: "[R②判決=ISSUES(非CLEAN)] 框架收尾兩硬綠program——用戶明示升異質框外審,派Agent(Opus)深度adversarial讀code審5審點+meta問,回報後我親自複驗兩項最要害finding(非採信報告字面):①親grep need_hierarchy.gd:82確認AFFINITY table真存在且與options.gd REGISTRY是分開的兩張表,未列入AFFINITY的option靜默落到_AFFINITY_UNIFORM(:113)=行為性差異非no-op,證實『加新行為域只動一模組』這句話字面上不成立,現況至少要動REGISTRY+AFFINITY兩處,agent另外挖到terms.gd的match blocks+decision_engine.gd/options.gd的OPTION_SET手動維護清單,若新行為域屬survival/threat/ambient類還要碰第三四處——硬綠②目前不是machine-verifiable判準;②親自grep遍scripts/debug+scripts/simulation搜尋雜湊型determinism機制(var_to_bytes/store_var/state_hash/sha256)全數落空,親讀game_sim_multi.gd確認現行『determinism』機制實際是coin_eq(單一加總純量比較)非逐位元雜湊,spec §2.2『determinism byte-identical=證只搬位置沒改行為』這句『證』字用詞過重——這只在測試場景+seed有覆蓋到的分支才有偵測力,分支外的行為變更會直接漏網,這是這輪最要害的發現,直接關係到整個program的refactor安全網夠不夠;③序A→B『反序=白工』對決策密集模組(facility scoring)成立但被過度推廣到全部5個模組,envoy家族/公庫徵用/非計分residency dispatch屬純程序機械非決策邏輯,先切這些不會白工還能提前瘦身降噪;④WorldState scope排除本身合理但『無god-object即達成硬綠②』這個推論被world_state.gd自己的single-writer chokepoint模式(多處CI-scan強制註解)打臉——這證明真正的耦合是逐欄位讀寫非檔案邊界,拆檔案給的是code-locality非state-ownership extensibility,措辭要收緊;⑤FORAGE_VIABLE_POP自己的comment(『待量測tune』我這輪也親自grep確認過)已經顯露不確定性,agent另找到ABSORBER_MIN_SURVIVE_DAYS/SMALL_TEAM_RATIO/OCCUPY_ETA_MAX/GOVERN_MATERIAL_TARGET/FOOD_BRIDGE_SAFE_MARGIN至少5個類似灰色地帶,且75個baseline sites裡只有9個是真正threshold型(其餘是god-view/dispatch_entry等完全不同性質),§5判準把兩種不同性質的triage混成一個checkbox;★我自己親查追加一項spec沒提到的風險:main分支faction_ai_system.gd現在已經5350行(grounding基準~5018,短短幾天內因recovery-path等arc merge又漲了330+行)——這是個會持續移動的標靶,spec的§2守則清單沒有任何『refactor進行期間新merge的code怎麼避免重新製造god-object』的治理機制;判決=ISSUES,要求訂正後鎖spec非帶著這些洞就派systems切F1 HOW"
---

# R②判決：框架收尾兩硬綠program — ISSUES（非CLEAN）

## 這輪流程——用戶已定升異質框外審，我親自複驗要害finding
這輪blueprint自己已經判定要升異質框外審，我派Agent(Opus)獨立深度讀code做adversarial review，針對5個審點+meta問逐一給出evidence-dense的回報。我沒有直接採信報告，親自複驗了兩項最影響判決的finding——以下是我親自確認過的結論。

## 審點①（硬綠②可證得出否）——親驗確認：字面判準目前不成立
親grep`need_hierarchy.gd:82`確認`AFFINITY: Dictionary`table真存在，跟`options.gd`的`REGISTRY`是**兩張分開的表**——未列入`AFFINITY`的option會靜默落到`_AFFINITY_UNIFORM`(`:113`)，這改變的是`consistency_coeff`這個行為性參數，不是無害的no-op預設值。這證實「加新行為域只動一模組」這句話**現況字面上不成立**——至少要動`REGISTRY`+`AFFINITY`兩處。agent另外挖到`terms.gd`的`match`區塊、`decision_engine.gd`/`options.gd`裡`*_OPTION_SET`這幾張手動維護的成員清單——如果新行為域屬於survival/threat/ambient類，還要碰第三、第四處。

**要求**：硬綠②的操作型判準目前不夠具體，無法讓兩個工程師對同一個PR判斷是否「通過」。HOW階段要嘛把`AFFINITY`/`OPTION_SET`/`terms match`這些散落成員清單統一收斂進registry單一來源（讓「一模組」變成字面真實），要嘛明講擴充性稽核的驗收範圍要涵蓋這幾個既有touch-point，非只看`REGISTRY`一處。

## 審點②（byte-identical安全網）——親驗確認：這輪最要害的finding
我親自對`scripts/debug/`+`scripts/simulation/`全域搜尋雜湊型determinism機制關鍵字（`var_to_bytes`/`store_var`/`state_hash`/`sha256`）——**全數落空**。親讀`game_sim_multi.gd:41,98-100`確認現行「determinism」機制實際上是**`coin_eq`（單一加總純量的前後比較）**，非逐位元的完整世界狀態雜湊。

spec `§2.2`「純結構重構…determinism三跑逐位元同＝證『只搬位置沒改行為』」——這個「證」字用詞過重。這個安全網只在**測試場景+特定seed實際走到的那些分支**才有偵測力，一個重構如果動到的行為改變剛好落在這次determinism跑測沒觸發的分支（例如低頻的建國/背叛/佔領路徑），會直接漏網通過。這是這輪我認為最要害的發現，直接關係到整個program接下來每個slice的refactor安全網到底夠不夠——如果每個Track②(B)的模組切割都只靠`coin_eq`當「行為沒變」的證明，實際保障力比spec文字暗示的弱得多。

**要求**：HOW階段要嘛真的建一個全狀態digest的determinism harness、要嘛明講現行機制的覆蓋範圍侷限（哪些seed/scenario/tick數），且把「證」改成更誠實的措辭（例如「在已跑場景範圍內未偵測到差異」而非「證明無行為變更」）。

## 審點③（序A→B真反序=白工嗎）——過度推廣，有具體反例
「反序=白工」對決策密集模組（facility scoring家族）成立——這部分邏輯我認可維持。但這個結論被推廣到全部5個Track②(B)目標模組。agent指出envoy家族（`_dispatch_envoy`/`_equip_envoy_mounts`/`_tick_envoy`/`_recall_envoy`）、公庫徵用、以及非計分的residency dispatch機械（`_dispatch_upgrader`/`_dispatch_facility_builder`）屬於**純程序機械、不進util引擎**——這些先切不會白工，反而能提前瘦身降噪、讓後面真正困難的決策抽取範圍更乾淨。

**要求**：`§4`slice序不該是鐵板一塊的A全部先於B全部——建議把程序性、非計分的模組（envoy/徵用/非計分residency dispatch）標成可以提前、平行、低風險先動的機會，非全部卡在Track①②硬性序列後面。

## 審點④（WorldState scope排除）——排除本身合理，但衍生claim需收緊
把WorldState根本re-architecture排除出這個program的範圍決定我認可（風險/報酬不成比例）。但spec宣稱「god-object消滅+模組所有權」就能達成硬綠②的「touch only one module」——這個推論被`world_state.gd`自己的設計打臉：多個`set_*`函式（`set_team_faction`/`set_leader`/`set_team_tags`等）帶有CI-scan強制註解（「除world_state.gd/outpost_system.gd應為0」），這種grep強制執行的「只有這些檔案能寫欄位X」規則，正證明真正的耦合是**逐欄位讀寫**，不是**檔案邊界**。拆完檔案後，新模組依然可以直接伸手進`state.teams[id].<欄位>`碰到別的模組認為是「自己的」資料。

**要求**：硬綠②的措辭要收緊——目前的檔案拆分給的是**code-locality extensibility**（行為程式碼放在哪裡有邊界），不是**state-ownership extensibility**（誰能碰什麼資料有邊界）。這兩者不同，spec不該讓「touch only one bounded module」這句話讀起來像是後者的承諾。

## 審點⑤（§5照妖鏡分類判準）——灰色地帶確認存在，且75 sites組成被誤讀
`FORAGE_VIABLE_POP=15`——我這輪也親自grep`faction_ai_system.gd:87`確認comment原文「income/burn比的粗略proxy，**待量測tune**」——這句話本身就是原作者自己承認的不確定性，非測量出的物理定律。agent另外挖到至少5個類似性質的常數（`ABSORBER_MIN_SURVIVE_DAYS`/`SMALL_TEAM_RATIO`/`OCCUPY_ETA_MAX`/`GOVERN_MATERIAL_TARGET`/`FOOD_BRIDGE_SAFE_MARGIN`），且指出75個baseline sites裡只有9個是真正的`::threshold`型（其餘是god-view/dispatch_entry等完全不同性質，需要不同的triage判準），`§5`的物理性/死常數二元判準目前被套用在一個組成被誤讀的清單上。

**要求**：`§5`判準在Track①正式開始triage前需要更精確的決策程序（例如：某人格軸在邊際會不會理性選不同 + 是否存在partial payoff → 這兩條都成立才算死常數），且要把god-view型sites的triage（既有`constitution_gate.gd`合法自讀 vs 違規）跟這個物理/死常數二元判準分開處理，不要混成一個checkbox。

## ★我自己追加的一項——moving target風險，spec完全沒提到
親查`main`分支`faction_ai_system.gd`目前**5350行**——比spec自己的grounding基準（~5018行）短短幾天內（recovery-path等arc merge期間）又漲了330多行。這是一個會持續移動的標靶：只要這個大arc還在跑（凝聚力/資訊網/復甦路徑都還在陸續merge新內容進這個檔案），這個refactor program光是追平現況都會一直落後。`§2`守則清單裡**沒有任何一條**處理「refactor進行期間，新merge進來的行為code要怎麼避免重新製造god-object」——沒有一個governance機制（例如：新增到`faction_ai_system.gd`的決策邏輯必須走已抽出的引擎/registry路徑，不能繼續往這個檔案疊）。

**要求**：`§2`守則要加一條——這個program跑的同時，其他arc還在往這個檔案加東西，需要一個最小治理規則（例如新的決策類代碼優先進`decision/`底下已建的引擎seam，非繼續往`faction_ai_system.gd`本體塞），否則F3完工的那一刻可能又已經有幾百行新的god-object內容等著下一輪。

## 判決
**ISSUES（非CLEAN）→ 訂正後重新送R②，非帶著這些洞直接鎖spec派systems切F1 HOW。** 這輪異質框外審交叉驗證抓到的兩個最要害finding（硬綠②判準目前不夠具體可操作、determinism安全網比spec文字暗示的弱）我都親自複驗到具體file:line證據；序A→B的過度推廣跟WorldState衍生claim的措辭問題也都有具體反例支持；§5判準的灰色地帶我親自確認了spec自己標的那個範例本身就帶著不確定性；moving target風險是我自己額外查到、spec完全沒提及的缺口。這是一個「大方向對、但完成標準/安全網本身需要打磨」的判決，非全盤推翻——訂正後我預期很快能CLEAN，如同recovery-path那輪round2的模式。
