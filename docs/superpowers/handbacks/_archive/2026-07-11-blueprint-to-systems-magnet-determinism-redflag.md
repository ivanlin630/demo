---
from: blueprint
to: systems
status: consumed
topic: [determinism 紅旗·先查] trace 場景E util 因加場景F code 而變(0.82→1.22)=狀態洩漏?床-local還是決策-code;查清才進多seed
---

# 呈報 systems：名聲磁鐵 trace determinism 紅旗 — 先查根因

## 好消息（磁鐵機制過）
控制場景掃描證：`protector_rep` 驅動歸附，翻盤點 ≈0.23，低 rep→逃（避暴君）、高 rep→投（偏仁君），雙端對。**磁鐵決策層級因果確認。**

## 紅旗（measurer §27，先查再往下）
同一床 `consolidation_decision_trace.gd`：**只在腳本尾端新增場景 F 的 code（未碰場景 A-E 邏輯），場景 E 的併入 util 卻從 0.82 變 1.22**（跨兩次 run）。
- **一個值因無關 code 變 = 狀態洩漏**，違 determinism 硬不變量（回歸 diff 全靠它）。
- 可能：(a) **床-local**——F 的 WorldState 構造/setup 汙染 E（shared static、未 reset 的 bank、RNG 流位移、`DecisionContext.gather` 讀到跨場景殘留）。(b) **更糟——決策 code 讀了某 global/static 被 F 動到**（真 sim 也會有 determinism 洞）。
- F 掃描內部一致（5 點同一次 run）→ 定性結論不受影響；但**絕對值不可信**到查清。

## 要你（+measurer）
1. **根因**：E 值跨 run 變的來源（file:line）——床跨場景沒隔離 vs 決策 code 狀態洩漏。診斷通則：值不該變卻變 → 查狀態源，非猜。
2. **判性質**：(a) 床-local → 修床隔離（每場景 reset/獨立 state），真 sim determinism 無恙。(b) 決策-code 洩漏 → 真 bug，修（且可能影響所有既往量測的可信度，要評範圍）。
3. 查清 + 分類回 blueprint。

## 為何先查（不急著多 seed）
多 seed robustness 是磁鐵下一關，但**建在會飄的量測基座上=白測**。determinism 紅旗便宜、必查，先清。**機制定性已過，不趕**。

## 序
- systems+measurer 根因 → 分類（床-local/決策-code）→ 修 → 回 blueprint。
- 清了才進：organic 多 seed（驗真世界裡 rep 升得夠高 + 弱隊真湧向仁君 → 聯邦成形）。
- a/b/c 續按住。

先查根因。
