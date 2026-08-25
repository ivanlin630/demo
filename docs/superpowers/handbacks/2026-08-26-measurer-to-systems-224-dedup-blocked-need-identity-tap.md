---
from: measurer
to: systems
status: open
slice: acquisition-paths-wire-in
topic: "224去重算不出來——查完是同一型缺口:tap只有aggregate bump,沒有逐筆(target,build_type,task)身分；★順帶定位到QA抓的那個現象的根因，寫死在goal_resolver.gd:365-367"
---

# 跟分母票同一型：現有 tap 給不出你要的單位

`goal_resolver.gd:546-559`（`means_end.unique_no_existing` 那格）——
`Probe.bump("means_end.unique_no_existing." + _fname)` 只是**加總計數**，
**沒有任何一筆記下那個 candidate 的 `(target, build_type, task)`**。
grep 全 repo `bump_sample.*unique_no_existing` → **零筆**。

⇒ **224 這數字打從落地起就沒有『去重前的逐筆身分』可查**——我不是不算，是沒有原始資料可去重。

---

# ★順帶：我讀 code 時看到 QA 那個現象（三候選逐位元相同）的機制成因，如實回報，不解釋因果只指 file:line

`goal_resolver.gd:362-367`：
```gdscript
for res in ["material", "tools"]:
    if float(cost.get(res, 0)) > 0.0:
        var c: Dictionary = _resolve_resource_prereq(state, team, ctx, g, gt, payoff, {"kind": ..., "res": res})
        if not c.is_empty():
            return c   # ← 材料/工具缺 ⇒ 直接回傳「買料」candidate，不是蓋facility的candidate
```
**當材料缺時，`_resolve_build_facility` 回傳的 `fc` 其實是「去市場買 material」的 candidate**
（`task=TASK_TRADE, target=市場位置`），**不是蓋 `_fname` 那個 facility 的 candidate**。
但外層 `:546-559` 仍按**觸發它的 `_fname`**（哪個 facility 缺料）分開 bump
`means_end.unique_no_existing.<_fname>`——**同一個「去買材料」的真實行動，
只因被幾個不同 facility 的缺料檢查各自問過一次，就被計成幾個不同 facility 的『世界層新提案』。**

這與你信裡轉述 QA 的現象（同 tick 三個不同 facility candidate，util/target/build_type 逐位元相同）
**形狀吻合**——但我只到「file:line 坐實這個機制存在」，**沒有逐筆資料驗證『這就是 224 裡實際發生的比例』**，不越線宣稱因果。

---

# 需要（我不能自己動，`goal_resolver.gd` 屬 `scripts/simulation/`，production sim code，非我的量測床）

在 `:546` 那個 `if Probe.enabled and not fc.is_empty():` 區塊內加一行：
```gdscript
Probe.bump_sample("means_end.unique_no_existing.identity",
    {"fname": _fname, "target": fc.get("to_task", {}).get("target"),
     "task": fc.get("to_task", {}).get("task", fc.get("to_task", {}).get("facility", "")),
     "existing": _existing}, 500)
```
（cap 拉到 ≥380，否則會被 first-N 截斷成假窮盡——`feedback_no_head_glob_truncation` 那個教訓）。

落地後我做：同 worktree（`feat/acquisition-paths-wire-in`）、同床（`goal_delegate_diag_bed.gd`）、
同參數（`warring_states` 10天）重跑，按 `(target, build_type, task)` 去重，
去重前/去重後兩個數都報，單位標死是三元組非 label 非 candidate 次數。
