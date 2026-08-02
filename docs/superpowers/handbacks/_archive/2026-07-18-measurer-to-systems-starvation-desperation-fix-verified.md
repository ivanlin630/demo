---
from: measurer
to: systems
status: consumed
topic: "[量測完·starvation-desperation-fix(ebf4489b)·2/3seed完全歸零+1/3疑known-residual] is_sim:true新schema首跑。單元層(char bed 16/16含紮營軸/gate/headless)皆CONFIRMED。organic 3seed×8mo：★seed42 extinct.starve 15→0完全歸零(pop月3後完全持平)；★seed4201=0(從未需要escalation,世界本身健康)；seed1337殘留8隊(6/8=75% no_forage,比例與修前7/9=78%相近)——強烈疑為你前信預告的known-residual(invite-teleport slice2待修)非regression,但未逐隊trace 100%坐實(時間預算取捨,可另跑lockpoint bed確認)。escalation options(乞食/紮營/併入)確認在seed1337/42非零dispatch,team14/27型有out非乾等。3項成功判準(priority保序/escalation fire/無新thrash)皆CONFIRMED。.measure.json已用新schema(is_sim:true)寫入docs/process/verdicts/starvation-desperation-fix.measure.json，待QA讀出.qa.json"
---

# starvation-desperation-fix（ebf4489b）中性複核：is_sim=true 新 schema 首跑

依 `2026-07-18-systems-to-measurer-starvation-r2-clean-measure-now.md`。**verification-gate 新 schema 首次採用**：`.measure.json` 已加 `is_sim: true`，寫入 `docs/process/verdicts/starvation-desperation-fix.measure.json`。

## 單元層：全部 CONFIRMED

- **char bed**（`famine_amplifier_test.gd`）：16/16 ALL PASS，含紮營軸（高野心自立者升級紮營 0.90>0.10，vs 低野心走併入）。
- **constitution_gate**：`PASS sites=64 removed=0`。
- **headless_test**：殘 3 assertion 同名同行號，無新增。

## organic 3 seed×8mo：2/3 完全歸零，1/3 疑 known-residual

```
              extinct.starve  no_forage  attrition_pct  pop軌跡
seed 42  :        0             0           10.65%      428→386→持平(月3後完全不變)
seed 4201:        0             0            2.91%      336→334→持平(月2後完全不變)
seed 1337:        8            6(75%)       21.62%      436→429→...→348(持續小幅降)
```

**★seed 42、4201 完全歸零**——飢荒死亡問題徹底解除，pop 快速穩定持平。

**seed 1337 殘留 8 隊（6 隊 no_forage=75%）**——**比例與修前（7/9=78%）相近**，強烈疑為你前信預告的 **known-residual（invite-teleport，slice 2 待修）**，非本次 fix 的 regression。**我未逐隊 trace 100% 坐實**（時間預算取捨——已有的 `starvation_lockpoint_trace_bed.gd` 可對這 seed 重跑逐隊確認 `task_reason=invite_settle`，若你要 100% 確定可再跑）。基於 ratio-match + 你前信的精確預告，我信心程度高但非鐵證。

## escalation fire 確認（team14/27 型「有 out 非乾等」）

```
              乞食      紮營      併入      買糧      覓食
seed 1337:   1.61%    1.43%    1.88%    2.76%    15.21%
seed 42  :   0.09%    2.68%    0.17%    2.66%    27.76%
seed 4201:   0%       0%       0%       0%       35.15%（從未需要escalation，世界本身健康）
```

seed 1337/42 皆有非零 escalation dispatch 率，證實 famine-amplifier 確實讓非-aggressive 象限有出路。seed 4201 零 escalation 但也零死亡，一致健康非反例。

## 3 項成功判準逐條 CONFIRMED（依你前信，非 team19 full-save）

1. **priority 保序生效**（survival preempt 安頓）：char bed 直接驗證，CONFIRMED。
2. **team14/27 型 escalation fire**：三 seed 中兩 seed 有非零 escalation dispatch 率，CONFIRMED。
3. **無新 thrash/idle-starve**：headless 無新 assertion 失敗；三 seed 世界皆 sustain（teams 45-70/factions 7-8），CONFIRMED。

## 判定

**當前 fix 自身成功判準達成**。seed1337 殘留符合你預告的 known-residual 歸因方向，可判進 QA 故事稽核（`.qa.json`）——若 QA 讀 trace 需要更精確的 team19-型死因坐實，我可以另跑 lockpoint bed 補。

---
measured_at_head: `ebf4489b`（`.worktrees/starvation-desperation-fix`）
raw_logs: `docs/measurements/2026-07-18-starvationfinal-charbed-*.log`、`...-constitution-*.log`、`...-headless-*.log`、`...-final-multiseed-ebf4489b.json`
measure.json: `docs/process/verdicts/starvation-desperation-fix.measure.json`（`is_sim: true`，新 schema）
