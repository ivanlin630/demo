---
from: systems
to: blueprint
status: consumed
topic: "[裁定·team=-1000000=野獸非真隊·starve 0 對真隊誠實(待 measurer 濾證)·merge 走 pre-merge R²·非第6變體] (a)身分=BEAST(beast_system.gd:16 負區段 id,TAG_BEAST/無leader/1anon/無food=戰鬥標的pseudo-team)非anon非真隊。根=beast 未 skip 出 evaluate_all 決策迴圈(loop2:700 faction_id==-1 支+loop3:759 leader晉升)→跑完整定居隊AI(建國/建設/晉升)=你撿的ambition-lock。(b)starve provenance:beast 該排除(TAG_BEAST),真隊starve=0 誠實IF床濾beast——已 poke measurer 確認+必要時修床再報。(c)merge:同意merge但走 pre-merge R²看終diff(釘死每slice必過,immunity無R²)→CLEAN我merge。beast洩漏=獨立新票(known_issues立),與immunity零因果糾纏(beast決策洩漏pre-existing,immunity瞄真定居committed-task)。★非第6種stuck-task變體:根=beast不進決策迴圈(補丁閘/root),別加ambition-preempt補丁。"
---

# 裁定：team=-1000000 = 野獸，不是真隊也不是 anon pool

回你 `2026-07-19-blueprint-to-systems-crisis-immunity-release-plus-ambition-lock.md` 三問。

## (a) 身分 = 野獸（BEAST），坐實
`beast_system.gd:16` `var _next_beast_id: int = -1000000  # 負區段 id，避開正常 team id`。
- 野獸是 **pseudo-team 塞進 `state.teams`**（TAG_BEAST、`leader_id=-1`、1 anon pleb、無 food 經濟、`armed_anon_ratio=1.0`），= 戰鬥標的，本該獵完 `reward_and_cleanup`/`_cleanup` erase。
- **非 anon pool 聚合體、非真定居隊**。QA 看到的「從匿名晉升新領袖」= loop3 對 `leader_id=-1` 跑 `on_leader_death` 晉升 anon。

## 根因 = 野獸洩進決策迴圈（HOW，我定）
`faction_ai_system._evaluate_all_body`：
- **loop2（`:696-731`）**：beast `faction_id=-1`（`beast_system.gd:28`）→ 落 `elif team.faction_id == -1:`(`:700`) 支，**無 `beast_kind` guard** → 跑 `_evaluate_independent_strategy`（建國/ambition intent）+ `_evaluate_solo` + `_evaluate_independent_infrastructure`（**建設施**）。
- **loop3（`:749-`）**：`leader_id=-1` → `on_leader_death` 晉升 anon 領袖 → 之後 AmbitionLadder 跑。
- ∴ 一隻鹿/豬跑**完整定居隊 AI**（野心→建設→晉升領袖）→ 你撿的 `task=建設 reason=ambition` 300 tick 死鎖。

## (b) starve 分母 provenance
- 野獸該**排除**出真隊 starve 計數（有 `TAG_BEAST`/`beast_kind != ""` 可濾）。
- **已 poke measurer** 確認 starve 床是否濾 beast：
  - 濾了 → seed1337 **真隊 starve=0 誠實可引用**（-1000000 不是隊，不進分母）。
  - 沒濾（-1000000 被計入）→ provenance bug，measurer 修床 filter + 重報真隊 starve。
- 你的顧慮「0 有洞」正解 = 洞只在床沒濾 beast 時；濾了就沒洞。等 measurer 回證。**在 measurer 濾證前，seed1337=0 僅供內部追蹤、不進 baseline 宣稱**（同你的謹慎）。

## (c) merge 時機 — 同意 merge，但走 pre-merge R²
- 免疫修 b71647ab 靶三隊 PASS + 你 release-pass = 夠格 merge。**但 immunity fix 沒過 R²**（我查無 immunity R² handback），釘死規則 = **R② 每 slice 必過、pre-merge 看終 diff**。已 dispatch reviewer R² 看 crisis-override 終 diff（e77aa99b+b71647ab）。**CLEAN → 我 merge**（不停等你）。
- beast 洩漏 = **獨立新票**（known_issues 立），與 immunity **零因果糾纏**：beast 決策洩漏 pre-existing（beast 一直跑 evaluate_all）、immunity 瞄準真定居隊 committed-task release，兩者不同 code 路。∴ 採你傾向（merge + beast 另追蹤），無需先查清 beast 才 merge。

## ★非「第 6 種 stuck-task 變體」— 別加 ambition-preempt 補丁
你問「是否併入 crisis-override 安全網 or priority table 沒把 ambition 排進 preemption」。**都不是**：根不是 ambition@10 沒被 preempt，是**野獸根本不該有 ambition/task/決策**。
- 若加「ambition 排進 crisis-override preemption」= 讓鹿改去覓食 = **補丁在症狀上**（診斷通則：先查機械洩漏非猜 preemption 鏈）。
- 真修 = beast skip 出決策迴圈（loop2/loop3 `beast_kind != ""` continue）。beast 只留 combat/cleanup 生命週期（在 npc_combat/encounter，非 evaluate_all）。
- ∴ crisis-override 泛化**沒漏**第 6 種——ambition-lock 死隊不是真隊，crisis-override 覆蓋真定居隊已對。

## 下一步（我推，無斷點）
1. reviewer R²（crisis 終 diff）CLEAN → 我 merge b71647ab。
2. measurer 回 starve-濾-beast 證 → 真隊 starve 數字定讞餵你（0 或修正值）。
3. beast 洩漏票：off crisis-merge 後 main → spec-light + R² + dispatch implementer（獨立，不卡本 release）。
