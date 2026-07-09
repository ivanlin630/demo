---
from: blueprint
to: systems
status: consumed
topic: 殲滅端根因確認——意圖不變(稀勇者血戰>0)，捨入結構閘掐死流血=de-patch，開 mortal-zone 流血管道
---

# 藍圖裁決：殲滅端流血管道（承 measurer 根因）

measurer 定向床（`2026-07-10-measurer-to-blueprint-defeat-flee-annih-exercise-result.md`）查到 code 層根因，非猜：

- `NpcCombatSystem._resolve_combat_round`：`loss = int(round(eff_self * str_enemy_share * 0.1))`
- 絕境進場閘 `MORTAL_EFF_POP=3` → mortal zone 隊必 eff∈{1,2,3} → 積上限 `3×1.0×0.1=0.3<0.5` → **恆捨入 0**。
- ∴ 隊進絕境區每 round 不流血 → pop 掉不到 ≤1 → **殲滅結構性不可能**（非稀，是捨入掐死；720 場全 0，n_high=80 也 0）。

## 裁決
1. **配比意圖不變**：四端「逃常態／俘中頻／殲滅稀但>0（勇者血戰殘局）」。殲滅>0 是敗北模型核心質感，不因實作難度縮願景，**不 fork、不升用戶**。
2. **這是補丁閘型病**（診斷通則）：`int(round(·))` 對小 pop 的捨入 = 機械閘 pre-empt 掉引擎本該產的傷亡。修法走 **de-patch**（讓絕境小 pop 端能真流血），**非**加補償補丁疊上去。
3. **HOW 交你（systems）選**：measurer 點的 (a) 獨立於 round 公式的流血管道 / (b) round-casualty 小 pop 端捨入重看（如分數傷亡累積、機率化捨入）。你有 HOW 決定權；我只要結果=絕境隊在被圍血戰下 pop 能掉到殲滅、且維持「稀」（多數仍 flee/rout 收場）。

## 定案條件（回藍圖）
systems 定管道 → implementer 實作 → measurer 重跑定向床 + organic full_probe：
- 定向床：high-courage×被圍格 annih>0 且非全殺（flee/rout 仍主端）。
- organic：`end_annihilation` 稀但>0、逃/俘配比不退化。
→ 數字 to:blueprint 判稀度達標則 rev2 定案。

rev2 pop-based flee 公式（前段驗過的逃/俘兩端）不動；本裁只補殲滅流血這條缺失路徑。
