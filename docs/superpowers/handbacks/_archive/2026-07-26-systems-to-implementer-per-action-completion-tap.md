---
from: systems
to: implementer
status: consumed
topic: "[實作·cheap per-action-type completion 計數 tap·決定 A1 閉沒(新 outpost 'build' 真 0 還是抽樣 missed)·加到 branch feat/construction-commitment-latch(latch 在)·blueprint 序] blueprint 6mo 判 latch=部分改善非閉 A1:16/16 抽樣 completion 全 action='upgrade_facility' 零 'build'(新 outpost founding)=A1 核心未坐實(可能真 0/可能 8-cap 抽樣 missed)。加 cheap per-action-type outpost_built 計數 tap 100% 確認 build completion 真 0 否。★純觀測禁 RNG。閘:headless 0-new+gate 74+determinism 3跑 byte-identical。→measurer measure 分 action。"
branch: feat/construction-commitment-latch (續 5b166eb1，latch+resume 在)
---

# 實作：per-action-type completion 計數 tap（決定 A1 閉沒）

**續 latch branch**（`feat/construction-commitment-latch` 5b166eb1，latch+resume 在——因要量測 latch 下新 outpost `'build'` completion 是否真發生）。

## 為何
blueprint 6mo 雙 seed 判 latch=**部分改善非閉 A1**：**16/16 抽樣 completion 全 `action='upgrade_facility'`（既有 outpost 升設施），零筆 `'build'`（新 outpost founding）** = A1 核心（新 outpost 真建成）未坐實。但抽樣 8-cap 無法 100% 排除「`'build'` completion 有發生只是沒抽到」。∴ 加 **aggregate per-action-type 計數**（非抽樣）100% 確認。

## 要做（cheap，純觀測）
`_complete_construction`（`outpost_system.gd`）已有 `construct.complete` bump + sample。**加 per-action-type aggregate 計數**：
```gdscript
# ★per-action-type completion 計數(A1 閉沒硬確認:'build'=新 outpost founding vs 'upgrade_facility'/'upgrade_level'/'demolish')
if Probe.enabled:
    Probe.bump("construct.complete")                       # 既有
    Probe.bump("construct.complete_" + str(action))        # ★NEW: complete_build / complete_upgrade_facility / ...
    ...既有 sample...
```
- action 已在 `_complete_construction` 開頭取（`tile.construction_target.get("action","")`）。
- **whitelist**：warring_harness `PROBE_KEYS` 加 `construct.complete_build` / `construct.complete_upgrade_facility` / `construct.complete_upgrade_level` / `construct.complete_demolish` / `construct.complete_crude_camp`（否則漏收，同前 obs-tap 款）。
- ★純觀測禁 RNG（`if Probe.enabled` gate，禁 randf/randi）。

## 閘 + 交付
- headless 0-new + `constitution_gate` sites=74 removed=0 + determinism 3跑 byte-identical。
- handback `to:measurer`：跑 A1 focused（seed1337/42，6mo，base=此 tap branch）→ dump **`construct.complete_build` aggregate count**（非抽樣）→ **`'build'` completion 真 0 還是 >0**（決定 A1 閉沒）+ per-action-type 分布。→ 數字 `to:blueprint`（帶用戶序：(a) 轉手統一 arc / (b) 若 build>0 只抽樣 missed 則重估）。

## 不做
行為修（latch/resume 已在 branch，不動）。本刀只加 completion 計數 tap。latch branch **hold 不 merge**（blueprint 定，待 per-action-count + 用戶序）。
