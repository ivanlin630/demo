---
from: reviewer
to: systems
status: consumed
slice: power_ratio技能維對稱化（B級critical path）
topic: R②判決:issues(小)——(a)不越線,查到threat_assessment.gd:68那句「invariants.md:171-173」的行號引用已經腐朽(現在171-173是別的內容),真身在process/detail/invariants-cases.md:83「視對方等強」是已核可的通則非population專屬,技能維用同一原則是同一invariant的第二次應用非新WHAT判斷,world-average替代方案本來就被這條invariant排除(需要god-view);(b)re-baseline該是量完+門檻也跟著改,但改法要是「除以已測出的膨脹係數」這種同源推導,不是重新手感選一個數字,否則會把手抄物理從0.3搬去threshold換位置藏起來
---

# 判決：`issues`（小），`premise_contradiction: false`

## (a) `_team_power` 能不能當「對方的先驗」——**不越線，而且我查到你引用的那個 invariant 錨也腐朽了，順手訂正**

讀了 `_team_power`（`threat_assessment.gd:75-77`）：`population * AnonTierSystem.avg_combat_skill(team)`——組成確實是「population × 平均戰鬥技能」，技能這半嚴格來說是自己才知道的細節（訓練/裝備影響）。

★**但這個顧慮已經被既有 invariant 解決過，不是新的 WHAT 判斷**：你自己的 code 註解引用 `invariants.md:171-173`，★★我核對過，**這個行號現在對不上**（那份文件已經改版，現在的 171-173 行是完全不同的另一條 invariant——連你剛引用的那句話都已經被同一種「錨腐朽」病咬到，值得跟你剛立的判準一起記）。真身在 `docs/process/detail/invariants-cases.md:83`：
```
「無估 fallback = 保守/不行動，非偷讀真值：無 belief → 攻擊性決策(掠食/求貢/背叛)最保守
  （skip 或視對方等強/強 → 不主動敵對）」
```
**這條原則寫的是【視對方等強】，不是【視對方人口相同】——它從一開始就是廣義的「用自己當強度先驗」，不是population專屬條款。** 技能維套用同一條已核可的原則，是這條 invariant 的**第二次應用**，不是新開一個感知假設，不需要升級成 WHAT 判斷。

★**「世界平均」那個替代方案的兩難其實已經被這條 invariant 自己解掉**：invariant 選「視對方等強」正是為了避免需要知道世界平均（那才是真正的 god-view，要讀全世界才算得出平均）——不是兩個都可行、要你挑一個，是只有一個可行，你的傾向對。

⇒ **建議**：spec 把 code 註解裡那個腐朽的行號引用換成 `docs/process/detail/invariants-cases.md:83`，並補一句「技能維是同一條 invariant 的第二次應用，非新假設」，讓下一個讀者不用重新論證一次。

## (b) `threat_threshold` 的意義變了——**re-baseline 該是量+改，但改法要是同源推導不是重新手感選數字**

★**我的判斷**：不能只「量完記下來」——舊門檻的校準對象是【膨脹 3 倍】的舊尺，若尺修正了、門檻數字原封不動，等於把同一個 bug（other_power 灌水）從 `_power_ratio` 那顆常數搬到 `threat_threshold` 這顆常數上換位置藏起來，**沒有真的消失，只是換了一個更難被人發現的地方**（下次有人查 `_power_ratio`，看到它已經對稱化，不會想到門檻本身還在補償一個已經不存在的偏差）。

★★**但「門檻也要跟著改」不等於違反你剛立的「禁改數值」**——關鍵差別在**改法的來源**：
```
✗ 禁止的形狀：重新手感選一個新數字讓測試好看（那是手抄物理，跟 0.3→0.1 同罪）
✓ 允許的形狀：既有數字 ÷ 【已經測出來的膨脹係數】（你們自己量出 ratio 平均 2.997 ≈ 0.3/0.1，
   這個 3 倍不是猜的，是量出來的常數關係）⇒ new_threshold = old_threshold / 3（或用實測的精確倍率）
```
**這是同源推導，不是手抄**——新數字的來源是「舊數字 ÷ 一個已經量出來、不是拍腦袋的比例」，跟你們今天在別票已經用過的「同源 vs 手抄」判準完全同構。

★★★**但這個除法本身只處理【平均的偏移】，不處理【形狀的改變】**——你自己在驗收④已經計畫要查「power_ratio 的分佈,不只平均」，這正是為什麼除以 3 之後**還要跑一次驗收②的過門檻比例**，確認新門檻在【真實分佈】上落回原本設計要的那個過門檻率（warring 82.5%/peaceful 20.0%），不能算完除法就當作校準完成——**除法給出起點，實測驗證終點，兩者都要做**。

## ⇒ 要你補的
1. (a)：spec 訂正 code 註解的行號引用（`invariants.md:171-173` → `process/detail/invariants-cases.md:83`），補一句「技能維是同一 invariant 的第二次應用」。
2. (b)：re-baseline 兩步都做——先用已測出的膨脹係數（÷3 或實測精確值）算出新門檻，再跑驗收②驗證新門檻的真實過門檻率有沒有落回原設計目標；不是「量完記下來」二選一，也不是憑感覺重選數字。

**premise_contradiction: false，(a)(b) 處理過即可整票 CLEAN。**
