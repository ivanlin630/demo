---
from: blueprint
to: systems
status: consumed
topic: "[perf arc 憲章(用戶帶入外部agent指令、我加兩修正後採納)+派 Phase1 細 profile·★憲章:①每次修改→full sim→Story QA 流程不降不取消(終極目標=把full sim壓便宜讓每改全跑付得起;過渡期分層:slice短窗+定向QA、arc里程碑full 12mo+全故事審=現行實務)②優化分兩道:位元級安全道(cache/memo/spatial index/避重複query/減allocation、FP byte-identical機器證)vs 行為影響道(降頻/deferred cascade=時序變=指紋變=intended-change流程+LOD紅線、外部agent誤列無害、修正)③禁降Team decision fidelity/message/reaction等故事生成機制·★Phase1 細 profile(只量不改、擴充perf_phase_bed既有FaiPhase markers往內鑽):Team step拆解=perception/state gathering|needs eval|candidate generation(applicable gates)|scoring(term×weight)|selection|execution各分支(movement-pathfinding/resource/event/message/faction-reaction)——各階段耗時+呼叫次數+candidates/evaluations量+重複world query偵測(同tick同query幾次)+allocation熱點+『全體慢vs特定team/action慢』分布(per-team timing histogram+per-option execution timing)·上次93.7%粗定位為天花板、這次鑽進faction_ai內部把93.7%拆開·短窗跑法(3-7天窗、上次成功經驗)·與settlement平行(S2b gate照跑不搶)·output=hot spot排行(含byte-identical-safe與否標注)→我帶用戶裁Phase2清單·evidence-only禁edit"
---

# perf arc 憲章 + Phase 1 細 profile 派工

憲章三條(用戶指令+兩修正):full sim→Story QA 不降(過渡分層、終極=壓便宜);優化分位元級安全道(FP 機器證)vs 行為影響道(intended-change+LOD 紅線);禁降故事生成 fidelity。
Phase 1:擴充 perf_phase_bed 往 faction_ai 內部鑽——Team step 全拆解(感知/需求/候選生成/計分/選擇/執行各分支)+呼叫次數+candidates 量+重複 query 偵測+allocation 熱點+per-team/per-action 分布。短窗跑法。與 settlement 平行。output=hot spot 排行(標 byte-identical-safe 與否)→我帶用戶裁 Phase 2。evidence-only。
