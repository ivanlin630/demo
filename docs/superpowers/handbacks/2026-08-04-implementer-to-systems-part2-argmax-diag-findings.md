---
from: implementer
to: systems
status: consumed
topic: "[Part2 求援 argmax-loss 診斷真值·measure-first 別下結論·root 確認=求援 applicable 但每 food 級輸 argmax rank 3/4·★winner=返家補給(非假設覓食/relocate/買糧、home-based resident)·求援 util 0.04-0.21(非假設 0.35)·⑥distribute 依賴驗:distress 塞領主 team_known→distribute candidate 生成(util 0.659)=證 distribute=0 下游於 herald 送達] feat/info-network-whole 436f85c2。argmax 二選一機制錯配(派信使≠放棄自救)支持 (a) side-action。measurement docs/measurements/2026-08-04-part2-argmax-loss-diagnostic.json。你讀確認 root+distribute 依賴→設計 (a)、我 HOLD。"
branch: feat/info-network-whole
commit: 436f85c2
measurements: docs/measurements/2026-08-04-part2-argmax-loss-diagnostic.json
---

# Part2 求援 argmax-loss 診斷真值（measure-first、別下結論、只交真值 + 表）

RE-measure#2 揭 help/scout/distribute 仍全 0。bed `infonet_argmax_diag_bed.gd`（seed 1337、honest-carrier、純觀測）掃 food_days 窗口、逐站 tap。

## ★argmax 輸給誰表（核心）
| food_days | 求援 applicable | 求援 util | rank | winner | winner util |
|---|---|---|---|---|---|
| 3.50 | **false**（severity=0、正確不絕境不求援） | — | — | — | — |
| 2.50 | true | **0.040** | 3/4 | **返家補給** | 0.472 |
| 1.50 | true | 0.123 | 3/4 | 返家補給 | 1.118（boost 起） |
| 0.50 | true | 0.207 | 3/4 | 返家補給 | 2.389（boost 破頂） |

top(2.5): 返家補給 0.47 / 駐守 0.22 / 建設 0.21 / 求援 0.04。

## root 確認 + 修正 systems 假設
- ★**argmax-loss root 確認**：求援 applicable（food<3）但**每 food 級皆輸 rank 3/4、從沒 reach dispatch** → herald_dispatched=0 真 root（dispatch-gate 修 necessary 但 **insufficient**、我 round-2 修對但不夠）。
- ★**修正假設**：winner = **返家補給**（此 resident 站自家 outpost=home）——**非 systems 假設的 覓食/relocate/買糧**（那些是無 home 隊求生；home-based resident 走返家補給）。
- ★**求援 util 0.04–0.21**（≠ 假設 ~0.35）：窗口 [2,3) severity=(3−food_days)/3 低 × 人格 mult → util 很低；food→0 severity↑但**返家補給 survival-boost 同步破頂 2.39、求援 追不上**。
- **genuine note**：求援輸求生=**引擎正確**（餓隊該先自救）。但**派信使 ≠ 放棄自救**（送個跑腿人同時仍可返家/覓食）→ 求援與求生**非互斥**、argmax 二選一是**機制錯配** → 支持 systems **(a) side-action** 設計（求援脫離 argmax 競爭、當併發 side-action）。★僅陳述、修法交你。

## ⑥ distribute 依賴驗（confirmed）
人工塞 distress（resident food 買單）進領主 team_known → **distribute candidate 生成 util=0.659 rank=1/5** → ★**證 distribute=0 是下游於 herald 送達**（領主沒聽到 need→distribute 根本不生成；一旦聽到就生成）=非獨立第二關、herald 通則解。
- 次要觀察（非主軸）：此 fixture distribute rank=1 輸 建設（領主有 idle-labor→idle_employ_value 競爭）；領主非餓、建設贏是引擎行為。

## 待你 / 我 HOLD
- ★**別下修結論、我 HOLD**：你讀**確認 argmax-loss root（求援輸返家補給/求生）+ distribute 依賴（下游 herald）**→ 設計 **(a) side-action**（求援脫離 argmax）→ R² → build。
- Part2 dispatch-fix（85edc4f6）+ bootstrap-fix + whole 4-slice 皆已在 branch；(a) side-action 續此 branch。
- bed-only 零 production 改（headless/constitution/determinism 不受影響）。

★measure-first、只交真值（[[feedback_measure_peroption_util_before_decision_claim]]）。待你確認 root → 設計 (a) → dispatch。
