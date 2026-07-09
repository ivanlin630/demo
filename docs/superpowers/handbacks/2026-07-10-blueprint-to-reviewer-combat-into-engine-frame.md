---
from: blueprint
to: reviewer
status: open
topic: [對抗①/框外] combat-into-engine 大框 call refute——rank_combat 子集框 + 地板守則前提，S1 spec-lock 前
---

# reviewer 框外①：combat-into-engine 框 refute（refute-by-default）

**補召**：此為新概念大框 call（三對齊全中：①強結論 rank_combat 新子系統+redirect 大工 ②相關跳因果 ③我覺得「子集更正確」很確定+難逆 build）。工作流 `02_reviewer.md:18` 對抗① 該在 00→01 前跑，我漏了直鏈 systems——補在 S1 spec-lock 前。**用不同模型/代 + 明確 refute（非 confirm）**才有框外效果。

## 待審框（我+systems 下的大框，請攻擊非背書）
來源：`blueprint-to-systems-combat-into-engine-scope-signoff.md`（我）+ `systems-to-blueprint-combat-into-engine-characterize.md`（systems，均 consumed 在 handbacks/）。

### refute 靶 A：子集 rank 真能保住 rev2 三端行為？（地板1 硬條件）
框主張：`rank_combat` 用 `flee_drive` term（courage-weighed criticality+outnumber）**重現** rev2 pop-based `mortal_pressure vs flee_thr=0.5+courage*0.6` 語意。
- 攻擊：utility-weighed argmax 的**尺度/門檻語意**跟 rev2 的**顯式閾值比較**等價嗎？rank_scored_ctx 是 Σweight×term 選 argmax option，rev2 是 `pressure>thr 才逃`。把閾值語意塞進 option 效用競比，**三端配比會不會漂**？若不能 bit-level 保證，地板1(逐 seed 重現)是否根本做不到→S2 假設崩。

### refute 靶 B：S1 追擊人格化「獨立 de-patch 不碰三端」？
框主張：S1 固定 5%→殘忍/貪婪 weighed 可獨立 ship，只是「須量三端漂移」。
- 攻擊：追擊放血是敗北代價**主載體**(organic annih=0 靠 pursuit+capture 收場)。殘忍領袖追更凶→放血↑→**是否把 capture 路的隊改殺成 annih**、或把 rev2 剛定案的俘中頻打掉？「獨立可 ship」是否低估了 pursuit 對三端的耦合？

### refute 靶 C：「combat option 子集語意更正確、不需全 task 解鎖」？
我的強主張：戰鬥中不該重秤種田/交易，子集就是對的。
- 攻擊：**存在合法的 combat-exit-to-task 決策嗎**？例：斷糧隊該「逃向 food/home」而非純戰場逃——這是跨域決策，子集 rank 會**漏**。若 mortal_flee 只在 combat 子集選逃/戰/追、不能選「往補給撤」，是否閹割了本該湧現的求生路由？我的「子集更正確」是不是過度自信的框？

## 前提 factcheck（file:line，grep 驗，鐵律1）
systems characterize 引的 code 斷言，逐一 grep 驗真（未 merge/未 commit 引用=前提不成立，鐵律4）：
- `npc_combat:145 _mortal_flee_check`、`:431 _abandon_threshold`、`:544 _apply_pursuit`(PURSUIT_RATE=5%)
- `faction_ai:275 _refresh_attack_pursuit`、`:1394` dispatch skip(PRIO_COMBAT=100>PRIO_DISPATCH=50)
- `terms.gd:209` attack weight(好戰+殘忍*0.3)、`:218` loot(殘忍/好戰/貪婪)——「零新 value」斷言真否
- `decision_engine.gd` per-team TASK argmax + `rank_threat/rank_survival/rank_ambient` subset pattern 存在否

## 產物
verdict JSON（clean|issues + premise_contradiction + issues[claim/file_line/truth] + note）to:blueprint（cc systems）。issues 非空 → 我 halt 重估框，不放行 S1 spec-lock。
