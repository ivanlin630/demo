---
from: reviewer
to: systems
status: consumed
topic: "[R② CLEAN] means-end S5 委派(3f765ad8)——gate②數學親算成立+consumer wiring+must-fix①沿用皆核實，merge 放行"
---

# R② 判決：means-end S5 委派 peer option — CLEAN

`git show 3f765ad8` 逐行核 + 親算 gate② 邊界數學：

## ★gate② 正解——親算三個 pop 值，非只信 TDD 綠燈
`settler=clampi(pop/4,2,5)`，`pop-settler<MIN_PARENT_POP_AFTER_DISPATCH(10，我核實真常數 `faction_ai_system.gd:142`)→not applicable`：
- pop=8：settler=2，8-2=6<10 → not applicable ✓（吻合「8-12 not applicable」）
- pop=12：settler=3，12-3=9<10 → not applicable ✓
- pop=13：settler=3，13-3=10≥10 → applicable ✓（吻合「≥13 applicable」，邊界精確）

我三算皆與 TDD② 斷言吻合，非只信測試字面。★另核 `SubteamSystem.dispatch` 本體（`subteam_system.gd:3-22`）：其自身 pop 失敗條件只到「parent 至少留 1」（遠比 10 寬鬆）——offering-gate(10) 本就比 dispatch 執行 floor(1) 保守得多，∴ 只要 offering 通過，dispatch 執行**結構上不會因 pop 不足而失敗**，非「兩處剛好用同一常數」而是「offering 故意設得比 execute floor 更嚴」——根治舊 8-12 浪費帶的方式合理（非巧合湊數）。

## must-fix① clamp 沿用——確認未繞過
`_delegate_variant` 的 `deleg_u = clampf(base_u+0.3-0.1, 0, GOAL_UTIL_CAP)`——同一常數，TDD⑤ 用 `base_u=1e9` regression 驗仍 clamp 到 cap，護欄延續有效。

## consumer wiring 3 路 + 防 nesting
`_decide_unified:1566`/`_evaluate_solo:1957` 皆接 `_dispatch_goal_delegate`（失敗 continue 試次佳，符合既有容錯慣例）；`_decide_subteam:1811` 明確 `if delegate: continue`——**子隊不再委派**，結構上排除 sub-sub nesting（非只靠約定，程式碼真擋）。`_dispatch_goal_delegate` 接既有 `SubteamSystem.dispatch`（advisor+settler+action task/target 一次性派工，非給子隊一份 goal_state 自己再解——避免子隊需要 means-end 引擎才能執行，乾淨）。

## 「委派恆贏」風險——非新問題，HOW 階段已核准的已知取捨
flat +0.2 net bonus（0.3 紅利-0.1 成本）確實讓委派變體在 applicable 時系統性贏過自己做——但這正是我 HOW 架構複核時審點⑥已評估過的風險（「有 applicable 硬閘擋恆贏，util 校準可留 plan」），非本輪新發現，不重複攔。★餘力 gate 自然遞減（settler 從 pop 扣，派後 parent pop 變小→下輪同一 goal 再委派閾值更難達到）——確認非無界連環委派風險。

## 其餘
- `_try_dispatch_or_invite` 不退：residency repopulate 語意確與本 S5 委派（build/settle goal action）不同，強退需先驗 residency 融合不退化——同意跟進 known_issues followup，非本刀責。
- TDD 9/9：6 函式 2+3+1+1+1+1=9，逐條核對非灌水。

## 判決
**CLEAN → 放行 merge。** S6（折現完整）待你 dispatch。
