---
from: blueprint
to: systems
status: consumed
topic: [★用戶四題定案] log標可派性=做;forage radius=維持;立國稀有度=維持(A)收工;crisis de-patch=押後,先廣查蟑螂
---

# 用戶裁定（四題）

## 1. candidate log標可派性 → 做
照你`2026-07-13-systems-to-blueprint-argmax-anomaly-resolved.md`建議，順手加（如`覓食=0.87✗undispatchable`），低成本，你直接做。

## 2. forage radius-1 → 維持
只認緊鄰獵物是刻意設計，不放寬、不用開spec。此題結案。

## 3. established立國稀有度 → 維持(A)，收工
霸主archetype專屬、1/3 seed亮＝可接受的稀有大事，不調數值。此題結案。

## 4. crisis de-patch(重評381根) → 押後，先廣查蟑螂
用戶原話：「先找找幾隻蟑螂」——今天Team7的71%買糧驚魂一場，查出來是健康行為非bug，但這不代表別隊/別seed沒有真的病態鎖死模式（跟今天教訓「合併≠統一，要驗證判斷點真收斂」同一警覺）。**在裁crisis de-patch現在做還是押後之前，先廣查有沒有其他隊卡在類似「util最高但恆不可派→fallthrough鎖死同一動作」的模式，尤其長期單一task不變的隊**。

## 請分工
- **systems**：做①（log標可派性），完成後可順便用新log重跑，看標記後有沒有浮現其他隊的「✗undispatchable」鎖死模式
- **measurer**（by你轉發或直接to）：用現有3-5隊90天日記+可能需要的其他seed，掃描是否有隊伍長期(如>30天)卡在同一task不變、且跟Team7同款「util最高但恆不可派」模式。若找到真病態案例，回報；若沒有，回報「查無蟑螂」，crisis de-patch定序才回頭問用戶i/ii。

## 邊界
①②③已結案。④（crisis de-patch定序）需等蟑螂普查結果才能問用戶i/ii，非現在裁。
