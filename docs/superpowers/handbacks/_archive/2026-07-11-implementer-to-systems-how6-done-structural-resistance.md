---
from: implementer
to: systems
status: consumed
topic: [§HOW-6 done, funnel 仍~0] 統一併入實作完整但 consolidation 結構性 marginal → 決策樹升 user 願景 fork
---

# §HOW-6 統一「併入」實作完整 + 驗綠，但 funnel 仍 ~0——世界結構抗拒 consolidation

§HOW-6 三改全上（@32bc09b）+ 驗全綠（parse/bed fail=0/multi-sanity inv=0/constitution/determinism IDENTICAL + can_reach guard 修 subteam 路 dangling ref）。**功能正確**。但 organic funnel 仍近 0。

## §HOW-6 做了什麼
1. **統一「併入」**：投靠+整併兩 option → 一個「併入」（REGISTRY/SURVIVAL_SET/applicable/to_task）。絕境+surplus host(gate#1)、TASK_JOIN+movement A re-track、weight=求生欲/(1-野心)。
2. **分流**（resolver）：accept 後 人少+好感高+低凝聚→dissolve(merge_teams)；否則整隊變子隊(set_subteam_parent+set_team_faction)。
3. **起始 loyalty**=f(好感,義氣)。
4. 死碼清（consolidate_drive/整併 row/TASK_MERGE 路）。

## funnel 仍 ~0（seed 1337 3mo，跨 weight 變體）
| 變體 | surv_ok | join.resolve | mergein.dissolve/subteam | merge 完成 |
|---|---|---|---|---|
| C2 整併(consolidate weight) | 9 | — | — | 0 到達 |
| §HOW-6 join-reuse weight | 0/39 | 0 | 0/0 | 0 |
| §HOW-6 mergein weight(spec) | 0/1 | 0 | 0/0 | 0 |

- **無論 weight/path/option 名，consolidation completion≈0**。5 層修（order_target/combat豁免/movement A/居民鎖/priority C1-C2）+ 統一併入 + 3 weight 變體全試遍。
- 分流兩端 dissolve/subteam **都 0**（對稱空窗守衛：INCONCLUSIVE，但根因非門檻——是上游沒隊到達 resolver）。
- surv try_set 近 0 succeed：併入@PRIO_SURVIVAL 無法 preempt 既有 survival task@80（try_set :42 需嚴格 >，equal fail）——survival-class 內部 self-replace 缺口 + 到達 churn。

## 判讀（決策樹 marginal 支，鐵證）
systems C2 決策樹：「C2 產真聚合→signoff；≈0/marginal → **真願景 fork 升 user**（小-絕境隊世界結構抗拒 consolidation）」。**6 層 + 統一併入後仍 ~0 = 結構性抗拒確認**：
- 絕境小隊（eligible 98.6% food<3）
- survival-class 內多 option 競秤 + sticky（首選 commit，併入罕首選 or 無法 preempt）
- 到達 churn（多日行軍途中 survival 重評棄 task）
- 分流路（子隊-attach）暴露 subteam 骨架 dangling（已 guard，但示外來附庸=S-B territory）

## → 建議（升 user 願景 fork，我不能單方裁）
1. **先 measurer big-window 確認**（03b detach+resume SOP / WARRING_RESUME，非 3mo 單 seed）——排除樣本量。若 big-window 仍 completion≈0 → 結構確認。
2. **確認後 user 願景 fork**：**世界結構下 team consolidation 本質罕見。核心問題升 user**：
   - (a) **接受 consolidation ≈ 罕見 flavor**（偶發抱團，不強求 volume；S-A 機制備著、湧現多寡隨世界）。
   - (b) **改世界動力**（讓小隊在絕境前有中度餓窗停留、或降 survival option 競爭）——大改，可能傷其他平衡。
   - (c) **consolidation 非此世界的 emergent 行為**（小-絕境隊結構天生抗拒抱團）——退役 S-A consolidation 野望，join 個人投靠已夠。

## 現況
- worktree @32bc09b：§HOW-1~6 全 + 三 movement 修 + 統一併入 + 分流 + loyalty + guard + 完整 merge 漏斗探針（6 站）。gates/determinism 綠。
- **實作無 bug**（功能正確、驗綠），blocker 是**世界結構**非 code。探針齊供 big-window + user 決策。

框外總結（7 層扒到底 + 統一）：order_target→combat早退→movement A/居民鎖→priority C1(食壓分布)/C2(survival-class)→統一併入(weight 變體)。**每層都真修真 bug，但頂層是願景**：這世界的小-絕境隊結構抗拒 consolidation。建議 big-window 確認 → 升 user 裁 (a)/(b)/(c)。
