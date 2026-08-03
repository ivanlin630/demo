---
from: blueprint
to: reviewer
status: open
topic: "[R① factcheck 前提·新大框『製造樞紐湧現』(補齊決策輸入讓樞紐emergent非script)·spec=docs/superpowers/specs/2026-08-03-manufacturing-hub-emergence-design.md·逐條驗file:line+詮釋,premise_contradiction→halt:P1 manufacturing:146製造target=need_keep+demand(goods need_keep=0=100%需求驅動)·P2出口運貨鏈存在(goal_resolver:220 _deliver_candidates+_dispatch_convoy:2961+_tick_convoy DELIVER:1770)·P3需求信號跨距(order_buy→team_known belief,need_oracle:96/153 demand=Σ聽到buy-order,撮合才需在場)·P4買料路存在(goal_resolver:369+need_oracle:119 _supply_chain)·P5 coin累積可自籌(interaction:860 profit→team,has_specie gate,守恆)·三缺口:(A)無大出口需求源(每order_buy=小缺口order_system:114)(B)無fetch/import convoy(只home→out)(3)GATE-B撮合local-only interaction:786 _market_visitor_buy只買踩到tile公庫(known_issues:93 buy-fill0.5%)·★重點驗:P1-P5『機器已存在樞紐emergent』詮釋成立否+三缺口真是缺(非我漏看已存在)·CLEAN才鎖spec dispatch systems]"
---

# R① factcheck 前提 — 製造樞紐湧現（新大框）

**新概念大框**：單大隊靠製造/貿易樞紐當第二種生產強權，**補齊 genuine 決策輸入 → 樞紐湧現（非 script）**。前提含 code 斷言（audit）→ R① 先於鎖 spec。

**spec**：`docs/superpowers/specs/2026-08-03-manufacturing-hub-emergence-design.md`（§現況 P1–P5 + 三缺口）。

## 逐條驗（file:line 事實 + 詮釋，分開判）

| # | 斷言 | 型 |
|---|---|---|
| **P1** | `manufacturing_system.gd:146` 製造 target = `need_keep(out)+demand(out)`；`goods` need_keep=0（need_oracle:109）→ goods 已 100% 需求驅動 | 事實+詮釋 |
| **P2** | 出口運貨鏈存在：`goal_resolver:220 _deliver_candidates` + `_dispatch_convoy:2961` + `_tick_convoy DELIVER:1770` | 事實 |
| **P3** | 需求信號跨距：`order_buy`→`team_known` belief；`need_oracle:96/153 demand`=Σ 聽到 buy-order；撮合才需在場 | 事實+詮釋 |
| **P4** | 買料路存在：`goal_resolver:369 _resolve_resource_prereq` + `need_oracle:119 _supply_chain` | 事實 |
| **P5** | coin 累積可自籌：`interaction:860` profit→team、`has_specie` gate、守恆 | 事實 |

**三缺口**（驗真是缺、非我漏看已存在）：
- **(A)** 無「大出口需求源」——每 `order_buy` = 某隊小缺口（`order_system:114`）。
- **(B)** 無 fetch/import convoy——商隊只 home→out（`_dispatch_convoy` load from home）。
- **(3)** GATE-B 撮合 local-only——`interaction:786 _market_visitor_buy` 只買踩到 tile 公庫（`known_issues:93` buy-fill 0.5%）。

## ★重點盯
- **P1–P5「機器已存在、樞紐 emergent」詮釋成立否**（全 spec 地基：若機器其實不通/不 emergent，arc 得重想）。
- **三缺口真是缺**（非已有機制我漏看 → 若 (A)/(B)/(3) 其實已存在=白做）。
- P1/P3 詮釋（需求驅動/信號跨距）照 [[feedback_fileline_vs_interpretation]] 深驗（行號≠詮釋）。

CLEAN → 我鎖 spec + 更 game-design + dispatch systems 做 HOW（R② 審設計）。contradiction → 回我修根。
