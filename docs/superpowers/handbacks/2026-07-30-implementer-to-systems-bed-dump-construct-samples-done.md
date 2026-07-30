---
from: implementer
to: systems
status: consumed
topic: "[done·bed construct dump·pin 拉走機制·帶 ct_task/ct_reason] feat/peaceful-economy-bed 0b6523db。4Q 段補印 construct.stall/samples(ct_task/ct_reason,純多印既有 data)。★坐實:construct.stall=29101 / start_task_not_build=7 / complete_build=0 vs complete_upgrade_facility=6 / timeout_cancel=0 / resume.attempt=0。stall samples ct_task=覓食/外交 ct_reason=unified、ticks_left>0(168/336)=argmax 搶班(unified 決策改 task)非 timeout release。dump 落地 docs/measurements/2026-07-30-peaceful-econ-bed-dump-0b6523db.txt(存在)。驗:bed exit0+observability_gate PASS+constitution 74。"
branch: feat/peaceful-economy-bed
commit: 0b6523db
base: 613d763d (local main HEAD)
measurement: docs/measurements/2026-07-30-peaceful-econ-bed-dump-0b6523db.txt
---

# done：bed construct dump（pin remote founding 拉走機制）

照補。4Q 段純多印 `result` 既有欄位（`WarringHarness.run` 已 capture `CONSTRUCT_SAMPLE_KEYS`）→ 零 sim 改、零行為變、**零數字變**（4 問數不變）。

## ★dump 坐實（中性讀樣本，機制判給 systems）
```
construct.start=14  start_task_not_build=7  complete_build=0  worldgen.build_outpost=1
construct.progress=145  construct.stall=29101  construct.timeout_cancel=0  construct.complete=6
resume.attempt=0  resume.success=0  resume.reject_*=0
construct.complete_upgrade_facility=6  complete_upgrade_level=0
```
**construct.stall samples**（前 8 筆，tile=施工格 / ct_id=施工隊 / ct_task=該隊現任務 / ct_reason）：
```
tick=510 tile=[6,10] ct_id=4 ct_task=外交 ct_reason=unified ticks_left=168
tick=510 tile=[8,10] ct_id=3 ct_task=覓食 ct_reason=unified ticks_left=168
tick=510 tile=[10,6] ct_id=5 ct_task=覓食 ct_reason=unified ticks_left=168
tick=510 tile=[11,9] ct_id=7 ct_task=覓食 ct_reason=unified ticks_left=336
（tick=520 同 4 格重覆）
```

## 樣本指向（事實層，非設計裁定）
- **complete_build=0 vs complete_upgrade_facility=6**：own-outpost 就地升級完工正常；remote/founding build 一件都沒完工。
- **拉走機制 = argmax 搶班**（非 timeout release）：`timeout_cancel=0`、`resume.attempt=0`（從沒嘗試召回復工），stall samples `ct_reason=unified`（unified 決策引擎 argmax 把施工隊 current_task 改成 覓食/外交），`ticks_left>0`（施工未完就走人）。
- **construct.stall=29101** = 施工格每 tick 找不到 builder（builder 跑去 覓食/外交）→ 逐 tick 累計；`construct.progress=145`（有 builder 在格才進度）。
- ★被搶的 ct_id=3/4/5/7 = ②develop（3/4/5）+③（7）——**注意**：這些是 own-outpost 隊被自身其他 task 拉走；①founding（0/1/2）的 remote 子隊行為需 systems 讀完整 dump 5861 行 samples 對照（我只摘前 12 筆/key）。

## 交付
- dump **落地** `docs/measurements/2026-07-30-peaceful-econ-bed-dump-0b6523db.txt`（5861 行，已驗存在；含全 construct.start/stall/progress/complete samples + 逐隊月故事）。
- 驗：bed exit0、observability_gate PASS（cd=9 rng_scan=5檔，bed 無 marker 不被③掃）、constitution PASS 74 removed=0。

## 待
systems 讀 dump pin 拉走機制（argmax vs timeout；樣本指向 argmax `ct_reason=unified`）→ 設計 non-freeze founding fix（persist floor / timeout-aware / argmax 施工保護）→ spec → 我實作。★卡住/需完整 5861 行特定 key 樣本再抓，報 to:systems。
