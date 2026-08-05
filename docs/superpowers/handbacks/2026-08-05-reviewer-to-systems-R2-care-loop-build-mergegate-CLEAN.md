---
from: reviewer
to: systems
status: consumed
topic: "[R②merge-gate CLEAN] 領主主動照護loop build(a24d4c71)——★★必查項②獨立逐行核完成:讀feat/lord-care-loop branch HEAD live內容(非commit歷史)確認_tick_info_scout的firsthand觀察write整段(讀target.population/effective_food合成distress、去重、寫team_known)確實inline寫在既有if scout.tile_pos==target.tile_pos co-location分支內部,前面緊接著既有的belief刷新+_deposit_help_need呼叫,同一段程式碼裡沒有抽成外部函式、沒有任何脫離co-location gate的呼叫路徑;test⑤親讀確認是這輪最重要的adversarial驗證——特意把scout搬離村莊(非co-location)後assert『不會』發生firsthand write,這是對防線本身的正面測試非只測『有co-location時會寫』;必查項①holding refresh-and-keep親讀_step_contact_ledger確認新增kind=='holding'專屬分支,entry觸發care/ignore反應後重置dispatched_tick/expected_return_tick並append回kept(非落入下方一次性kind的resolved=true丟棄路徑),搭配_ensure_holding_ledger(once-guard,已有entry的村不重建)在同一per-team cadence迴圈裡先於_step_contact_ledger呼叫,兩機制疊加確保holding entry真的持久監看非查一次就消失;test①直接呼叫真實_step_contact_ledger確認entry觸發反應後仍留在ledger裡;care/ignore(_pick_care_reaction)雖只2候選但義氣/統領vs野心兩個獨立加權util比大小,非直接比人格特質本身,結構上是genuine competing非死常數分支;test④走完整_tick_info_scout→真實GoalResolver._distribute_candidates端到端管線確認observation真的餵到賑濟候選生成;determinism/constitution/零死常數皆親驗坐實;CLEAN→measurer量cohesion①natural真考"
---

# R②merge-gate判決：領主主動照護loop build（a24d4c71）— CLEAN

## ★★必查項②——獨立逐行核完成，讀live branch HEAD非commit歷史
這是這輪最重要的查核，systems特別要求獨立複驗。我沒有信任commit diff或systems的自我陳述，直接`git show feat/lord-care-loop:scripts/simulation/faction_ai_system.gd`讀branch尖端當下的live內容，確認`_tick_info_scout`的完整程式碼結構：

```
if scout.tile_pos == target.tile_pos:
	BeliefSystem.record_claim(...)          # 既有：刷新position belief
	_deposit_help_need(...)                 # 既有：relay已post買單
	# ★★care-loop firsthand 觀察 write（P4核心）
	var _vburn = ...
	var _vfdays = ResourceSystem.effective_food(state, target) / _vburn
	if _vfdays < DESPERATION_DAYS: ...synth distress → team_known...
	Probe.bump("scout.info_returned")
	_recall_envoy(...); return
```

**新的firsthand觀察write整段(讀`target.population`/`ResourceSystem.effective_food(state, target)`合成distress、去重、寫入`mother.team_known`)確實原封不動地寫在這個既有`if scout.tile_pos == target.tile_pos:`分支內部**——緊接在既有兩行(belief刷新+`_deposit_help_need`)後面，同一個縮排層級，沒有被抽成一個外部可獨立呼叫的函式，也沒有任何脫離這個co-location檢查的呼叫路徑。這條防線守住了，跟上輪要求逐字一致，且comment本身就把我上輪的顧慮寫進去（「差別只在此co-location gate...分支外讀=違憲換皮復刻」）——這代表這個要求不只是被動符合，是真的被implementer理解並記錄下來的設計原則。

**test⑤是這輪對這條防線最有力的驗證**：`_test_firsthand_needs_colocation`故意把scout搬離村莊（`scout.tile_pos = Vector2i(0,0)`，村在(5,5)），呼叫`_tick_info_scout`後assert**沒有**firsthand write發生。這是對防線本身的**正面測試**——不只測「co-location時會寫」，還測「非co-location時真的不會寫」，這是我這輪最看重的一項，親讀確認測試邏輯正確、非空殼。

## 必查項①——holding refresh-and-keep，親驗坐實
親讀`_step_contact_ledger`確認新增了`if String(entry.get("kind",""))=="holding":`專屬分支——逾時觸發`care`/`ignore`反應後：

```
entry["dispatched_tick"] = state.world.current_tick
entry["expected_return_tick"] = state.world.current_tick + (原expected - 原dispatched)
kept.append(entry)
continue
```

這是重置監看窗（保留原本的持續時間長度、重新從現在起算）並把entry放回`kept`——**不會**落入下面給herald/scout/convoy用的`entry["resolved"]=true`丟棄路徑。搭配`_ensure_holding_ledger`（once-guard，已有entry的村不重建，`:1679`確認在同一個per-team cadence迴圈裡排在`_step_contact_ledger`之前呼叫）——兩個機制疊加：`_ensure_holding_ledger`負責補上還沒被監看的村，`_step_contact_ledger`的holding特殊分支負責讓已存在的entry持久續留非查一次就消失。這比我上輪列出的兩個選項（純靠lazy補建 vs 改`_step_contact_ledger`特殊處理）**更完整**——兩條防線都做了，非只選一條。`test①`直接呼叫真實`_step_contact_ledger`確認entry觸發反應後仍在ledger裡（`resolved==false`），親讀確認為真integration驗證。

## care/ignore competing util——結構genuine
`_pick_care_reaction`只有2個候選（`care`/`ignore`），寫法是`care_u = overdue_ratio*(0.3+義氣*0.5+統領*0.2)`、`ignore_u = overdue_ratio*(0.3+野心*0.7)`、`return "care" if care_u>=ignore_u else "ignore"`——雖然只有2個候選用直接比較非dict+迴圈，但這兩個util是**各自獨立加權計算後**才比大小，不是直接比較「義氣 vs 野心」這兩個raw人格值本身——這仍然是genuine competing util的結構（2候選時直接比較就是正確的argmax形式，不需要為了形式而套用dict+迴圈），非偽裝的if/elif死一條。

## 觀察→distribute端到端——test④親驗真integration
`_test_firsthand_to_distribute`：走真實`_tick_info_scout`(firsthand write)→真實`GoalResolver._distribute_candidates`，確認candidate真的fire、`terminus_team_id`對到正確的傲村——這是完整管線的integration驗證，非只測某個中繼步驟。

## determinism/零死常數
`_vfdays`/`_deficit`純算術、`_oid`合成規則`CARE_FIRSTHAND_ORDER_BASE + target_id`保證去重穩定（同一村重複觸發不會疊加多筆），零新RNG。理不理走`care_u`/`ignore_u`連續util、無「逾時X必派」死常數。

## 判決
**CLEAN → measurer量cohesion①natural真考（moderate-distress ex-ante床：責任lord村留人vs疏忽村叛離）→ QA → merge → blueprint推用戶。** 這輪兩項必查項都親自獨立驗證到具體程式碼行為（非採信自我陳述），尤其firsthand write的co-location鎖定是這整個資訊網/凝聚力大arc目前最關鍵的感知鐵律防線，這次守得乾淨。地基KEEP。
