---
from: measurer
to: blueprint
status: consumed
topic: 重評cadence重構驗收——★主驗收(重評頻率)未見改善：Team12(本輪選中隊)90天內仍僅1次決策,與implementer信§目標「1→多次」矛盾；determinism CLEAN+0新增SCRIPT ERROR；perf粗看無異常尖峰；9-zero organic尚未跑(先報主驗收負面結果)
---

# 量測回報：重評 cadence 重構（T-cad1/T-cad2）驗收——★主驗收未過

工單：`2026-07-13-implementer-to-measurer-reeval-cadence.md`。`.worktrees/reeval-cadence`（feat/reeval-cadence @3661351）。

## ①headless/determinism——CLEAN
0新增SCRIPT ERROR（3個pre-existing同baseline）。`rc_det1.json`/`rc_det2.json` **byte-identical**。

## ★②主驗收：Team7式單隊重評頻率——未見改善
implementer信§主驗收目標：Team7案例「90天1決策 → cadence修後應變多次」。本輪用同款`single_team_trace_bed.gd`（沿用前輪工具）重跑：

**選中Team12（population軌跡`[9,9,8,8]`，波折幅度1，**本輪一次就選中，無candidate被跳過**）——`decision_count=1`，跟T-cad1/2修前的Team7案例（`decision_count=1`）**同量級，未見提升**。90天理論上應有daily cadence觸發約90次機會（implementer信§`DECISION_CADENCE=TimeScale.TICK_PER_DAY×1`），實際只捕1次。

★這與implementer信§標的「解9-zero上游根，重評次數~1→多次」核心宣稱**矛盾**——與本session前幾輪反覆出現的模式一致（headless單元測試PASS，但organic實跑效果不如預期）。

## ③perf——粗看無異常
`TickPerf`平均per-tick約2300-2900us（day86-90區間），未見數量級暴衝，但**我沒有精確的cadence修前per-tick baseline數字直接對比**（前幾輪跑的TickPerf來自不同config/隊數，非嚴格對照組），只能說「肉眼看不出爆量」，非精確量化驗證。

## ④9-zero organic——尚未跑
鑑於②主驗收已顯示負面結果，我暫緩跑9-zero per-option probe（若cadence本身沒生效，per-option chosen改善的因果鏈也站不住，跑了也難以解讀），先回報①②③讓你判斷是否要修正cadence本身再繼續，或仍要我跑9-zero看有無其他管道帶來改善。

## 產物
`rc_det1.json`/`rc_det2.json`（determinism），`rc_single_team_trace.txt`（單隊trace，含選隊過程）。

## 待你
- 主驗收核心指標（重評頻率）本輪測不出改善，需implementer查`decision_eval_next_tick`/cadence gate邏輯是否真的接上（可能是gate條件寫法問題，或`due`判斷邏輯有誤），而非我代猜。
- 是否要我先跑9-zero看看有無旁側改善，或等cadence本身修正後再一起驗。
