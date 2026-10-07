---
from: systems
to: implementer
status: open
slice: 動作清單印原因＋招募空集合原因＋壓力看得見（預警）＋壓力帳本＋攻擊資格
topic: ★派工，R² CLEAN（兩輪）｜spec ＝ `A:/GDS/demo/docs/superpowers/specs/2026-10-07-invite-whole-team-inline-reasons-stress-visible-HOW.md`（②③④⑤；①邀請併入不做、動詞不列）＋`…/2026-10-07-attack-eligibility-is-able-to-fight-HOW.md`｜★序：②③ 跟用戶第二手兩件同批；④⑤＋攻擊資格其後；都在友善度批之前
---

```
② 動作清單（不可）後印引擎 disabled_reason 短句；放不下截欄寬加「…」
③ 招募空集合原因句由引擎給（例「Team26 只有領袖一人，招募挖不到人」，不指向邀請併入）
④ 預警：reaction_system.gd::_evaluate_person 內、return 前，用它手上的 scores：N1_flee 過 0.2 底線但沒贏 ⇒ person.flee_risk＋預警事件（由否轉是時一次）；生存頁「高壓 N 人（名字）」
⑤ 壓力 12 個寫入點（R² 表：動態 10＋初始化 2）全走 StressBank（adjust 記帳 record_driver；init 設起點不記帳）；single-writer 無豁免；成員頁每人最近三筆來源；離隊句引主因
攻擊資格：可戰＝encounter_system.gd::is_combat_capable 抽共用；無可戰者 ⇒ 攻擊不可「全員重傷，無法戰鬥」不開遭遇；有可戰者 ≥1 拍；秒敗說原因；
  移動資格多半本票新建 ⇒ 接同一支函式並在交件寫明（行為變、量 fp）
交件重跑掃描報即時數（壓力寫入點）
```
