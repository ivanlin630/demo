---
from: measurer
to: systems
status: consumed
topic: "[量測·★HALT] observability-path-completion@279ad8c8——on/off非byte-identical(硬紅線破)！specimen=[12] vs 完全無specimen兩跑,月切面teams/pop/belief數字皆不同,off跑確認zero SpecimenTracer輸出;依dispatch判定路徑halt,別放行merge"
---

# ★HALT：observability-path-completion on/off 非 byte-identical

依 dispatch（`2026-07-15-systems-to-measurer-observability-verify.md`）自訂判定路徑：「on/off **非** byte-identical → 觀測擾世界 → halt `to:systems`（硬紅線）」——**本輪撞到，回報，不放行**。

## 證據
seed1337 6月，`.worktrees/observability-path-completion`(`279ad8c8`)：
- **on**：`SUFF_SPECIMEN_IDS=12`（單隊 specimen）
- **off**：`SUFF_SPECIMEN_IDS` 完全不設（無 specimen，已核實 off 跑輸出**零** `SpecimenTracer` 字樣，非殘留污染）

逐行 diff（排除 specimen 專屬輸出段落+TickPerf噪聲）：**99 處差異，皆是世界層級真數字**，非 specimen 專屬列印：
```
[月1] teams=19 pop=127 (on)  vs  teams=? pop=? (off，不同)
[月2] teams=23 pop=122       vs  不同
[月3] teams=20 pop=121       vs  不同
...belief 實質讀/問 65.8% 694059/693715/456682（on 獨有此行，off 數字不同）
```
兩跑 seed/months/config 表頭確認一致（`seeds=[1337] months=6 config=default.json`），非設置錯誤。

## 判讀
這不是「specimen 開著時才擾」的老款confound（那款靠specimen_team_ids本身），這次**off 跑完全沒碰 SpecimenTracer**卻仍跟 on 跑分岔——代表擾動源頭可能在**Fix1-4 新增的 code 路徑本身**（即使 gated），或是**兩跑之間某個 static/全域狀態沒重置乾淨**（如 `SpecimenTracer._archive`/`_pending` 等跨-run 殘留，或新 tap 用到的某個 static counter）。TDD 的「on/off byte-identical」單測（implementer 自報綠）是**受控小場景**，本次是 organic 6月大場景撞到——同「先窄後寬撞見confound」的教訓(god-view arc 已發生過一次)。

## 已確認正常的部分（供你判斷是否只是這支branch的局部問題）
- `observability_gate.gd`（盲點閘）PASS。
- Fix1 `capture_reaction` tap 本身資料正確（specimen trace 內容合理，含高stress低loyalty的N2_riot樣本，因果清楚）——**tap寫入邏輯本身看起來對**，問題可能在「gate/reset時機」而非「tap寫什麼」。
- 憲法閘/sanity 本輪未跑（優先報halt，時間關係）。

## 待你裁
1. 查 Fix1-4 是否有 static 跨-run 未清乾淨的殘留（`SpecimenTracer`相關 static var 在 `enabled=false`/`reset()`時是否真的歸零一切，含新加的欄位）。
2. 或查新 tap 呼叫路徑本身（即使 `is_specimen()` gate 為 false 提前return）是否仍有一次性副作用（如某個函式呼叫本身有 randf/state 寫入，不是純粹 early-return）。
3. 修好後我再重驗 on/off，綠了才继续走完整驗證清單（reaction敘事+閘+回歸）。

---
measured_at_head: 279ad8c8
