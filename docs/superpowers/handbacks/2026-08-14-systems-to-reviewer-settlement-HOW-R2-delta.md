---
from: systems
to: reviewer
status: open
topic: "[R² delta 審 settlement HOW(用戶核可 spec LOCKED、四訂正入版、我 HOW delta 對齊)·spec=2026-08-14-settlement-lifecycle-agriculture-HOW.md·delta 三處對四訂正:①L0 採集=短期看圖塊存糧(讀 tile 池現量、低倍單旋鈕、遊牧循環湧現[池乾就移]、再生率只定久留線非產糧公式)②S1b ★重大 reframe(訂正③④):降回『既有 settle 補全+目標池擴充』非新認領動詞、★HOW-binding 硬禁 code 只准兩處(a _tick_solo_settle 加 owner=-1 分支[抵無主營→solo 接管入住]b settle/invite 目標池納 owner=-1 outpost)、★禁新增任何搶城類 action、occupy 不碰、需新 action=停下呈報③搶鬼城競爭(訂正②):先到先得 set_owner/後到 owner≠-1 belief 過期→既有遭遇路/情報時效回報·★審點:(1)S1b 真只兩 code 點無 scope creep?(移除了原 occupy 加無主營候選=搶城 action、符訂正④)(2)owner=-1『空』判定 belief-gated 感知鐵律守?(3)L0 池現量讀法無 god-view(讀腳下 tile 池=proximate)?(4)先到先得 set_owner chokepoint 無雙認領 race?·★R②硬禁複核:S1b implementer 若冒出第三 code 點/新 action=違訂正④=halt·CLEAN→S1 plan→dispatch implementer(S1 機械修先解鎖300家)·地基KEEP"
---

# R² delta 審 — settlement HOW（用戶核可 spec、四訂正入版）

spec = `specs/2026-08-14-settlement-lifecycle-agriculture-HOW.md`。用戶已核可 design spec（LOCKED、四輪 review 訂正）。我 HOW delta 三處對齊：

## delta 對四訂正
1. **① L0 採集=短期看圖塊存糧**：讀 tile **池現量**、低倍**單旋鈕**、**遊牧循環湧現**（池乾就移）、再生率只定久留線非產糧公式。
2. **② S1b ★重大 reframe（訂正③④）**：降回「**既有 settle 補全 + 目標池擴充**」非新認領動詞。★**HOW-binding 硬禁 code 只准兩處**：(a) `_tick_solo_settle` 加 `owner=-1` 分支（抵無主營→solo 接管入住）(b) settle/invite 目標池納 `owner=-1` outpost。★**禁新增任何搶城類 action、occupy 不碰、需新 action=停下呈報**。
3. **③ 搶鬼城競爭（訂正②）**：先到先得（`set_owner`）/ 後到 owner≠-1（belief 過期）→既有遭遇路 / 情報時效回報。

## ★審點（skeptical）
1. S1b 真**只兩 code 點無 scope creep**？（已移除原 occupy 加無主營候選=搶城 action、符訂正④）。
2. `owner=-1`「空」判定 **belief-gated 感知鐵律**守？
3. L0 池現量讀法無 god-view（讀腳下 tile 池=proximate）？
4. 先到先得 `set_owner` chokepoint 無雙認領 race？

## ★R² 硬禁複核
S1b implementer 若冒出**第三 code 點 / 新 action** = 違訂正④ = **halt**。

CLEAN → S1 plan → dispatch implementer（S1 機械修先解鎖 300 家）。地基 KEEP。
