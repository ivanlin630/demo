---
from: systems
to: implementer
status: consumed
topic: "[investigation-slice(純查不改):specimen 非中立性=掛 SpecimenTracer 讓世界真實分岔、威脅所有 specimen-based QA·現象(measurer lag-quantify 意外撞到):同 seed/config/branch,Pass1(無 specimen)death.starve_anon=28、Pass2(7 隊掛 tracer)=26,Team10 死亡型態也改變·★systems code-read 已排除既有三道防線:①is_specimen(specimen_tracer:21)純讀零 RNG②capture 路徑(:56/86/107/148)全包 _begin/_end_observe(Probe.enabled=false+PathSystem.suppress_observe_noise=true)③LOD-exempt 已移除(sim_runner:506-507/518)·★★我的假說(要你查證或否證、別預設對):非 RNG 的【狀態副作用】——tracer re-query(_snapshot/BeliefSystem.best_estimate/to_task/各 finder)呼叫帶 lazy cache 的系統(LaborSystem.ensure_fresh、belief snapshot/known_member_states 寫入、market finder memo、PathSystem 快取)→提前暖化或更新快取→下游行為改變;_begin_observe 只擋 RNG+Probe、擋不住 cache/state mutation·★T1:逐一列 tracer capture 路徑 callee、標記哪些會寫 state 或暖 cache(file:line)、判哪個最可能分岔;特別看 BeliefSystem.best_estimate 是否寫回 known_member_states/belief entry、LaborSystem ensure_fresh 是否被 re-query 觸發、PathSystem find_path 是否寫 cache·★T2 最小重現:bed 同 seed 同 config、A=無 specimen/B=specimen_team_ids=[某隊]、跑 N tick 比 StateFingerprint→找第一個 fp 分岔 tick→往回 pin 誰寫了 state·★禁改 production(純 investigation、temp tap 用完 revert)·完→handback to:systems 附 file:line+分岔點、我裁修法(可能擴 _begin_observe 成只讀語意 or tracer 專用 read-only 路徑)·優先序:排你手上工作之後;不阻塞當前 gate(非 specimen 量測乾淨)、但阻塞 QA 故事稽核可信度=中高·地基KEEP"
---

# investigation-slice（純查不改）：specimen 非中立性

## 現象（measurer 意外撞到、非其 ticket 範圍）
同 seed/config/branch：Pass1（無 specimen）`death.starve_anon=28`、Pass2（7 隊掛 tracer）=**26**；Team10 死亡型態改變（Pass1 單一連續 famine 7→8→9→10；Pass2 兩段短 episode、從未到 9/10）。

## systems code-read 已排除既有三道防線
①`is_specimen`(specimen_tracer:21) 純讀零 RNG ②capture 路徑(:56/86/107/148) 全包 `_begin/_end_observe` ③LOD-exempt 已移除(`sim_runner:506-507/518`)。

## ★★我的假說（**要你查證或否證、別預設對**）：非 RNG 的**狀態副作用**
tracer re-query（`_snapshot`/`BeliefSystem.best_estimate`/`to_task`/各 finder）呼叫**帶 lazy cache 的系統**（`LaborSystem.ensure_fresh`、belief snapshot/`known_member_states` 寫入、market finder memo、PathSystem 快取）→ 提前暖化/更新快取 → 下游行為改變。`_begin_observe` **只擋 RNG+Probe、擋不住 cache/state mutation**。

## T1（查）
逐一列 tracer capture 路徑 callee、標記**哪些會寫 state 或暖 cache**（file:line）、判哪個最可能分岔。特別看：`BeliefSystem.best_estimate` 是否**寫回** `known_member_states`/belief entry、`LaborSystem.ensure_fresh` 是否被 re-query 觸發、`PathSystem.find_path` 是否寫 cache。

## T2（最小重現）
bed：同 seed 同 config、**A=無 specimen / B=`specimen_team_ids=[某隊]`**、跑 N tick 比 `StateFingerprint` → 找**第一個 fp 分岔 tick** → 往回 pin **誰寫了 state**。

**★禁改 production**（純 investigation、temp tap 用完 revert）。完 → handback to:systems 附 file:line + 分岔點，**我裁修法**（可能擴 `_begin_observe` 成只讀語意 or tracer 專用 read-only 路徑）。
優先序：排你手上工作之後。不阻塞當前 gate（非 specimen 量測乾淨），但**阻塞 QA 故事稽核可信度**=中高。地基 KEEP。
