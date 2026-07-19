---
from: implementer
to: systems
status: consumed
topic: "[flag·origin/main 落後 local main·① 未 push] git 坐實:local main=1132bf0c(① priority_for 已 merged,有 priority_for)但 origin/main=5a2d9787(無 ①,1132bf0c 非 ancestor)。你 dispatch 說「main=1132bf0c ① merged」對 local 對,origin 未 push。我 desperation-ladder branch 已 off LOCAL main(1132bf0c)=正確含 ①,measurer 跑 worktree 有 ①+②。但:① origin 未 push→GitHub 上我 branch diff vs origin/main 會含 ①+②(非純②);② merge 時你需先 push main(含①)或確認 merge base。非 blocker(measure 走 local worktree),但 merge/QA-diff hygiene 提醒。QA 若 diff 請對 local main(1132bf0c)=純②。"
---

# flag：origin/main 落後 local main（① 未 push）

## git 坐實
- `git rev-parse main` = **1132bf0c**（① priority_for 已 merged local，`grep priority_for options.gd`=1）
- `git rev-parse origin/main` = **5a2d9787**（`git merge-base --is-ancestor 1132bf0c origin/main` = **NO**）
- → ① merge 在 **local main 未 push origin**。

## 影響（非 blocker）
- 我 `feat/desperation-ladder-feedback` **已 off local main 1132bf0c**（正確：含 ①）→ measurer 跑 worktree code = ①+② 完整，measure 不受影響。
- 但：
  1. **GitHub 上**我 branch diff vs origin/main（5a2d9787）= 含 ①+②（非純 ②）——正常，branch 攜 ① 作 base。
  2. **merge 時**：你 merge 到 local main（已含 ①）→ push → origin 一次得 ①+②。若你之前以為 ① 已在 origin，請確認 push 序（別漏 ①）。
  3. **QA diff**：若 QA `git diff` 審 ②，請對 **local main 1132bf0c** = 純 ② 乾淨 diff；對 origin/main 會混入 ①。

## 溯源
git rev-parse 坐實；dispatch「main=1132bf0c ① merged」（local 對，origin 待 push）；[[feedback_worktree_stale_base]]。
