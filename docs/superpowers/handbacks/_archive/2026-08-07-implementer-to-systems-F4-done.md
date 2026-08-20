---
from: implementer
to: systems
status: consumed
topic: "[F4 統一註冊表 DONE·②結構 operational byte-identical·feat/framework-F4 commit e30b3208]INV-1 表2 AFFINITY(24 opt)折入 REGISTRY[opt].affinity(買料/遷移找糧顯式 UNIFORM 保序、affinity_of 讀 REGISTRY)。INV-2/2b fork=b:6 OPTION_SET 折入 REGISTRY[opt].sets、刪 6 舊 const array 單源、加 is_in_set(REGISTRY.has guard+sets.get)+options_in_set(插入序 filter)。INV-3 terms 零改。INV-4 lambda 零改。caller 全更新 exhaustive(F2 教訓):production 11(decision_engine×6+options×3+faction_ai:4562+decision_context:404 STAKES 迭代)+debug/test 11→is_in_set/options_in_set。★★命門:fp 對 ce201650 27/27 byte-identical(diff=0、含 STAKES 序)。驗:framework_f4_test 3/3(INV-1/INV-2+guard+STAKES 序/§3 加 mock option 動一處 operational)+constitution 75+headless 0-new(accessor 全 caller 無 Invalid-call)+determinism 天然保持。★誠實邊界:註冊動一處;行為碰決策核=Track②A backlog。★follow-up:遷移找糧∈survival 卻 uniform=behavior slice。請 R²(核 INV-1~4+fork(b)全 caller 無漏+fp byte-identical 含 STAKES 序)→QA 親 diff→merge=F4 收②operational→回玩法。"
branch: feat/framework-F4
commit: e30b3208
---

# F4 統一註冊表 DONE（②結構 operational、byte-identical）

feat/framework-F4 commit `e30b3208`（已 push、pre-push constitution PASS 75）。②「可擴充」operational 示範＝加東西動一處。★純結構搬移零行為變。

## §HOW-binding（全守）
| INV | 實作 |
|---|---|
| **INV-1**（AFFINITY 折入保序） | 表2 AFFINITY（24 opt 需求層）折入 `REGISTRY[opt].affinity`；**買料/遷移找糧顯式 `[0.2×5]` UNIFORM**（保序非訂正）；`affinity_of` 改讀 REGISTRY（非-REGISTRY→`_AFFINITY_UNIFORM` 保留、`main_layer_of` 自動繼承）。刪 AFFINITY 表。 |
| **INV-2 + INV-2b（fork=b）** | 6 OPTION_SET（survival/passive_survival/threat/ambient/strategic_selfinit/stakes）折入 `REGISTRY[opt].sets` flags；**刪 6 舊 const array**、單源 REGISTRY；加 2 accessor `DecisionOptions.is_in_set`（`REGISTRY.has` guard + `sets.get(name,false)`）+ `options_in_set`（REGISTRY **插入序** filter）。 |
| **INV-3** | `terms.gd` + REGISTRY `terms` 欄零改（term 異軸不折入）。 |
| **INV-4** | applicable/to_task lambda 本體零改（含內嵌 Probe.bump 原位）。 |

## caller 全更新 exhaustive（F2 教訓、無漏）
- **production 11**：`decision_engine`:75/81/138/171/203/228 + `options`(內) 431/445/447 + `faction_ai_system`:4562 + `decision_context`:404（STAKES 迭代→`options_in_set("stakes")`）。
- **debug/test 11**：`buyfood_measure`:88 + `headless_test`×7(4833/5783/6512/6709/9984/11146/13069) + `starvation_lockpoint_trace_bed`:23 + `survival_layer_unify_test`:137 + `survival_prio_fix_test`:67 → `is_in_set`/`options_in_set`。
- comment-only：無 code 改。★依賴 need_hierarchy/engine/context → DecisionOptions.REGISTRY 單向零環。

## 驗（全綠）
| 閘 | 結果 |
|---|---|
| `framework_f4_test` | **3/3 PASS**（INV-1 affinity 讀 REGISTRY[覓食 值/買料+空 UNIFORM] / INV-2 is_in_set+guard+options_in_set STAKES 序 / **§3 加 mock option 到 REGISTRY 單一 entry → affinity+sets+iter 全反映=動一處 operational**） |
| ★★**fp 對 ce201650** | **27/27 byte-identical、diff=0**（含 STAKES 迭代序 fp）＝純移零行為變命門證 |
| constitution_gate | **PASS sites=75**（折入=資料搬非新 gate） |
| headless | **0-new**（affinity_of/is_in_set 全 caller 無 Invalid-call、affinity 斷言過） |
| determinism | 天然保持（fp byte-identical to 3-run-stable ce201650） |

## ★誠實邊界 + follow-up（呈你）
- **誠實邊界**：本 slice 證「**註冊**部分=加 option 動一處」（affinity/sets/set-iter 皆單源 REGISTRY）；但新 option 的**行為若與決策核互動**（applicable/to_task 呼 faction_ai helper）仍需碰 faction_ai = full no-god-object 未達 = **Track②A incremental backlog**。
- **follow-up（另 slice、非本批）**：遷移找糧 ∈ survival set 卻 uniform affinity（疑該 survival-heavy）= behavior slice（fp-分化-intended）→ measurer/blueprint 定。

## 路
1. **你 R²**（核：INV-1~4 + fork(b) 全 caller 無漏 + fp byte-identical 27/27 含 STAKES 序 + 依賴無環）。
2. → QA 親 diff → merge = F4 收（②operational）→ 回玩法 / Track②A backlog。

地基 KEEP。（F2 disk flag 仍待 systems prune ~115 stale worktrees。）
