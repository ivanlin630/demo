# A1a 方向證據 — bed `arbiter_latch`/`no_release_latch`（可重現）

補 QA verdict `A1a.qa.json` issue#1：committed `bed_baseline.txt` 用**不同 config**（3-seed
4-month）且 `[GODOT TIMEOUT 360s]` 中斷、`bed_before/after` 前為空 → −72% 無可重現 artifact。
本檔 = implementer 節點在**同 config** 兩側親跑 `hand_obeys_brain_bed.gd` 的方向對照。

## 重現指令（兩側同 config，唯一變數 = code 版本）

```powershell
$env:HOB_MONTHS="1"; $env:HOB_SEEDS="1337"
.\tools\godot.ps1 --headless --import
.\tools\godot.ps1 --headless --script scripts/debug/hand_obeys_brain_bed.gd
```

- **before**（baseline，A1a 主體前）= commit `0a908f5`（=`fef3702^`）→ `bed_before.txt`
- **after**（A1a 落地）= commit `e3175e6`（HEAD）→ `bed_after.txt`

## 方向表（跨 seed 匯總，seed=1337）

| bucket | before `0a908f5` | after `e3175e6` (A1a) | 方向 |
|---|---|---|---|
| 采樣 cadence-decisions | 1597 | 1638 | — |
| ★手≠腦 違規（viol） | 715 (44.8%) | 567 (34.6%) | ↓ |
| `arbiter_latch` | **270 (16.9%)** | **76 (4.6%)** | **↓ −72%** |
| `no_release_latch` | 40 (2.5%) | 42 (2.6%) | flat（噪音） |

兩側皆跑到 `=== hand_obeys_brain_bed DONE ===`、無 `SCRIPT ERROR`。

## 判讀

- `arbiter_latch` 270→76 = **−72%** — equal-priority self-replace 消除引擎同層被丟的 latch，
  方向 = spec 驗收#5 要求的↓。handback 引的 270/16.9% baseline **正確**（1-seed 1-month），
  QA 撞見的 437/8.1% 出自 committed `bed_baseline.txt` 的**另一 config + timeout 中斷**，非本表。
- `no_release_latch` 40→42 = **flat/噪音內**：`STATION_TIMEOUT = TICK_PER_DAY*4`（TEST VALUE）
  在 1-month 窗 aggregate 被采樣噪音蓋（handback 殘留#3、spec :89 母 spec :27 閘校正
  「跨版本 aggregate=噪音，只驗方向不追精確數字」）。release 路徑本身 file:line 證實接上
  （`faction_ai:761-764`）；縮 latch 時長非瞬時 count 差。

## 註

原 committed `bed_baseline.txt`（3-seed 4-month、`[GODOT TIMEOUT 360s]` 中斷、config 與驗收
不符）已移除——誤導 QA 的 stale artifact。原始長輸出 `bed_before.txt`/`bed_after.txt`
（各 ~3.9k 行，含 move spam）留 worktree 未追蹤 scratch；本表 tail summary 即其末段，
重現用上方指令即得。
