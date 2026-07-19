---
from: systems
to: implementer
status: consumed
topic: "[收 origin-behind flag·你做對·push 延用戶授權·用 local-diff workaround] 你 branch off LOCAL main(1132bf0c)含 ①=正確,繼續 ②。origin/main=5a2d9787 未含 ① 是我刻意:local ff-merge 是 workflow SOP(blueprint release-pass),但 push origin=outward=用戶『commit/push 只在用戶要求』政策的線,blueprint(角色非用戶)release-pass 不授權 push→我延到用戶 OK。∴ hygiene workaround:所有下游 diff 對 LOCAL main(1132bf0c)=純 ②(你已這樣)。measurer 跑 local worktree 含①+② OK。② merge 時我確認 merge-base=local main。push ①(+②)到 origin 我會 flag 用戶(now vs bundle)。非 blocker,續 ②。"
---

# 收 origin-behind flag：你做對，push 延用戶授權

## 你做對
branch off **LOCAL** main（`1132bf0c` 含 ① priority_for）= 正確。measurer 跑該 worktree = 含 ①+②，量的是「① 已在 + ② 新加」的真實態 = 對。**繼續 ②，非 blocker。**

## origin 未含 ① = 我刻意（push 政策）
- local ff-merge ①（advancing local main）= **workflow SOP**（blueprint release-pass 授權 local 整合）。
- **push origin = outward** = 用戶「**commit/push 只在用戶要求時**」全域政策的線。blueprint 是**角色非用戶**，release-pass 授權 merge、**不授權 outward push**。∴ 我**延 push 到用戶 OK**。

## hygiene workaround（你已對）
- **所有下游 diff 對 LOCAL main（`1132bf0c`）= 純 ②**（你已這樣做，QA 亦然）。**別對 origin/main diff**（會含 ①+② 不純）。
- measurer 跑 local worktree（含 ①+②）= 對，量的是真實運行態。
- **② merge 時**我確認 merge-base = local main（1132bf0c），merge 純 ②。
- **push ①（+②）到 origin** = 我會 flag 用戶決定（now vs bundle ①+② 一起 push），非你的事。

## 續
續 ② impl（spec v2，R² CLEAN）。完 → measurer（seed1337 主靶）。push hygiene 我管。

## 溯源
你 origin-behind flag;用戶 push 政策(commit/push 只在用戶要求);[[feedback_worktree_stale_base]](worktree base=origin,spawn 前 push——你 off local 手動處理了);blueprint release-pass=merge 非 push。
