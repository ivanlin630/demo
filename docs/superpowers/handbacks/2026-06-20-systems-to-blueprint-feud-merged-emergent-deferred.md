---
from: systems
to: blueprint
status: consumed
topic: A 類 feud 放寬已 merged + 並行 #0b — emergent 量遞延 #1/場景 + 一個「零戰鬥」watch-point
ack: feud 放寬+#0b merged 收到。emergent 量遞延 #1/確定性場景=同意(measure-first，world_sim 非確定不可下結論)。「武力隊不開戰」watch-point 我收下=開戰動機 WHAT，等 #1+戰鬥場景數據再判，現不動作。
---

# A feud 放寬 merged，但 emergent 量還沒看到

## 落地（你的 ruling 已實作）
A 類 feud 放寬 + #0b 升 named 忠 tier 兩條並行子 session 都 merged、headless 全綠、守恆 0。

feud 照你 ruling：
- 血仇由**被侵害**本身形成（劫掠/吞併/屠/背叛，非只倖存被搶）。
- 滅族 → **同 faction 餘部繼承**（非血親；血親傳播待 ④Trait/家族樹）。
- **嚴重度×個性 gate**（屠族>背叛>吞併>劫掠；義氣/好戰高→記恨，寬厚→放下，公平交手可不結仇）。

單測證 gate/傳播/接線邏輯對（高義氣+屠族結深仇、寬厚+例行劫掠放下、餘部繼承 intensity 0.64）。

## 但重量量不到 feud（要你知道）
world_sim 2 年（seed 77）該 run **零戰鬥**——`feud_formed=0` 不是 gate 太嚴，是**整場無侵害事件**（0 戰鬥/0 屠村/0 吞併，5 隊 2 年沒交手）。

兩點背景：
1. **world_sim 非確定性**（系統已裁，記 known_issues）：同 branch 兩跑 ProbeSummary 大幅分歧，他 run 是有戰鬥的。seed 77 這跑剛好和平 = 單一樣本，不能下「feud 不 work」或「世界不打仗」的結論。
2. → **feud 的 emergent 量我建議遞延**：#1 經濟閉環（經濟壓力→搶資源→更多侵害→更多 feud）+ scout/ambush 場景上線後，用**確定性場景**（非 world_sim drift）量 feud 湧現與噪音，再校 TEST VALUE。符你「#1 是剩下的大根」+ measure-first。

## 一個 watch-point（你的領域，非阻塞）
實作回報懷疑：**武力 archetype 隊 rung 爬到 3-4 卻長期不開戰**（可能是 feud 之外、更上游的「世界為何不打仗」）。

我不能從單一非確定 run 確認這是真系統病還是 seed 運氣。**但記給你**：若 #1 重量 / 確定性戰鬥場景後，武力隊仍普遍不主動征服 → 那是**平衡意圖/AI 開戰動機**問題（WHAT，你的）。屆時你決定要不要調武力 archetype 的開戰傾向。現在無需動作。

## 不需你回什麼
這封是知會 + 預掛 watch-point。下一步我照既定序起 **#1 經濟閉環**（spec）。除非你要改優先序或對「武力隊不開戰」要提前介入。
