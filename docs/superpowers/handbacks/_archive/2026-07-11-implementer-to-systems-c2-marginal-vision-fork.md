---
from: implementer
to: systems
status: consumed
topic: [C2 mechanically 對但 marginal → 決策樹 vision fork] 整併 survival-rank 罕勝(2.5%)，join 蓋同 niche
---

# C2 done：機制正確，但 volume marginal → trending 決策樹「≈0/marginal → 願景 fork 升 user」

C2 五改全上（@34034bb）+ 驗綠（bed fail=0/sanity inv=0/constitution/determinism IDENTICAL）。**機制證實正確**：priority 覆寫解了（`mv_reached` 0→1）。但 **merge_accept 仍 0，volume marginal**。

## 完整 C2 漏斗（seed 1337 3mo）
| 站 | 數 | 判讀 |
|---|---|---|
| `merge_appl.food_lt3` | 772 | 絕境隊有 target（母體） |
| `merge.surv_ok` / `surv_fail` | 9 / 10 | ★`_trigger_survival` 選整併僅 **19/772 = 2.5%**——整併罕勝 survival rank |
| `merge.mv_reached` | **1** | ★priority 覆寫**已解**（C1 時=0，C2 整併 persist 到 movement） |
| `merge.pair_seen` → accept | 0 → 0 | 那 1 隊沒到達 absorber |
| （對照）`join.resolve`/`consol.accept_n` | 1 / 1 | 投靠正常運作 |

## 判讀（C2 正確但世界結構抗拒）
1. **C2 機制對**：整併升 survival-class 後，`mv_reached` 0→1 = 不再被 survival-sticky 覆寫（真根 C 解）。order_target survival-路接線 + A re-track + combat 豁免全生效。
2. **但整併罕勝 survival rank（2.5%）**：772 絕境隊只 19 次選整併。**投靠(join) 蓋同 niche**（絕境併入強隊）且常勝——join weight(義氣/信義/求生欲×low-ambition) 與 consolidate weight(求生欲/1-野心) 近似，applicable 域重疊（都 food<3+target）。**join/整併語意重疊**（我 C1 報告已 flag）。
3. **9 set 只 1 到 movement**：survival 每 tick 重評，整併 task churn（下 tick 可能改選投靠/覓食）。
4. ∴ **整併作為獨立機制 marginal**——join 已填「絕境併」需求，整併(整隊池化)冗餘。

## → 決策樹（systems/blueprint，你工單定的）
你 C2 工單決策樹：「C2 產真聚合→signoff；C2 也≈0/marginal → **真願景 fork 升 user**（小-絕境隊世界結構抗拒 consolidation）」。**現在 = marginal 支**。

**建議兩步**：
1. **先 measurer big-window 確認**（你工單提的 detach+resume tooling / WARRING_RESUME）：3mo 單 seed volume 小，big-window 確認 marginal 是結構非樣本。若 big-window 仍 2.5% survival-rank + merge_accept≈0 → 結構確認。
2. **確認後升 user 願景 fork**（我不能單方裁）：核心問題 = **世界需不需要「整隊池化(整併)」獨立於「投靠(join)」？** join 已=絕境個人/全隊併入強隊。整併(全池化合併)在絕境域與 join 重疊、罕勝、churn。選項：
   - (a) **整併退役/併入 join**：承認 join 已填絕境併 niche，S-A 整併機制不獨立（join = the 絕境併 primitive）。
   - (b) **整併差異化**：若整隊池化須語意獨立（如保留隊 identity/faction 結構），需給整併 rank 優勢或不同觸發（非絕境域，但 C1 證非絕境域沒隊）→ 回到兩難。
   - (c) **接受 marginal**：整併=罕見 flavor 事件（偶發整隊抱團），不強求 volume。

## 現況
- worktree @34034bb：S-A term/餵養/accept-util/cadence + 三 movement 修 + C2 survival-class + 完整 6 層 merge 漏斗探針。gates/determinism 綠。
- **探針齊**：measurer big-window 可逐站驗（food_lt3→surv_ok→mv_reached→pair_seen→accept + gate#1 非搬餓）。

框外總結（6 層扒到底）：order_target(已wired)→combat早退→movement A/居民鎖→priority mv_reached=0→C1食壓分布(eligible絕境)→**C2正確但 join 蓋 niche→marginal**。真根鏈完整。**這站是願景問題（join/整併關係），非再一個 code 修**——建議 big-window 確認後升 user。
