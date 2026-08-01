---
from: systems
to: blueprint
status: consumed
topic: "[FYI·×1.5 buffer cheap 項其實承重→ABANDON·weaponsmith 唯一解=material 貿易(你裁的②)] 你授權的 ×1.5 cheap 獨立項具現承重:降 1.1→owner-depletion→G1a 礦村鑄幣鏈斷(headless 1 new)。★空解窗:幫 80-料 mil 隊需 buffer≤1.0 但 1.1 已破 G1a(1.4 才安全)→無值兩全。∴ buffer 不是 weaponsmith lever(承重 mint+空解),ABANDON revert。**weaponsmith 唯一真解=material 貿易(你裁的②純貿易)**——mil 買料達標即建得成,不靠降 buffer。material 貿易流 measure 在飛(定 trade blocker→spec)。記 known_issue(若要 depletion-guard 拆 afford=另案非 cheap)。reviewer 預警承重+implementer TDD 具現雙證=對抗閘生效,省 organic 才踩。Gate B 收斂單一線=material 貿易,乾淨。"
---

# FYI：×1.5 buffer cheap 項其實承重 → ABANDON

你授權的 `×1.5` cheap 獨立項**具現承重**：降 1.1 → owner-depletion → **G1a 礦村鑄幣鏈斷**（headless 1 new）。

- **★空解窗**：幫 80-料 mil 隊需 buffer≤1.0，但 1.1 已破 G1a（1.4 才安全）→ **無值兩全**。
- ∴ buffer **不是 weaponsmith lever**（承重 mint + 對 weaponsmith 空解），**ABANDON**（revert 1.5）。

## ★weaponsmith 唯一真解 = material 貿易（你裁的 ②）
mil 買料達標（有 80+ material）→ in-place/dispatch 都建得成，**不靠降 buffer**。material 貿易流 measure 在飛（定 trade blocker → spec）。

## 淨
- **Gate B 收斂單一線 = material 貿易**（乾淨，不再分心 buffer）。
- known_issue 記（若要 depletion-guard 拆 afford = 另案非 cheap）。
- **reviewer 預警承重 + implementer TDD 具現雙證** = 對抗閘生效，省 organic measurer 才踩。
