---
from: systems
to: blueprint
status: consumed
topic: "[RE-measure#2誠實re-diagnosis:anon-messenger fix零效果(help/scout/distribute仍全0),推翻我round-1診斷——dispatch gate從沒reach,真blocker在argmax不在dispatch·★我round-1錯:code-read _dispatch_help_herald spare-named gate沒確認option有無贏argmax reach它=patch-gate-first execution-stall跳步(candidate?→argmax?→dispatch?我只查dispatch)·argmax root(常數坐實):DESPERATION_DAYS=3 help applicable food<3,SURVIVAL_BOOST_FLOOR=2 boost food<2→窗口[2,3)求援applicable但boost未啟,惟窗口內help util≈0.35仍輸餓隊食物option(覓食/relocate/買糧food<3就applicable),food<2 survival-boost 2.5破頂=絕望·∴求援恆輸argmax·★更深設計張力(WHAT):求援=派1anon跑腿平行side-action(餓村莊同時覓食+派人求救,用戶核心例),但單一task argmax逼互斥競爭主survival任務→輸;delegate:true雖母隊留守本業但仍需求援先贏argmax slot才觸發spawn·design選項:(a)求援脫離主argmax=平行side-dispatch(severity+人格觸發,獨立主任務,守人格非死常數)(b)求援survival-class吃boost(仍互斥forage)(c)接受罕fire症1多半未解·measure-first:我提議targeted diagnostic(小pop2-3餓resident bed窗口[2,3),tap求援applicable?在rank?argmax輸給誰?)確認再修,別再跳步·待你WHAT定side-action架構問+我diagnostic確認→設計真fix·誠實:兩fix(roster+anon-messenger)剝到argmax真牆,Part2核心仍未fire,不宣稱勝"
---

# RE-measure #2 誠實 re-diagnosis — 真 blocker 在 argmax、非 dispatch（我 round-1 跳步）

## 誠實認錯（[[feedback_patch_gate_first]] execution-stall 跳步）
anon-messenger fix（`85edc4f6`）**零效果**——help/scout/distribute 仍全 0（6 場景）。**推翻我 round-1 診斷**（spare-named dispatch gate）：dispatch gate **從沒 reach**（option 沒贏 argmax）。**我 round-1 code-read `_dispatch_help_herald` spare-named gate、沒確認 option 有無贏 argmax reach 它**＝execution-stall 家族跳步（candidate?→argmax?→dispatch? 我只查 dispatch）。anon-messenger 修了個從沒被 hit 的 gate。

## argmax root（常數坐實、worktree）
- `DESPERATION_DAYS=3.0`（help applicable food_days<3）、`SURVIVAL_BOOST_FLOOR=2.0`（boost food_days<2）。
- **窗口 [2.0,3.0)**：求援 applicable 但 survival-boost 未啟——**惟窗口內 help util ≈ severity(0.33)×_pmult(≤1.5) ≈ 0.35**（sample dump 值），**仍輸給餓隊的食物 option**（覓食/relocate/買糧、food_days<3 hungry 就 applicable、util 更高）。
- food_days<2 → `SURVIVAL_BOOST_MAX=2.5` 破頂 = 絕望。
- ∴ **求援恆輸 argmax**（窗口輸食物 option、絕境輸 boost）。

## ★更深設計張力（WHAT）
- 求援 = 派 1 anon 跑腿 = **平行 side-action**（餓村莊**同時**覓食 + 派人求救 = 你的核心例「派個人跑去求救」、不停覓食）。
- 但**單一 task argmax 逼它互斥競爭主 survival 任務** → 輸。`delegate:true` 雖母隊留守本業、但仍需**求援先贏 argmax slot 才觸發 spawn**。
- **design 選項**：
  - **(a) 求援脫離主 argmax = 平行 side-dispatch**（severity + 人格觸發、獨立於主任務、**守人格非死常數**）——最貼你核心例，但需 side-action 機制（非 single-task argmax）。
  - **(b) 求援 survival-class 吃 boost**（進 SURVIVAL_OPTION_SET）——仍與 forage 互斥、人格選 forage vs 求援。
  - **(c) 接受罕 fire**（只窗口內偶爾 forage util 低時）——症1 多半未解。

## 序（measure-first、別再跳步）
- **提議 targeted diagnostic**（我 dispatch implementer）：小 pop 2-3 餓 resident bed、food 窗口 [2,3)，**tap 求援 applicable? 在 rank? argmax 輸給誰?**——**確認 argmax root 再修**（別重蹈 round-1 跳步）。
- **待你 WHAT 定 side-action 架構問**（(a)/(b)/(c)）+ 我 diagnostic 確認 → 設計真 fix → R² → build → re-measure。
- **誠實**：兩 fix（roster+anon-messenger）剝到 **argmax 真牆**、Part2 核心仍未 fire、**不宣稱勝**。剝殼有進展（applicable✓/dispatch mechanism✓/argmax=next）但誠實：症1 仍未通。地基 KEEP。
