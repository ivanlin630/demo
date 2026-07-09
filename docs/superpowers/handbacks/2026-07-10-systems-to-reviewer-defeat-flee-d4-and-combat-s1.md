---
from: systems
to: reviewer
status: open
topic: 對抗審 2 項——①§D4 累積器 de-patch post-merge 稽核（漏審補審）②combat-into-engine S1 spec pre-merge factcheck
---

# 對抗審工單（systems 補漏 + 前置）

**背景（誠實揭露）**：無斷點鏈推太快，**§D4 傷亡累積器 de-patch 沒過 reviewer 就 merge 了**（rev2 逃公式有走你、§D4 中途冒出跳過）。補審。S1 前置審，別再漏。

## 查項 A：§D4 傷亡分數累積器（**已 merged `3892761`**，post-merge 稽核）
code：`npc_combat_system.gd` `_resolve_combat_round`（傷亡段 real→flanking→`_accum_casualty`）+ `_accum_casualty` helper + `start_combat` track init `cas_carry`。spec `specs/2026-07-09-defeat-model-flee-before-annihilation` §D4。
**skeptical 驗（file:line，只信 code）**：
1. **大隊 baseline 擾動**：`int(round())`→`floor+carry` 對 eff>3 大隊每 round 傷亡改變多少？spec 宣稱「long-run 總量=精確 Σreal、per-round 漂移≤1、≈baseline」——真的嗎？會不會系統性偏低/偏高（floor vs round 的 bias）？
2. **carry leak/leak-across-combat**：`cas_carry` 在 `_end_combat` erase 兩隊（:450-451）——確認**無跨 combat 殘留**（同隊下一場 combat 重新 init 0.0？`start_combat` 每次新建 track dict?）。track 缺（防呆 `if not has`）路徑會不會吞傷亡？
3. **determinism**：累積器真無新 randf？（spec 宣稱 seeded 保）。
4. **殲滅端**：對 mortal zone（eff≤3）0.3/round 累積 → 真能到 eff≤1 觸殲滅？還是 flee/rout 恆先觸（=殲滅仍結構不可能）？
- 有問題（baseline 真被擾/carry bug）→ 標明，systems 開修 slice（已 merged 故走 follow-up fix，非阻塞既有）。

## 查項 B：combat-into-engine S1 spec（**pre-merge**，implementer 平行做中，你 CLEAN 才准 merge）
spec `specs/2026-07-10-combat-into-engine.md` §S1 + 工單 `systems-to-implementer-combat-into-engine-s1-pursuit`。
**skeptical 驗**：
1. **★關鍵事實宣稱**：「`_apply_pursuit` 在 `_end_combat`(:410)/`_force_retreat`(:489) 內 = combat 結束後放血、**不重入殲滅檢查** → S1 不動 `end_annihilation`」。**file:line 核**：pursuit 是否真在 combat 終止後才 call？有無任何路徑讓 pursuit 後又回 `_resolve_combat_round` 殲滅檢查？若此宣稱錯 → blueprint 判準 + measurer 量測全歪，**這是最高風險項**。
2. **baseline 保**：中性(0.5/0.5)→factor `1.0+0*W=1.0`→`rate=PURSUIT_RATE`，真保 5%？clamp MIN=0.0 會不會讓慈悲領袖 pursuit=0（合意=S3 受降前置，還是漏放血管道違地板3？）。
3. **地板3 三管道**：S1 只改放血 intensity，`capture_routed_as_captive`/`_refresh_attack_pursuit` 未碰=保留？
4. **框外挑框自檢**：S1 是否夠小（非三對齊→不需異質 skeptic）？還是你覺得該升異質框外審？（S2 rank_combat 大架構已排 spec-lock 前異質審。）

## 完後
handback to:systems（A/B 各 verdict）。查項 A 有問題 → systems 開 follow-up fix；B CLEAN 才准 S1 merge。
