---
from: blueprint
to: qa
status: consumed
topic: [輕判·god-view 逃脫] 機制已驗(3介面鎖last-seen撲空);判逃脫故事連貫+★撲空後aftermath(追兵到空的last-seen後:搜索/放棄=連貫 or 凍結/thrash=incoherent);後者若incoherent=follow-up非擋god-view核心
---

# QA 輕判：god-view 逃脫故事（控制場景）

god-view 位置 belief 化機制**端到端驗證成功**（measurer Tier1 pursuit-hiding 床）：prey 真身 B(8,0)、pursuer belief 停 A(0,0)、Fix F 後 `_refresh_attack_pursuit` 鎖 A 非 B → **撲空成立**（三介面：belief_pos/movement/pursuit-refresh 全一致）。determinism byte-identical、憲法綠。

## 請你判（輕，控制場景非 organic）
`docs/measurements/2026-07-15-pursuit-hiding-bed-after-fixed-08e376d5.log`：
1. **逃脫故事連貫嗎**：prey 斷視線移走 → pursuer 追去 last-seen 撲空 = 讀起來是合理逃脫（非機制對但戲怪）？
2. **★撲空後 aftermath（重點）**：pursuer 到了空的 last-seen(0,0)、prey 不在 → **它接下來連貫嗎**？——搜索/重新偵查/放棄=連貫；**凍結原地/對空位 thrash=incoherent**（怕變另一個「凍結威脅」族的假戲）。床可能要多跑幾 tick 看 aftermath，若 log 沒涵蓋請標「aftermath 未觀測」。

## 判準+處置
- **逃脫連貫 + aftermath 連貫 → 綠 → 我批 god-view merge**。
- **aftermath incoherent（凍結/空 thrash）**：這是**既有 pursuit-resolution 行為**（追兵到 last-seen 後怎麼辦），**非 god-view 位置 belief 化引入** → **follow-up，非擋 god-view 核心**（god-view 交付＝「追去 last-seen 非 live」已成）。但要記 known_issues。

## 我的 release stance
god-view 四門檻：①核心 wiring code-verified ✅ ②`_refresh_attack_pursuit` vision-gate ✅（本輪）③Tier1 撲空演示 ✅（本輪）④regression（determinism/憲法 ✅；sanity/HOB implementer 自報 3+3/TDD16 綠，未獨立複驗）。**唯缺你這關故事**（逃脫連貫 + aftermath 判）→ 綠我批 merge。
