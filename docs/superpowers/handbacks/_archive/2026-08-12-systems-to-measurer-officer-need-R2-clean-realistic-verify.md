---
from: systems
to: measurer
status: consumed
topic: "[R² CLEAN(結構+genuine+bounded)officer_need dispatch-demand 補·held feat/named-scarcity-ab 7304e16c·★6th-gap 命門移交你 realistic 定案:formula-clean≠realistic-fires·硬讀核查全過:①officer_need=maxf(villages-oversight①, dispatch-demand②)、dispatch-demand=(CONCURRENT2−spare)/CONCURRENT2、spare=named_members.size()②set_leader:238 erase leader→spare=可派 bench 正確排除領主(我先前 overcount 疑撤回)③subteam:79 remove_member 派遣真 drain bench(派 scout→spare↓)④MAG 1.3 未 bump=非 crank⑤無殘留 _promote_demand caller、leader_team_id 真欄、bounded(bench≥2→0/無村→0/非領主→0)⑥determinism 3-run byte-identical+test PASS+constitution 75·★★6th-gap 殘留(你定案、我 code-read 不能證):dispatch_demand SIMPLIFIES『任一 scout/care/relief demand>0=想派』→『有村=standing dispatch want』=PROXY;genuine-ness HINGES on 開火條件 bench=0 須真來自 actual dispatch 耗盡(named 非派遣不消失)→∴realistic 必顯示 T12 型領主真的 dispatch→drain bench→0→train→tier-up→promote→spare+1→need 降→停(終止性)·若 realistic 顯示 bench=0 卻無真 dispatch(白練)or 練了不促 promote(不終止)=not-genuine 失敗你抓·implementer 誠實 flag:Team12 pre-dispatch bench=1→0.5→train_drive 0.65<build 尚不練(正確 pre-symptom)、須 dispatch 耗 bench→1.0 才練→此正是你要驗的真 fire 條件·★量前後對照(main baseline vs branch、4+16 realistic diverse、5×overclaim+6gap 教訓禁預設):①T12 型真解否=真 dispatch→drain→train→promote→named+1→need 降→停(整鏈+終止)②bounded=well-benched(bench≥2)officer_need 0 不練(machine-demonstrate)③CONCURRENT2(2.0)/MAG(1.3)校準:full need 1.3 真贏 build argmax 否+bench=1 的 0.5 不誤 fire④vs 玩壞(over-train 排擠生產?over-promote anon 榨乾?named 爆增?)⑤人格分化(野心訓多/多疑吝嗇/絕境 field_desperate)⑥promote 終止性硬證=練→提拔→need 降→停(非無限練、用戶死循環疑的 realistic 反證)·determinism+specimen 送 QA·★merge-time 警:branch 落後 main(24 檔/7045 del stale base)→merge 必先 merge main→branch 免 revert 新 docs·output→T12 真解+終止+校準+玩壞否→systems consolidate→QA→merge→blueprint 推用戶·地基 KEEP"
---

# R² CLEAN（結構+genuine+bounded）→ measurer realistic 定案（6th-gap 命門移交）

held `feat/named-scarcity-ab` `7304e16c`。R² 硬讀核查全過，**6th-gap「真反映壓力」最終定案在你 realistic 床**（formula-clean ≠ realistic-fires，我 code-read 不能證）。

## R² 硬讀核查（全過 CLEAN）
1. `officer_need = maxf(villages-oversight①, dispatch-demand②)`；dispatch-demand `=(CONCURRENT2−spare)/CONCURRENT2`、spare=`named_members.size()`。
2. `set_leader:238 team.named_members.erase(pid)` → **leader 出 named_members**、spare=**可派 bench 正確排除領主**（我先前「overcount 含領主」疑=撤回）。
3. `subteam:79 remove_member(parent, sub_leader_id)` → 派遣**真 drain bench**（派 scout→spare↓）。
4. **MAG 1.3 未 bump = 非 crank**（genuine）。
5. 無殘留 `_promote_demand` caller、`leader_team_id` 真 FactionData 欄、bounded（bench≥2→0 / 無村→0 / 非領主→0）。
6. determinism 3-run byte-identical + test PASS + constitution 75。

## ★★6th-gap 殘留（你 realistic 定案、我 code-read 不能證）
dispatch_demand **SIMPLIFIES**「任一 scout/care/relief demand>0=想派」→「**有村=standing dispatch want**」= PROXY。**genuine-ness HINGES on 開火條件 bench=0 須真來自 actual dispatch 耗盡**（named 非派遣不消失→bench=0 是 dispatch 發生的下游證據）。
- ∴realistic 必顯示 T12 型領主**真的 dispatch → drain bench→0 → train → tier-up → promote → spare+1 → need 降 → 停**（整鏈 + 終止性）。
- 失敗態你抓：bench=0 卻**無真 dispatch**（白練）/ 練了**不促 promote**（不終止）= not-genuine。
- implementer 誠實 flag：Team12 pre-dispatch bench=1→0.5→train_drive 0.65<build **尚不練**（正確 pre-symptom）、須 dispatch 耗 bench→1.0 才練 = **正是你要驗的真 fire 條件**。

## ★量前後對照（main baseline vs branch、4+16 realistic diverse、5×overclaim+6gap 教訓禁預設）
1. ★**T12 真解否** = 真 dispatch→drain→train→promote→named+1→need 降→停（整鏈+終止）。
2. **bounded** = well-benched（bench≥2）officer_need 0 不練（machine-demonstrate）。
3. **CONCURRENT2(2.0)/MAG(1.3) 校準**：full need 1.3 真贏 build argmax 否 + bench=1 的 0.5 不誤 fire。
4. **vs 玩壞**：over-train 排擠生產？over-promote anon 榨乾？named 爆增？
5. **人格分化**（野心訓多/多疑吝嗇/絕境 field_desperate）。
6. ★**promote 終止性硬證** = 練→提拔→need 降→停（非無限練、= 用戶死循環疑的 realistic 反證）。
- determinism + specimen 送 QA。

## ★merge-time 警
branch 落後 main（24 檔/7045 del stale base）→ merge 必**先 merge main→branch** 免 revert 新 docs/measurements。此 merge-time 處置、非 R² 阻擋。

output → T12 真解+終止+校準+玩壞否 → systems consolidate → QA → merge → blueprint 推用戶。地基 KEEP。
