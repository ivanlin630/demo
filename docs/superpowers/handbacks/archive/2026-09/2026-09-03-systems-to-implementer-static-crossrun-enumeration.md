---
from: systems
to: implementer
status: consumed
slice: 跨 run static 列舉票（★排在 ③④ 之後，不插隊）
topic: ★blueprint 把「跨 run 不清的 static」收為儀器騙人形態的新成員,理由:同 process 第二輪【靜默少計】而第一輪是對的 ⇒ 比「儀器沒開」更陰;★★要的是【列舉】不是修:production 15 個可變 static 逐個判「跨 run 會不會被清」;★★★判準是【證據】不是印象——每個要附清它的那一行 file:line,清不掉的寫「沒有清除點」
---

# ★①母體（我掃的，★逐個列全，你可以直接用）
```
scripts/simulation/decision/goal_registry.gd:39     REGISTRY
scripts/simulation/decision/goal_resolver.gd:492    _fall_seen          ←★已知：跨 run 不清（本案源頭）
scripts/simulation/decision/need_oracle.gd:32       _construction_visiting（註解自稱 transient，★要驗）
scripts/simulation/decision/options.gd:12           REGISTRY
scripts/simulation/faction_ai_system.gd:20          _a2b_remote_tribute_payers
scripts/simulation/faction_ai_system.gd:775         _fai_ph
scripts/simulation/faction_ai_system.gd:787         _mk_verify_rows
scripts/simulation/faction_ai_system.gd:5490        FACILITY_DEFICIT_DEF
scripts/simulation/interaction_system.gd:38         _mf_seq
scripts/simulation/npc_combat_system.gd:44          _combat_track
scripts/simulation/npc_combat_system.gd:47          _cas_carry
scripts/simulation/path_system.gd:23                _path_cache
scripts/simulation/path_system.gd:34                _sssp_cache（★以 world_iid 為鍵 ⇒ 可能自帶失效）
scripts/simulation/sim_runner.gd:149                SYSTEMS
scripts/data/world_state.gd:159                     driver_ledger
```
★**我的掃法是 `static var` ＋可變容器** ⇒ ★★**若有別的形狀（例：`const` 裡藏可變、或 autoload 單例的成員）我漏了，請補上並說是怎麼找到的。**

# ★★②每個只要三格
```
①【跨 run 會不會被清】：會 ⇒ 貼清它的那一行 file:line；不會 ⇒ 寫「沒有清除點」
②【不清會怎樣】：★三選一 ——（a）只影響 Probe 計數（b）★★影響決策/世界（c）自帶失效鍵所以不影響
③【證據】：不是印象。★★★(c) 要證明鍵真的會變（例：`world_iid` 每次 new world 都不同 ⇒ 貼那一行）
```
★**常數表（`REGISTRY`／`SYSTEMS`／`FACILITY_DEFICIT_DEF`）若確實從不被寫入，寫「唯讀」＋一句根據即可**，不用細查。
★★**而「從不被寫入」也要有根據** —— **`grep` 出所有寫入點，不是「看起來像常數」。**

# ★★★③不要做的
★**不修**（修法與優先序等這張列舉回來再談）。★★**不重構 static 成非 static**（那是另一件事，會動決定性）。
★★★**排在 ③`tracer_completeness`／④`unified_commerce` 判定之後** —— **不插隊。**
