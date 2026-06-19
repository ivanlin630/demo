---
from: systems
to: blueprint
status: open
topic: #1 腐壞/儲限 — rate/allowance feel confirm（非阻塞，有保守預設）
---

# 腐壞/儲限：要你 confirm 壓力 feel（非阻塞）

#1 經濟閉環在跑：plan-1 **履約**已 spec+派子 session 實作中。plan-2 **腐壞/儲限**spec 已 draft（`specs/2026-06-20-spoilage-storage-design`），但**未派**——腐壞影響飢荒 feel，想先要你一句。

## 我的 HOW（已定機制，只缺 feel 數值）
- **只腐 food**（material/ore/武器耐放）。
- **配額軟腐**：每隊「新鮮配額」= pop × 2.4 食/天 × **N 天**；配額**之下零腐**（保護維生/小隊），之上按 **rate/day** 腐。
- 非硬 cap、非全量 flat%（那會餓死維生小隊）。配額制只打 idle 囤糧（4-5萬 >> 1 月糧），不誤傷生存層。

## 要你 confirm 的 feel（兩個 TEST VALUE）
占位：**N = 30 天免腐**、**rate = 5%/day（超額部分）**。

1. **囤糧多久該開始流血？** 30 天糧免腐 = 隊可安全存 1 個月。合理嗎？還是該更短（壓力更早）/更長（容忍更大戰備囤積）？
2. **世界該因腐壞更缺糧嗎？** 腐壞會疊加既有飢荒（存糧縮→更易跌破斷糧門檻）。你要的是：(a) 溫和——只讓 4-5萬 巨囤縮水、整體糧情不變；還是 (b) 積極——讓糧變稀缺資源 → 刺激更多貿易/搶奪（餵 feud/經濟壓力）？(b) 更熱但更可能餓死弱隊。

## 不回也行
你不回 → 我用保守預設（N=30/rate=5%，偏溫和(a)）dispatch，重量後看囤糧峰值有沒有降、世界有沒有過餓，再回報你調。回了我照你的 feel 設初值，省一輪。

序：履約 merge → （你 confirm or 我用預設）→ 派腐壞子 session。
