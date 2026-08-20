---
from: systems
to: implementer
status: consumed
topic: "[dispatch build F4 統一註冊表(②結構 operational、byte-identical、spec docs/superpowers/specs/2026-08-07-framework-F4-unified-registration-HOW.md LOCKED R² CLEAN 終判)·新 slice feat/framework-F4 off 更新後 main(9727304f、含 F0/F1/F2/F3)·折 option-keyed 散資料(表2 AFFINITY+表4 6×OPTION_SET)進 REGISTRY 單一 entry.{affinity,sets}·★★§HOW-binding 寫死必守(byte-identical 保序):INV-1 每 entry.affinity=現行 AFFINITY.get(opt,_AFFINITY_UNIFORM)、買料/遷移找糧顯式 UNIFORM(保序非訂正禁給語意值=行為變)、affinity_of 保非-REGISTRY→UNIFORM;INV-2 6 set 折 sets flags=現行(opt in SET)、INV-2b fork=(b)刪 6 const array 單源 REGISTRY.sets+2 accessor(is_in_set(opt,name)=REGISTRY.has guard+sets.get(name,false)、options_in_set(name)=REGISTRY 插入序 filter);INV-3 terms.gd 零改不折入(term 異軸);INV-4 applicable/to_task lambda 本體零改含內嵌 Probe.bump 逐條原位·★full caller enum 全改(否則 Invalid-call 炸):production 11(decision_engine:75/81/138/171/203/228+options:396/410/412+faction_ai:4562+decision_context:404 STAKES 迭代→options_in_set('stakes'))+debug/test 11(buyfood_measure:88+headless_test:4833/5783/6512/6709/9984/11146/13069+starvation_lockpoint_trace_bed:23 迭代+survival_layer_unify_test:137+survival_prio_fix_test:67)+comment-only 7 無 code 改·accessor 統一置 DecisionOptions、跨檔改 DecisionOptions.is_in_set(依賴 decision_engine/context→DecisionOptions 單向零環)·★擴充性稽核:加 mock 域 option machine-assert 只動一註冊處=硬綠②operational·★★驗收 byte-identical:跑 state_fingerprint_bed 對 ce201650 baseline 27/27 byte-identical(diff=0、含 STAKES 序 fp 確認)+constitution 綠(折入=資料搬非新 gate)+headless 0-new(全 accessor caller 無 Invalid-call、affinity_of/is_in_set 斷言過)+determinism 3-run byte-identical·完成 handback to:systems R²(merge-gate 核 INV-1~4+fork(b)全 caller 改無漏+fp byte-identical 含 STAKES 序)→QA 親 diff→merge=F4 收②operational→回玩法·★follow-up 非本批:遷移找糧∈SURVIVAL_SET 卻 uniform affinity=behavior slice·地基 KEEP"
---

# dispatch build F4 統一註冊表（②結構 operational、byte-identical）

spec：`docs/superpowers/specs/2026-08-07-framework-F4-unified-registration-HOW.md`（LOCKED、R² CLEAN 終判）。新 slice `feat/framework-F4` off 更新後 main（`9727304f`、含 F0/F1/F2/F3）。

折 option-keyed 散資料（表2 AFFINITY + 表4 6×OPTION_SET）進 REGISTRY 單一 entry `.{affinity, sets}`。

## ★★§HOW-binding（寫死必守、byte-identical 保序）
- **INV-1**：entry.affinity = 現行 `AFFINITY.get(opt, _AFFINITY_UNIFORM)`；買料/遷移找糧**顯式 UNIFORM**（保序、禁給語意值=行為變）；affinity_of 保非-REGISTRY→UNIFORM。
- **INV-2 + INV-2b（fork=b）**：6 set 折 `sets` flags = 現行 `(opt in SET)`；**刪 6 個舊 const array**、單源 `REGISTRY.sets`、+ 2 accessor：`is_in_set(opt,name)`（`REGISTRY.has` guard + `sets.get(name,false)`）、`options_in_set(name)`（REGISTRY 插入序 filter）。
- **INV-3**：terms.gd 零改、不折入（term 異軸）。
- **INV-4**：applicable/to_task lambda 本體零改（含內嵌 Probe.bump 逐條原位）。

## ★full caller enum 全改（否則 Invalid-call/Identifier-not-found 炸）
- **production 11**：decision_engine:75/81/138/171/203/228 + options:396/410/412 + `faction_ai:4562` + decision_context:404（STAKES 迭代→`for g in DecisionOptions.options_in_set("stakes")`）。
- **debug/test 11**：buyfood_measure:88 + headless_test:4833/5783/6512/6709/9984/11146/13069 + starvation_lockpoint_trace_bed:23（迭代）+ survival_layer_unify_test:137 + survival_prio_fix_test:67。
- **comment-only 7**：無 code 改。
- accessor 統一置 DecisionOptions、跨檔改 `DecisionOptions.is_in_set(...)`（依賴 decision_engine/context→DecisionOptions 單向零環）。

## ★擴充性稽核（硬綠②operational）
加 mock 域 option、machine-assert 只動一註冊處。誠實邊界：註冊部分解 ≠ no-god-object done（行為互動碰決策核=Track②A backlog）。

## ★★驗收（byte-identical）
- 跑 `state_fingerprint_bed` 對 ce201650 baseline **27/27 byte-identical**（diff=0、含 STAKES 序 fp 確認）。★命門。
- constitution 綠（折入=資料搬非新 gate）+ headless 0-new（全 accessor caller 無 Invalid-call、affinity_of/is_in_set 斷言過）+ determinism 3-run byte-identical。

## 序
完成 → handback `to:systems`（R² merge-gate 核 INV-1~4 + fork(b) 全 caller 改無漏 + fp byte-identical 含 STAKES 序）→ QA 親 diff → merge = F4 收②operational → 回玩法。★follow-up 非本批：遷移找糧∈SURVIVAL_SET 卻 uniform affinity=behavior slice。地基 KEEP。
