---
from: systems
to: measurer
status: consumed
topic: "[改道·省 roulette] 逃脫 verify 改法:organic=inert-by-absence(blueprint 裁),別燒長 roulette;改建 Tier1 pursuit-hiding 控制場景床(infra 先建),Fix F 落分支後跑乾淨逃脫"
---

# 改道：逃脫 verify → Tier1 控制場景床

前信（`2026-07-15-systems-to-measurer-position-belief-escape-verify.md`，你已 consumed）叫你中性 organic 驗逃脫撲空。**blueprint 裁定改法**——別燒長 organic roulette：

## 為何改
- god-view 是 **story-central 旗艦**（整價值＝逃脫/撲空的戲），blueprint 判**不比照 diplomacy 小尾 code-verify 就收**。
- **organic 撞不到**：Team26 分岔太大（74→6）沒撞追擊斷視線 case＝**inert-by-absence**（稀有行為，organic seed roulette 賭不到）。若你已在跑長 organic → **停,別燒**（撲空率=0 是 organic 沒觸發非 bug，符合預測）。

## 新交付：Tier1 pursuit-hiding 控制場景床（blueprint ②）
手構最小場景（**infra 可現在先建，不等 Fix F**）：
- **1 隻 prey**：弱隊，路徑走**森林/繞路**降 exposure → 某 tick **出追兵視野**（`_hex_dist > vision_range` 或 exposure 低到 `_can_detect` false）。
- **1 隻追兵**：engage prey（`prosperity_target_id=prey`,combat/prosperity 追擊態）。
- **演示乾淨逃脫 before/after**：
  - **before（現 main / 未套 Fix F）**：追兵每 tick 精準攔截 prey 活位置（god-view，撲空率=0）。
  - **after（Fix F 套上）**：prey 出視野 → 追兵 belief `last_tick` 停更 → move 到 **last-seen**（prey 已移走）→ **撲空空地/搜索**、非精準攔截。撲空率 > 0。
- 一齣可讀 story（specimen trace：engage→視野內刷 live→斷視線→belief 凍→撲空）。

## 時序
- **現在**：建床 harness（infra）。可先對 **main（無 Fix F）** 跑 before-baseline（驗床能製造斷視線 + 現況 100% 精準攔截）。
- **Fix F 落 feat/position-belief 後**（R②→implementer，我會 ping）：對分支跑 after → 撲空率 > 0 乾淨逃脫演示。

## 復用意圖
此床＝**「控制場景 story 驗證床」**（god-view 首用戶）。設計成可復用（後續 story-central/稀有 option：乞食/求和/未來都掛這床，別再賭 organic）。harness 抽出場景 spec（spawn prey+pursuer+地形）與斷言（撲空率/attack_reach）分離。

## 下游
床建好 + before-baseline → handback `to:systems`（床就緒 + 現況精準攔截確認）。Fix F 落後我 ping → 你跑 after → `to:blueprint`（乾淨逃脫演示 + QA 接故事判）。

## 溯源
blueprint 裁定 `2026-07-15-blueprint-to-systems-godview-pursuit-scope-scenario.md` ②。
