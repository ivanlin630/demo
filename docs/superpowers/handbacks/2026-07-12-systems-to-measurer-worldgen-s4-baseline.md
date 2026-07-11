---
from: systems
to: measurer
status: consumed
topic: [§4重baseline] world-gen merged 9156f6f—seeded_warring_bed baseline重生(標位移非迴歸)+深度長跑參照(2seed×12月/1年全探針,用戶定,非18seed廣度)
---

# §4 重 baseline：world-gen variety merged（`9156f6f`）

world-gen variety 已 merge main。**§1 據點 seeded 散布改動所有 config 的起點位置**（scatter 對 warring_states 控制床也生效,非只 default）→ 既有 `seeded_warring_bed` baseline 位置位移。

## 要你做
1. **`seeded_warring_bed` baseline 重生**：main `9156f6f` 上重跑 `WARRING_OUT` dump,新 baseline **標「world-gen variety 位移,非迴歸」**（emergence 硬斷用新基線,別把位移誤判 regression）。
2. **★深度長跑參照（用戶定:2 樣本 × 12 月/1 sim 年,非 18-seed×3mo 廣度）**：用戶要的是**長程湧現深度樣本**,非跨 seed 廣度。
   - **2 seed × 12 sim 月（1 年）全探針**（全維度探針開:經濟/征服/人口/戰鬥/perf/coin/invariant 全打點）。
   - 目的=**看長程湧現**:世界撐不撐得住、經濟/征服弧有沒有跑完展開、人口曲線(漸疏/崩/穩)、late-game O(N²) perf 走勢(對照 known_issues LOD 評估)。18-seed×3mo 短窗看不到這些。
   - **detach+resume 跑**（後段隊多變重,GODOT_TIMEOUT 加大;粗估 24 seed-月 ~56min 基線 ×2-4 後段 = 1-2.5hr）。存檔標「world-gen variety 新基線參照(深度)」。異常維度(perf 塌/人口崩/弧不展開)標回 systems/blueprint。
   - config:default.json（玩家實際世界,§2/§3 放野）跑深度=看真實開局長程;若要 control 對照另跑 warring_states 亦可,但**深度樣本以 default.json 為主**（那是玩家玩的）。

## 註
- 控制床（warring_states）§2/§3 count/faction 仍釘死（42/8）,只 §1 位置變 → baseline 差異應限於位置/連帶湧現,非 count 爆炸。
- determinism 已驗（含 fallback byte-identical）,重跑同 seed 應穩定。
數字/存檔位置 → to:blueprint（新基線登記）。
