---
from: systems
to: implementer
status: consumed
topic: "[cheap #2 tap-fix:faction-leave 4 出口接 Probe tap(憲法級全量暫態可觀測性補盲、blueprint 派直接修)·新 branch feat/phase3-tapgap-fix 自 main HEAD·★4 個 clear_team_faction 出口只 print 無 Probe.bump(defect death.defect_leave/betray g3.betrayal 出口有 tap、這 4 無):faction_ai:5152(起義自立脫離)/5158(起義流亡脫離)/5259(defection path B 投降強鄰 fail→clear)/5262(defection path C 獨立)·★fix=各加 Probe.bump(建議 key:uprising.secede/uprising.exile/defection.surrender_fail/defection.independent、gated by Probe.enabled 同既有慣例)緊鄰 clear_team_faction 前後·★命門:純觀測 tap 零行為變(Probe.bump 不耗 RNG、determinism byte-identical、無 sim 邏輯改)、感知鐵律無涉、憲法閘不變(非 TaskArbiter site)·★驗:tap 真 fire(構起義/defection 場景→counter 非零)+determinism 3-run byte-identical(Probe.bump 不入 RNG 流)+headless 0-new+constitution 75+regression·★行為變=零(fp 應 byte-identical=純 tap 加、無行為變)·完成 handback to:systems merge-gate 硬讀(核 4 tap 加、零行為變、determinism)→measurer 覆核 tap fire→merge→un-blind 未來 long-game audit·地基 KEEP"
---

# cheap #2 tap-fix：faction-leave 4 出口接 Probe tap

blueprint 派直接修（憲法級全量暫態可觀測性補盲、③story-audit #2 CONFIRMED tap-gap）。新 branch `feat/phase3-tapgap-fix` 自 main HEAD。

## ★真根（4 個無 tap 出口）
`clear_team_faction` 中 4 出口**只 print 無 `Probe.bump`**（defect `death.defect_leave` / betray `g3.betrayal` 出口有 tap、這 4 無）：
- `faction_ai:5152`（起義自立脫離）
- `faction_ai:5158`（起義流亡脫離）
- `faction_ai:5259`（defection path B 投降強鄰 fail→clear）
- `faction_ai:5262`（defection path C 獨立）

## ★fix
各加 `Probe.bump`（建議 key：`uprising.secede` / `uprising.exile` / `defection.surrender_fail` / `defection.independent`、gated by `Probe.enabled` 同既有慣例）緊鄰 `clear_team_faction`。

## ★命門
- **純觀測 tap 零行為變**：`Probe.bump` 不耗 RNG、determinism byte-identical、無 sim 邏輯改。
- 感知鐵律無涉、憲法閘不變（非 TaskArbiter site）。

## ★驗收
- tap 真 fire（構起義/defection 場景 → counter 非零）。
- determinism 3-run byte-identical（Probe.bump 不入 RNG 流）+ headless 0-new + constitution 75 + regression。
- ★**行為變=零**（fp 應 byte-identical = 純 tap 加）。

## 序
完成 handback `to:systems` merge-gate 硬讀（核 4 tap 加、零行為變、determinism）→ measurer 覆核 tap fire → merge → un-blind 未來 long-game audit。地基 KEEP。
