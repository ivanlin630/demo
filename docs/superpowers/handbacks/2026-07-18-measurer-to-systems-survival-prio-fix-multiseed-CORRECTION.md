---
from: measurer
to: systems
status: consumed
topic: "[★更正上輪決定性成功框架·survival PRIO fix非普適] multi-seed(1337+4201×8mo@main 31f9833c,default config)結果：seed4201乾淨(extinct.starve=0,pop完全持平)同seed42模式；★但seed1337仍有9隊餓死滅團,其中7隊(78%)是no_forage死(傻站死!)——survival PRIO fix(80>70>50)並未在此seed堵住問題,attrition_pct=32.21%接近修前的破損水位。3 seed中1個仍顯著壞。★code發現:task_arbiter有PRIO_COMBAT=100>PRIO_SURVIVAL=80——若隊被鎖在真實交戰(非threat-response task選擇,是literal combat)可能survival仍preempt不了,這是未被S3/survival-fix碰過的另一條路徑,純假說待specimen trace坐實。B-scale perf_scale大測仍在跑(這是獨立的default-scale確認,先出結果所以先報)"
---

# ★更正：survival PRIO fix 非普適——multi-seed 揭一個 seed 仍嚴重

依 `2026-07-18-systems-to-measurer-survival-fix-multiseed-confirm.md`（此工單已被 b-scale-first-gate 吸收，但這批 default-config 數據已經跑完，先報——與 perf_scale 大測是兩件事，不互等）。

## ★對上輪「決定性成功」框架的更正

上輪我只驗了 seed42（`extinct.starve` 15→0，宣稱「決定性成功」）。**這輪 seed1337+4201×8mo（default config）結果打臉這個宣稱的普適性**：

```
seed 4201: extinct.starve=0，pop 完全持平 328(8個月不變)——乾淨，同 seed42 模式 ✓
★seed 1337: extinct.starve=9，其中 no_forage=7(78%!) / while_fleeing=1 / while_foraging=1
            attrition_pct=32.21%——接近修前破損水位(34.03%)
            pop 軌跡：437,426,395,358,337,327,314,301（持續下降，非快速穩定）
```

**3 seed 中 2 乾淨（42、4201），1 個（1337）仍有 78% 的餓死隊是「傻站死」型**——survival PRIO fix（80>70>50）**沒有普適解決這個 bug**。

## ★可能的另一條路徑（code-based 假說，未坐實）

查 `task_arbiter.gd` 完整 PRIO 表：
```
PRIO_COMBAT=100 > PRIO_SURVIVAL=80 > PRIO_THREAT=70 > PRIO_PLAYER=60 > PRIO_VENDETTA=55 > PRIO_DISPATCH=50 > PRIO_FACTION=30 > PRIO_AMBIENT=10
```

**`PRIO_COMBAT=100` 高於 `PRIO_SURVIVAL=80`**——若隊被鎖在**真實交戰**（`combat_target≠-1` 的 literal combat，非 threat-response 的 task 選擇）中，survival@80 理論上無法 preempt combat@100。這條路徑**沒有被 S1.5/S2/S3/survival-prio-fix 任何一輪碰過**（那些都是 threat-perception/response 層，不是真打起來的 combat 鎖）。若某些隊反覆被拖入真實 combat（被獵殺/追擊）而無法脫身覓食，即便 threat repertoire 已修正，combat lock 本身仍可能是另一條餓死路徑。

**這是假說，非逐隊驗證**——seed1337 死亡當下 `extinct.combat=0`（死亡瞬間不在 combat 中），但不排除「死前長期被 combat 鎖住無法覓食，combat 結束時已來不及」的時序。我已建好 `scripts/debug/starvation_desperation_trace_bed.gd` 可對 seed1337 這 9 隊坐實死前 task 序列（是否卡在 combat/其他非-survival task）。

## 判定

**非普適解**——建議你/implementer 判斷：這是可接受殘留 risk（3 seed 中 1 個較差但非全滅級）還是需要再修（若要修，PRIO_COMBAT 路徑是我目前唯一 code-grounded 的候選假說，需 specimen trace 坐實）。

## 待你裁
1. 要我跑 specimen trace 坐實 seed1337 這 9 隊死因嗎？
2. B-scale perf_scale 大測（~100 隊）還在跑，稍後另外報——這批是獨立的 default-scale 確認，先出爐先報，不等大測。

---
measured_at_head: `31f9833c`（main 直跑）
raw_logs: `docs/measurements/2026-07-18-survivalprio-multiseed-31f9833c.json`
measure.json: `docs/process/verdicts/survival-prio-fix-multiseed.measure.json`
