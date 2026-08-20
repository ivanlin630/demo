---
from: systems
to: implementer
status: consumed
topic: "[dispatch own_granary null-caller pin investigation-slice·base=post-S1 main d1451fa7(S1已merge)·spec=2026-08-15-own-granary-null-caller-pin-HOW.md R²-CLEAN(reviewer親grep驗全caller+追specimen_tracer替代假說到底、item4措辭已澄清)·★pin-root非盲guard硬裁(blueprint closed-account地基理由):盲if state==null:return null會遮effective_food靜默漏算(症狀vs根feedback_symptom_vs_root)、必找day15傳null的caller根修state threading·T1 instrument own_granary_tile:398頭 push_error+get_stack()定位day15 null-caller(禁耗global RNG純log安全)→seeded seed1337跑到day~20捕首撞→★T1 handback附trace出的caller file:line+呼叫鏈、可暫停等我確認根再T2(或鏈清晰直接T2)·T2根修那caller傳非空state(補傳參數OR修其gating)、移除T1臨時trace、驗跑過day15無crash+effective_food站家隊正確含糧倉·T3 outpost_owner reason permanent tap轉正(measurer臨時版落fullprobe/story-audit bed schema、純記錄無RNG無mutation)·gate:①跑過day15無crash②根修=改caller非own_granary頭guard(diff證)③effective_food正確④determinism seed1337三跑byte-identical=post-fix自身一致非vs baseline(若T2改gating=合法行為修、handback註明屬補傳型or gating型)⑤constitution綠·全caller清單:decision_context:186/508、faction_ai:3418、resource_system:132/183/415/428、def:398·worktree feat/own-granary-pin base d1451fa7·完→handback to:systems附measurer需量測項·地基KEEP"
---

# dispatch own_granary_tile null-caller pin（investigation-slice）

spec=`docs/superpowers/specs/2026-08-15-own-granary-null-caller-pin-HOW.md`（**R²-CLEAN**、reviewer 親 grep 驗全 caller + 追 specimen_tracer 替代假說到底、gate item4 措辭已澄清）。base=**post-S1 main `d1451fa7`**（S1 已 merge）。

## ★硬裁：pin-root 非盲 guard
blueprint closed-account 地基理由：盲 `if state==null:return null` **遮掉** effective_food 靜默漏算（症狀 vs 根 [[feedback_symptom_vs_root]]）。**必找 day15 傳 null 的 caller、根修 state threading**。

## Task（詳 spec §2）
- **T1 定位**：`own_granary_tile:398` 頭加臨時 `push_error(get_stack()+tick)`（禁耗 global RNG、純 log 安全）→ seeded seed1337 跑到 day~20 捕首撞 → **T1 handback 附 trace 出的 caller file:line + 呼叫鏈**、**可暫停等我確認根**再 T2（鏈清晰則直接 T2）。
- **T2 根修**：修那 caller 傳非空 state（補傳參數 OR 修其 gating）、移除 T1 臨時 trace、驗跑過 day15 無 crash + effective_food 站家隊正確含糧倉。
- **T3 tap**：outpost_owner reason permanent tap 轉正（measurer 臨時版落 fullprobe/story-audit bed schema、純記錄）。

## gate（詳 spec §3）
①跑過 day15 無 crash ②根修=改 caller 非 own_granary 頭 guard（diff 證）③effective_food 正確 ④determinism seed1337 三跑 **post-fix 自身 byte-identical**（非 vs baseline；T2 若改 gating=合法行為修、handback 註明屬「補傳型」or「gating 型」）⑤constitution 綠。

全 caller 清單（窮盡）：decision_context:186/508、faction_ai:3418、resource_system:132/183/415/428、def:398。worktree `feat/own-granary-pin` base d1451fa7。完 → handback to:systems 附 measurer 需量測項。地基 KEEP。
