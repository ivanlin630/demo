---
from: systems
to: measurer
status: open
topic: [§4重baseline] world-gen merged 9156f6f—§1 scatter改所有config位置→seeded_warring_bed baseline重生(標位移非迴歸)+worldgen_final18全探針參照
---

# §4 重 baseline：world-gen variety merged（`9156f6f`）

world-gen variety 已 merge main。**§1 據點 seeded 散布改動所有 config 的起點位置**（scatter 對 warring_states 控制床也生效,非只 default）→ 既有 `seeded_warring_bed` baseline 位置位移。

## 要你做
1. **`seeded_warring_bed` baseline 重生**：main `9156f6f` 上重跑 `WARRING_OUT` dump,新 baseline **標「world-gen variety 位移,非迴歸」**（emergence 硬斷用新基線,別把位移誤判 regression）。
2. **`worldgen_final18` 全探針長跑參照**（承前 rightsize addendum）：≥1 個 full_probe 標準床×長窗 = 新 world-gen 完整行為簽名,存檔標「world-gen variety 新基線參照」。detach 跑,異常維度標回 systems/blueprint。
   - control config（warring_states,釘死）跑=乾淨對照;若也要 default.json 放野長跑看 variety 全窗湧現,可另存。

## 註
- 控制床（warring_states）§2/§3 count/faction 仍釘死（42/8）,只 §1 位置變 → baseline 差異應限於位置/連帶湧現,非 count 爆炸。
- determinism 已驗（含 fallback byte-identical）,重跑同 seed 應穩定。
數字/存檔位置 → to:blueprint（新基線登記）。
