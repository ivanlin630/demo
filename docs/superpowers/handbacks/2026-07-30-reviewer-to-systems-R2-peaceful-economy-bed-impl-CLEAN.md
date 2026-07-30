---
from: reviewer
to: systems
status: consumed
topic: "[R②CLEAN+2必補] 和平經濟床實作——①雙run漏清_a2b_remote_tribute_payers(1行補)②確認indep.gate_*量錯機制(你focus③疑對)真正訊號是construct.start=14 vs complete_build=0，report需標註別誤讀；apothecary對應A1機制核實乾淨"
---

# R②判決：和平經濟床實作（measure-first Step0）— CLEAN + 2 必補（不擋merge）

## 1. ★雙run determinism——序列幾乎全同，漏一個static清空
`peaceful_economy_bed.gd:_print_team_stories`跟`warring_harness.gd:run`(114-127)逐行比對：`seed(SEED)`→`WorldState.new()`→`SimRunner.new()`→`GameSetup.load_config`→`config["seed"]=SEED`→`GameSetup.setup`→tick迴圈(含800-tick draw同款邏輯)——順序完全一致。

**漏一項**：`WarringHarness.run:119` 明文 `FactionAISystem._a2b_remote_tribute_payers.clear()`（comment「每run重置(防跨run污染)」）——bed的第二次 inline run **沒做這行**。親查`interaction_system.gd:607-609`確認這個 static Dictionary 真的被**讀**(`.has(payer_id)`)當貢賦結算閘，非純觀測——若第一輪(WarringHarness.run)留下 payer entry，第二輪沒清空理論上會讀到跨run殘留。

**嚴重度評估**：本 fixture 全隊`faction_id:-1`(無faction)，這個機制是「跨faction遠距徵收」——正常執行下不會fire(沒有faction就沒有貢賦關係)，除非6mo內真有隊透過`_evaluate_independent_strategy`的建國(ally)意外形成faction。低機率但非零，且不該讓「巧合沒發生」頂替「機制上保證乾淨」——這正是這輪Step0要避免的僥倖心態。

**要求**：`_print_team_stories`開頭補一行`FactionAISystem._a2b_remote_tribute_payers.clear()`，跟`WarringHarness.run`對齊，不留隱患。

## 2. ★Q1 tap 錯層——你自己 focus③ 疑對，需要求 report 標註避免誤讀
`indep.gate_ambitious/gate_fail_*/path_ok` 全部只在`_evaluate_independent_strategy`(faction_ai:1257-1266)內bump——這個函式是「fid==-1隊秤建國(ally/subjugate)」的**外交**gate，跟①情境實際測的機制（`goal_resolver._resolve_resource_prereq`材料缺口→forest founding delegate→`_dispatch_builder`）完全是**兩條不同的路**。①隊人格`野心≈0.3`（沿econ_bed.json既有設計）本就低於`AMBITION_FOUND_MIN(0.55)`門檻，`gate_ambitious`理所當然=0——這不是「有動機被卡」也不是「沒動機」，是**這條 gate 對①情境要測的機制而言，從頭到尾就不是相關的量**。

真正跟①機制對應的訊號是`construct.start=14`(dispatch真的發生了14次)vs`complete_build=0`(6個月內沒有一次完工)——這組數字才回答「①這條goal_resolver驅動的founding，動機層有沒有fire」：**答案是fire了**(14次dispatch)，卡點在**執行/完工層**，不在動機層。你自己初看寫的「疑execution-layer非純動機缺」方向對，我親驗確認這個解讀正確。

**要求**：4問report(或measurer/QA拿到這份數字時的說明)必須明講「Q1的`indep.gate_*`量的是另一個機制(建國ally/subjugate)，本情境(goal_resolver材料驅動founding)請看`construct.start` vs `complete_build`」——不要求現在改tap或改code，只要求別讓「gate*=0」被下游誤讀成「①這條路完全沒被卡」或「毫無動機障礙」，兩者都不是這組數字能回答的問題。

## 3. apothecary 對應 A1——核實乾淨
`outpost_system.gd:61-66`確認`apothecary`真實facility、`cost={material:50,tools:2}`——`_construction_facility_need`(need_oracle:45-61)的迴圈會因這筆非0的`cost_r`真的把`need_keep(material)`推高（配合`_facility_deficit≥0.3`閘）。這條需求鏈雖然「因為想蓋藥局」而非「因為想蓋新outpost本身」驅動material渴望，但驅動出來之後，`_resolve_resource_prereq`(goal_resolver:192-219)不管material渴望的**理由**是什麼，一律走同一套「買不到→採@forest→forest founding candidate」邏輯——機制驗證是乾淨的，非測了一個不相干的東西。

## 其餘
liveness ALL PASS(need_keep=100/62 unowned forest)+headless 0-new+constitution 74+@observe-pure零RNG，跟R²v2 spec要求逐項對上，implementer照做無走樣。

## 判決
**CLEAN → merge。** 2項必補（①漏清static/②report加註tap層說明）皆輕量、不擋這輪merge(零sim改本就低風險)，但**必須在measurer產出「權威4問數」落地前完成**——不然①項的殘留風險跟②項的誤讀風險會污染下游 QA 故事稽核跟 blueprint 裁分支的信任基礎，違背這輪Step0「先把量測地基站穩」的初衷。measurer/QA看到Q1數字時務必按②的說明解讀（construct.start=14主訊號，非indep.gate_*）。
