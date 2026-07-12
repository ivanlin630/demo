---
from: systems
to: blueprint
status: consumed
topic: [B2真根·零跑] 統領技能成長路徑存在但被繁榮閘鎖死—P4_expand(唯一成長觸發)base 0.55僅food>100+stress<0.3+統領tag,否則0.05;絕境隊永觸不到=第三層雞生蛋;修=de-patch繁榮閘
---

# B2 統領門真根：成長路徑被繁榮閘鎖死（patch-gate 第三層）

patch-gate-first 查完。**答案=門檻+機制互鎖,但機制閘是更深根**（同 session 絕境-preemption pattern，第三層雞生蛋）。

## 統領技能怎麼漲（成長機制存在但被鎖）
1. **唯一成長路徑**：`SkillSystem.REACTION_SKILL_MAP "P4_expand":{"skill":"統領"}`（skill_system:13）——統領只經 **P4_expand reaction** 成長（`on_reaction`→`cap_add`，BASE_GROWTH=0.005×attr×毅力×mult ≈ +0.001~0.003/次）。**無其他統領 write**（grep 全 code:cap_add 只長 戰鬥/商業/製造/偵查/戰術，統領僅此 P4_expand 一途）。
2. **★P4_expand 觸發被繁榮閘鎖**（`reaction_system:_score_expand:154-161`，真根）：
   ```
   base = 0.55 if (food > 100.0 AND stress < 0.3 AND team 有"統領"tag) else 0.05
   base += 統領×0.3 + 野心×0.3 + 戰術×0.2
   ```
   - P4_expand 要贏 reaction argmax（vs N1_flee/N2_riot/P1_comply 等）才 fire → 才長統領。
   - **但 base 0.55 只給「food>100 + 低壓 + 已是統領」的隊**。絕境/餓死隊（本世界預設態）：food<<100 + 高壓 → base=0.05 → P4_expand 幾乎永遠輸給 survival reactions → **統領永不成長**。
   - `統領tag` 額外要求：獨立/非統領隊本就沒此 tag → base 0.05。

## 初始統領分布（gen）
- 程序 leader（`PersonGenerator.generate("leader")`:68-69）：`randf(0,0.3)+0.1` → **統領 ∈ [0.1, 0.4]，mean ~0.25**（player leader game_setup:343=0.15）。
- outlier roll（:74-82）少數 archetype 可高，但非常態。
- **門檻 ESTABLISH_COMMAND=0.4 − (野心−0.5)×0.2 → ~0.3-0.38**（faction_ai:977）。
- ∴ mean 初始 ~0.25 < 門檻 ~0.35 → **多數 leader 起手就不夠**，須靠成長爬過——但成長路徑被繁榮閘鎖。

## ★真根結論（第三層雞生蛋，同 session pattern）
```
要 established → 需統領 ≥ ~0.35 (B2)
統領只由 P4_expand 長
P4_expand 只在 food>100+低壓+統領tag 才 fire
但絕境隊 food<<100+高壓 → P4_expand 永不 fire → 統領凍在 ~0.25
→ 永不 established → 永遠絕境
```
**繁榮才長統領、統領才立國、立國才繁榮**——絕境隊被鎖死在門外。這是 farming(第一層)→建國A門人口(第二層)→**統領繁榮閘(第三層)** 的最深雞生蛋。同 faction-only/farming 的 patch-gate 型：**成長機制存在但 gate 在絕境隊達不到的繁榮態**。

## 門檻 vs 機制 判讀
- **不是純門檻脫real**：門檻 0.35 對「能繁榮擴張的 leader」合理（統領該練出來）。
- **不是純成長斷裂**：P4_expand→統領 機制在、會 fire（繁榮隊確實長）。
- **是機制閘 pre-empt**：成長觸發（P4_expand）被繁榮條件鎖 → 絕境隊結構性練不起來。**de-patch 對象=繁榮閘,非調門檻/調初始**（調那些是 band-aid，不解雞生蛋）。

## 修向（你 brainstorm，systems flag）
1. **★de-patch 繁榮閘（結構修，對症）**：統領成長不該只綁「繁榮擴張」。加**日常領導成長路徑**——如 faction/獨立 leader 每領導 cadence 微長統領（帶隊本身=練統領）、或**建國/組隊當下授統領 XP**（當上領袖=領導經驗躍升）、或 P4_expand base 對「掙扎但在治理」的 leader 也給部分分。拔「繁榮才長」的雞生蛋。
2. band-aid（不建議單用）：降 ESTABLISH_COMMAND / 抬初始統領 mean / P4_expand food 門檻降。治標不解鎖。

## 序
- 這是 established=0 的最深結構根（B2 100% 硬牆的機制解釋）。
- 你判 de-patch 方向（日常領導成長 / 建國授 XP / 繁榮閘放寬）→ 若改統領成長設計語意需用戶裁 → brainstorm→對抗→spec。
- 與 A 門人口（82.7%，第二層）+ 長程週期可能共享「絕境 pre-empt 建設」根,一起看。
- measurer 可實證：leader 統領實際數值分布（12mo 內爬升軌跡=幾乎不動?）坐實凍結。既有 `establishment_diagnose.gd` 床（grep 見）可能已有料。
