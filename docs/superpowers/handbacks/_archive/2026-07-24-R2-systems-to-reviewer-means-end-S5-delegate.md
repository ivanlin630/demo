---
from: systems
to: reviewer
status: consumed
topic: "[R②·means-end S5 委派 peer option·★gate②正解(known_issues DEFER 項根治)·委派變體進 rank 池+consumer 3 路 wiring+子隊不再委派避 nesting·systems 收驗 PASS·branch feat/means-end-s5-delegate 3f765ad8] S5=委派 peer option。systems 收驗(git diff,留 main dir):★1.★★gate②正解(_delegate_variant):委派變體 applicable=pop−settler(clampi pop/4,2,5)≥MIN_PARENT_POP_AFTER_DISPATCH(10)=真 viability,★attempt=dispatch guard 同源→pop 8-12 無委派變體(不浪費)/pop≥13 有=known_issues gate② DEFER 項此處根治(TDD 9/9 驗)。★2.委派變體(build/settle 型:util=base+DELEGATE_MULTILINE_BONUS 0.3−DELEGATE_COST 0.1 clamp GOAL_UTIL_CAP=must-fix① 護欄沿用<survival;label:delegate 有界;settler 配額)。★3.consumer wiring 3 路(_decide_unified:1566/_evaluate_solo:1957 delegate→_dispatch_goal_delegate 派子隊+承諾追蹤+失敗試次佳;★_decide_subteam:1811 delegate→continue=子隊不再委派避 sub-sub nesting);_dispatch_goal_delegate:2801 接既有 SubteamSystem.dispatch(advisor+settler+action task/target)。★4.餘力 gate(settler 從 pop 扣,派後 pop 遞減→餘力 gate 自然擋 over-delegate=多線配額 WHAT §4)。★5.gate 74 removed=0(委派讀狀態非 god-view/零 randf)/determinism 0efd2191 2 跑一致/headless 0-new。★_try_dispatch_or_invite(residency repopulate owned outpost 手評)不退=implementer 判 residency 語意不同(≠S5 新 build/settle 委派),我接受(退役需驗融合 residency 不退化)→標 known_issues followup(residency 手評收進委派 option=後續 arc,means-end 委派進引擎但 residency 仍手評=憲法債殘)。★reviewer focus:gate②正解對否(viability 真 guard attempt=dispatch 同源)?委派 util base+0.2 但 pop-guard 餘力 gate 遞減擋 over-delegate=無委派恆贏失控否?consumer 3 路+子隊不再委派避 nesting 對否?_try_dispatch_or_invite 不退 followup 判斷接受否?must-fix① clamp 沿用無破否?CLEAN→我 merge S5→dispatch S6(折現完整:投資型 util=payoff×折現(延遲,人格折現率),絕境不走遠路)。有洞→回 to:systems。"
branch: feat/means-end-s5-delegate
---

# R②：means-end S5 委派 peer option（gate② 正解）

S5 = 委派 peer option。systems 收驗（git diff，留 main dir）。

## systems 收驗（5 點）
1. ★★**gate② 正解**（`_delegate_variant`）：委派變體 applicable = `pop − settler(clampi pop/4,2,5) ≥ MIN_PARENT_POP_AFTER_DISPATCH(10)` ＝ **真 viability**，★attempt=dispatch guard **同源** → pop 8-12 無委派變體（不浪費）/ pop≥13 有 ＝ **known_issues gate② DEFER 項此處根治**（TDD 9/9 驗）。
2. **委派變體**（build/settle 型）：util = `base + DELEGATE_MULTILINE_BONUS(0.3) − DELEGATE_COST(0.1)` clamp `GOAL_UTIL_CAP` ＝ **must-fix① 護欄沿用 < survival**；`label:delegate` 有界；settler 配額。
3. **consumer wiring 3 路**：`_decide_unified:1566` / `_evaluate_solo:1957` delegate → `_dispatch_goal_delegate` 派子隊 + 承諾追蹤 + 失敗試次佳；★`_decide_subteam:1811` delegate → continue ＝ **子隊不再委派避 sub-sub nesting**；`_dispatch_goal_delegate:2801` 接既有 `SubteamSystem.dispatch`。
4. **餘力 gate**：settler 從 pop 扣，派後 pop 遞減 → 餘力 gate 自然擋 over-delegate ＝ 多線配額（WHAT §4）。
5. **gate 74 removed=0**（委派讀狀態非 god-view / 零 randf）/ determinism `0efd2191` 2 跑一致 / headless 0-new。

## _try_dispatch_or_invite 不退（implementer 判，我接受 → known_issues followup）
residency repopulate owned outpost 手評 ≠ S5 新 build/settle 委派，語意不同，退役需驗融合（residency 不退化）→ 標 followup（residency 手評收進委派 option ＝ 後續；means-end 委派已進引擎但 residency 仍手評 ＝ 憲法債殘）。

## ★reviewer focus
- gate② 正解對否（viability 真 guard，attempt=dispatch 同源）？
- 委派 util base+0.2 但 pop-guard 餘力 gate 遞減擋 over-delegate ＝ 無委派恆贏失控否？
- consumer 3 路 + 子隊不再委派避 nesting 對否？
- `_try_dispatch_or_invite` 不退 followup 判斷接受否？must-fix① clamp 沿用無破否？

**CLEAN → 我 merge S5 → dispatch S6**（折現完整：投資型 util = payoff × 折現(延遲, 人格折現率)，絕境不走遠路）。有洞 → 回 `to:systems`。
