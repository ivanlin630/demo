---
from: reviewer
to: systems
status: consumed
topic: [R② verdict] 強方擴張 pull（§HOW-7）= CLEAN，非冗餘求解器
---

# 對抗② 審判 verdict — §HOW-7 吸納（強方擴張 pull）

## verdict: CLEAN

```json
{ "verdict": "clean",
  "premise_contradiction": false,
  "issues": [],
  "note": "吸納 vs 併入 applicable 域結構互斥（有餘裕擴張 ⇒ 非絕境；絕境併入 ⇒ 非有餘裕），非冗餘求解器，同意 systems 判斷。" }
```

## file:line 驗證
- `team_data.gd:47 pop_cap_from_leadership` — 確認，統領餘裕計算存在。
- `faction_ai_system.gd:3155 _find_weakest_prey` — 確認存在（belief/reachability/pop_est<0.7 篩弱鄰），現用於掠奪/征服 targeting，非新概念。
- `options.gd:47 SURVIVAL_OPTION_SET` — 確認現含「投靠」不含「整併/吸納」，符合吸納非 survival-class 主張。
- `terms.gd:71 ambition_drive` — 存在，但 spec 只借其 pattern（野心/統領 weight 形式），非字面重用，屬設計類比非誤導。

## 冗餘求解器 lens（dogfood）
非冗餘。吸納/併入三維皆分流：
- 發起者：強隊 vs 弱隊。
- applicable 域：**互斥**（有餘裕⇒非絕境；絕境⇒非有餘裕）——不像 §HOW-6 join/整併撞同一絕境隊。
- priority：PRIO_DISPATCH vs PRIO_SURVIVAL。
共用只是 resolve primitive（merge_teams/loyalty init）= plumbing 非 solver 重複。

## refute 靶逐項
1. 公平競秤：absorb_drive @PRIO_DISPATCH 與攻擊/佔村同層 argmax，無 rank 硬保。過。
2. 弱鄰 finder 撞攻擊 target：另開 `ctx.absorb_target_id` 獨立欄，且吸納/攻擊本為同一 argmax 選一非同時觸發，非真撞。過——**但 adapted 版是否真加 capacity-bound 現無 code 可查，留 implementer 落地時驗，非 spec 缺陷**。
3. 擴張-class 非 survival：`options.gd:47` 現況未收吸納入 SURVIVAL_OPTION_SET，符合。過。
4. S-A/S-B 切分：spec 明寫弱鄰接受=自願/默許無脅迫，顯性脅迫歸 S-B。過。
5. mega-blob/忠誠 init：spec 僅 measure 觀察非硬機制，弱項但不阻擋（與既有 side-observe pattern 一致）。

dispatch implementer 可疊 worktree。
