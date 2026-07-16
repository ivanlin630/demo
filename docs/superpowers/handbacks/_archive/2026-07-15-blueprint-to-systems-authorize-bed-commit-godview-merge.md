---
from: blueprint
to: systems
status: consumed
topic: [授權+merge stance] pursuit_hiding_bed進repo=YES(首個控制場景story驗證床,復用infra);god-view merge待QA逃脫故事綠(已路由);床bug是工具非遊戲(鐵律3)
---

# 授權 pursuit 床進 repo + god-view merge stance

## 授權：pursuit_hiding_bed 進 repo = YES
`scripts/debug/pursuit_hiding_bed.gd`（measurer 授權建，現 worktree 未 commit）**正式收進 branch**——這是**首個「控制場景 story 驗證床」**，零遊戲邏輯改動、可復用（後續稀有/story-central option：乞食/求和/未來都掛它，別再賭 organic seed roulette）。指示 implementer 收進 god-view 分支 + 記入 `03b_measurer.md` Tier1 床庫清單。
- 註：床自身初版兩個 bug（缺 `_initialize` 進入點→逾時、`move_teams`→`process` 方法名）＝**純工具非遊戲邏輯**（鐵律3 TIMEOUT≠迴歸），measurer 已 L3 修正、determinism 復核 byte-identical。收進去的是修正版。

## god-view merge stance
機制四門檻齊（wiring code-verified / `_refresh_attack_pursuit` vision-gate / Tier1 撲空演示 / determinism+憲法）。**唯缺 QA 逃脫故事綠**（已路由 `to:qa`：判逃脫連貫 + 撲空後 aftermath）。
- **QA 綠 → 我批 merge god-view**（`feat/position-belief` 或分支名，含 pursuit 床）。
- aftermath 若 incoherent（追兵到空 last-seen 凍結/thrash）＝既有 pursuit-resolution，**follow-up 非擋 god-view**（god-view 交付＝追 last-seen 非 live 已成），記 known_issues。

## sanity/HOB 複驗
本輪床跑未獨立複驗 sanity/HOB（implementer 自報 headless 3+3/TDD16 綠）。merge 前你判要不要 measurer 獨立複驗一輪標準閘，或接受 implementer 自報（小 code 面：Fix F vision-gate + 床 infra）。

## 序不變
god-view（收 QA 綠→merge）→ tracer-completeness（觀測 infra）→ full-HD 觀察 → 照妖鏡。求和/外交 code-verify 平行。
