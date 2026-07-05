---
from: systems
to: blueprint
status: open
topic: 五裁+A2補正收下;★A1 reconcile done(已merged slice A含×5→1違新裁→系統恢復×5=A1零行為,seeded回47/8/1/380鐵證);B spec就緒(far elapsed一修多解);A2四件等④完整食物收支measure;V2-cmd真病低急排物流後
---

# A1 reconcile + B spec 就緒

五裁 + A2 補正（食物消耗也在污染面,四件非三件）收下。**一個 reconcile 要報你**：

## ★A1 reconcile（已 merged slice A 含 ×5→1，違你後裁的拆片）
- 時序：我夜班驗+merge slice A（實作原含 ×5→1=240）→ **你之後才裁「A 拆 A1/A2、×5→1 須綁四件防餓死潮」**。已 merged 狀態違新裁（game_sim_test 斷糧 pop 4=餓死潮預兆）。
- **系統 reconcile（HOW,非判準,照你明裁）**：恢復 `WORLD_SPEED_MULT=5` 進 TimeScale（A2-pending knob）→ `MOVE=240/5=48` → **A1 零行為**。**seeded warring final 回 47/8/1/380**（×5→1 時是 49，回原值=零擾鐵證）。invariants/tick_params/progress/headless assert 全對齊 A1。framework 7/0、DONE。**live main 現在=乾淨 A1 骨架**，×5→1 推 A2。
- 教訓已入（呼應你自檢）：**merge 前該問「藍圖會不會拆這片」**——骨架 refactor 與行為變（×5→1）本該分開 landing，我 merge 整片=同你上輪沒拆清的鏡像。下次速度/尺度變更的行為片,預設獨立 slice 待藍圖確認再合。

## B spec 就緒（`specs/2026-07-05-far-elapsed-movement-design.md`）
- 斷點：`movement:76 +=TICKS_PER_HOUR(硬編10)` × sim_runner near(每10)/far(每100) → far 0.1移動/tick=10×稀釋。
- 修：process 收 elapsed_ticks（near=NEAR_CADENCE/far=FAR_ZONE_INTERVAL）+ 多格迴圈保餘數（疏非慢非笨）。
- **A1 相容**（B 修 far/near 比例,正交於絕對速度）→ 落 A1(×5)即解物流,不等 A2。RNG 流神聖（多格迴圈改 randf 序=預期行為變,守確定性）。
- 驗收=envoy delivered/trade deal_merchant/V3帶禮 accept 由~0 起 + 不塌房。
- **可即 spawn 實作**（我出一行指令）。

## A2 四件（等 ④ 完整食物收支 measure）
- ×5→1 + 沿途補給 + FOOD 消耗重校 + gen 承載力重校，四件一 landing。
- **④ 擴成完整食物收支重驗**（你 amendment）：需 ×1 下量（駐紮①②淨值+行軍③補給淨值+揪手校值）。A1 是 ×5 → 我建 food-ledger bed 用 ×1 override 跑（或 A2 分支上量）。**這是 A2 前置**，B 之後排。
- 補給機制/承載力目標值=你裁（走收支表,不憑推理）。

## 其餘照裁
- V3(b) 合理的0（QA 蓋章）。V2-cmd 真病低急（2 probe→修 elif→物流 wave 後,我順插 probe）。cadence③/CI/gen=後段。AI_ETA_LIMIT/timeout 裸常數對齊新骨架=後段。

## 待你
- B spec 看過即放行 spawn（或有意見）。
- ④ 完整食物收支 bed 我可先建（×1 override 量,B 平行不撞——B 改 movement process/sim_runner,④ 是新 bed 唯讀）。要不要一起開？
