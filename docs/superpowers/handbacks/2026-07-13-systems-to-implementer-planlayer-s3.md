---
from: systems
to: implementer
status: consumed
topic: [工單 S3] 計畫層 survival-bypass—劇變立即重算rung(目標階層≠行動層survival override);plan Task3;疊新worktree feat/plan-layer-s3
---

# 工單 S3：survival-bypass（劇變立即接管 rung）

plan：`docs/superpowers/plans/2026-07-12-midlong-term-plan-layer.md` **Task 3**（R² CLEAN）。S1+S2 已 merged main。S3:遲滯設計的風險——rung 該降沒降的窗口內行為停舊高 rung 但實質活不下去。加**劇變幅度立即重算 rung**（無視 milestone 遲滯）。**新 worktree `feat/plan-layer-s3` 疊當前 main（已 push，含 S1+S2）。**

## 做（照 plan Task 3 Step 1-6）
- team_data 加 `rung_pop_last: int`（記上期 pop 算驟降）。
- `AmbitionLadder.update()` 開頭（leader 取得後、正常升降前）加 bypass 檢查（見 plan Step 3 完整 code）：劇變（pop 驟降>30% / food_flow<-2.0 / leader 失）→ 立即重算 rung 為承載力（連續 milestone_met 爬到的最高 rung）→ set + return（不走正常升降/stall）。
- 常數 RUNG_CRASH_POP_DROP_PCT=0.30 / RUNG_CRASH_FOOD_DEEP=-2.0。
- TDD:`_test_plan_rung_bypass`（pop 驟降+food 深負→立即降,不經 stall_count）。

## ★層次分離必守（R² 驗過、spec §核心）
- **bypass 只改 `ambition_rung`（目標階層）**——**不碰 `_evaluate_survival`（行動層插隊覓食）**、不碰任何 task/option 派工。
- 兩者觸發條件**各自獨立定義**（bypass=劇變幅度;survival override=當下飢餓）——避 :39 誤判兩者等價重演。
- bypass 是 S1 milestone-based demote 的**補充**（demote=連續 K 次失守含 plateau;bypass=單 cadence 劇變立即,跳過 K 遲滯）。

## 守（Global Constraints）
- **掛 S1 rung update,複用 milestone_met**（承載力=連續 milestone_met 爬到的最高 rung）。
- determinism byte-identical（純算術零 randf）。
- baseline 位移非 regression。

## 驗收（handback to:measurer）
- 劇變隊 rung 立即反映（不卡舊高階持續失敗到 K）+ 崩潰矩陣:加 bypass 後死磕原地減少（re-plan 遷移/投靠苗頭）+ determinism + 融合閘 + headless 零新增。

## 註
- 序列末前:S3 merge 後 dispatch S4（GUI，最後）。
- 卡點 → to:systems（如 S1/S2 trace 抓設計問題→呈報裁決）。
