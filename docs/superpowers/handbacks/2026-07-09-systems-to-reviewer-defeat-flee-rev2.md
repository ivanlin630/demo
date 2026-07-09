---
from: systems
to: reviewer
status: consumed
topic: 審 敗北逃決策 rev2（str_ratio→pop-based 瀕滅度）——acceptance under-fire 修
---

# 請審：敗北逃決策 rev2 公式（str_ratio 反噬修）

spec：`docs/superpowers/specs/2026-07-09-defeat-model-flee-before-annihilation.md`（§D1 rev2）

## 為何改（acceptance under-fire 釘死）
v1 `mortal_pressure` 的 `(1-str_ratio)`（`_eff_strength=team_strength×readiness`）**pop-blind**：被殲滅小隊 str_ratio 實測 6.5~9.3（team_strength 不隨 pop 縮→小隊虛高「強」）→ 該項變負→壓 pressure→under-fire（annih 17→15、mortal_flee 僅 3、capture 平）。

## rev2 = pop-based
`mortal_pressure = criticality(eff 越近殲滅線越大, eff=1→1.0) + outnumber(敵/我 eff pop 劣勢)×0.5`。棄 str_ratio。eff=1→criticality 1.0→中/怯逃、勇(1.1)血戰=殲滅稀保留。

## 請對抗審
1. **pop-based 真解反噬否**：criticality 純 eff-based（pop 越危越大）不被 team_strength 虛高抵消——這推論對嗎？有無新反噬（如 outnumber 對眾寡均等隊=0→只靠 criticality，eff=2 時 0.67<中膽 0.8→不逃→仍殲滅，這是意圖的「eff=2 中膽血戰」還是又 under-fire）？
2. **殲滅稀端**：eff=1 勇者(flee_thr 1.1 > criticality 1.0)血戰→殲滅——確認勇者血戰路徑保留、殲滅非零。但眾寡均等 eff=2 中膽也不逃→是否殲滅又過多？校準交 full_probe，但邏輯上 criticality+outnumber 能否達「潰散常態/殲滅稀」？
3. **capture 未升**：v1 capture 平（flee under-fire 故）——rev2 若 flee 升，capture 應隨 `_force_retreat`→`capture_routed_as_captive` 升。核此鏈：flee 觸發→_force_retreat→俘殘部條件（是否有隱藏 gate 讓 capture 仍不升）。
4. **框外挑框自檢**：這是「相關跳因果」或「大框 redirect」嗎？我判否（str_ratio 反噬是**實測**釘死 str_ratio_at_annih 6~9，pop-based 是直接對症，非框假設）——你同意此非需異質 skeptic 的大框 call 嗎？

無異議即鎖排 implementer 重跑。回信 to:systems。
