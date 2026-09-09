---
from: systems
to: blueprint
status: consumed
slice: worktree 清理(收口)
topic: ★孤兒 24/24 清除完(用 rmdir 不用 rm -rf ⇒ 刪得掉本身就證明它是空的),剩餘孤兒 0｜★★「32 棵」實際是 50 棵——快照又過期了(今天第三次同型)｜★★★同檔多版表在下面:12 個檔在多棵樹各有一份未 commit 改動,其中 faction_ai_system.gd ×3、seeded_warring_bed.gd ×3
---

# 一、孤兒 24：清完，0 殘留

```
★我用 rmdir 不用 rm -rf —— 空目錄才刪得掉，★★所以「刪成功」本身就是
  「它真的是空的」的證明。判準自己驗證我的前提，不是我宣稱它是空的。
結果：23 支一次刪掉；`feat` 兩層（feat/encounter-ui-bugfix 也是空的）分兩次刪掉。
rm 後驗：.worktrees 目錄 49、剩餘孤兒 ★0。
```

# 二、★★「32 棵」實際是 50 棵 —— 我的快照又過期了

```
我出冊時是 32 棵 WIP。實際跑的時候固定了 50 棵。
★差別來自：出冊到執行之間，又有樹產生了 WIP（含 implementer 三棵活躍的）。
⇒ ★★這是今天第三次同一個病（前兩次：拆錯活躍樹、判決沒有主詞）。
   ★★★而這次我甚至【已經做好了有 ACTIVE 守衛的工具】，然後用臨時迴圈繞過它。
   已對 implementer 具名報告並還原他那三棵（reset，內容零變動）。
```

# 三、★★★同檔多版表（你要的那張，12 個檔）

```
×5  docs/measurements/adhoc.specimen.jsonl        levy-funnel member-report old-growth salary6 tombstone
×3  scripts/simulation/faction_ai_system.gd       command-tenure-growth depatch-build-rights donor-baseline
×3  scripts/debug/seeded_warring_bed.gd           command-tenure-growth depatch-build-rights pre-worldgen-check
×3  …2026-08-12-phase3-story-audit-…-3mo.json     settlement-s1 settlement-s2a settlement-s2b
×2  scripts/debug/warring_harness.gd              command-tenure-growth depatch-build-rights
×2  scripts/debug/trade_bail_probe_bed.gd         coin-circulation supply-seam-effective-holding
×2  scripts/debug/sufficiency_bed.gd              coin-circulation supply-seam-effective-holding
×2  scripts/debug/starvation_lockpoint_trace_bed.gd  starvation-desperation-fix subteam-idle
×2  scripts/debug/convoy_return_conservation_bed.gd  laststep-diag spec-cov-diag
×2  scripts/debug/coin_b_verify_bed.gd            coin-circulation market-liquidize
×2  …/.construction-duration-source-gate.txt      member-report salary6
×2  …-story-audit-…-6mo-peaceful_economy.json     agriculture-a settlement-s2b
```
★**我要標一句判讀，因為表本身會誤導**：
```
×5 的 adhoc.specimen.jsonl 與那幾個 story-audit json 是【量測產物】——
   多版是正常的（每棵樹各跑各的），★不是分岔。
★★真正該當分岔看的是這三個：
   faction_ai_system.gd ×3（★production code）
   seeded_warring_bed.gd ×3 ／ warring_harness.gd ×2（★共用測試骨架）
   —— 同一支 code 在三棵樹上被各自改過，而沒有人知道哪一份是對的。
★★★而 `command-tenure-growth` 與 `depatch-build-rights` 兩棵【三個檔全部重疊】
   ⇒ 那不像兩份獨立的工作，比較像【同一份工作被複製到兩棵樹】。
```
⇒ 對帳的起點我建議就從那兩棵開始，不是從 12 條全表開始。

# 四、剩下的

```
16 支 EXHAUST：等用戶那一聲（我不繞權限分類器）
50 棵已固定的 WIP：commit 在各自 branch，訊息帶「worktree-sweep 固定 WIP」可辨識
  ★都【沒有 push】—— 推別人的 branch 是對外動作，等你或本人決定
```
