---
from: blueprint
to: systems
status: consumed
topic: "[★糧流感知 WHAT 定案+用戶核可·交你做 HOW(走 R②)·spec=docs/superpowers/specs/2026-07-29-runway-aware-persistence-survival-design.md·premises 全 file:line 驗過(§8)故 R① 覆核而非重factcheck、大框你要升異質 R① 框外審自便·一個糧流感官(每日算1次+快取,非每tick,內生-only)+三消費者:①存活持守(safe_ratio×人格餘裕,team14 nuance 根治)②派遣配糧(離家隊糧橋+載重,立國極端,解PARK子隊餓死)③在家前瞻(餵既有maintain_food goal加前瞻觸發→饑荒前主動擴/立/買/遷)·多為現有零件接線(burn/載重/地形回補/打獵/persist_strength/maintain_food皆現成)·後勤補給車隊排除留後續arc(自動接得住)·憲法:util偏置非scripted+接tap全量觀測·★持守release關係:此arc根治team14 nuance,release決策我另跟用戶處理別搶跑] 糧流感知WHAT定案。腦手在糧食軸接線:每隊一個糧流感官(net=inflow−burn,runway),三消費者共用。內生-only(外生純賺不預測)解『賭施捨/過去猜未來』。立國=派遣消費者的極端非特例。means-end maintain_food現成故在家前瞻不暴增。你做HOW+R②+切slice。premises §8全驗。"
---

# ★糧流感知 WHAT 定案 → 交你做 HOW

## Spec
`docs/superpowers/specs/2026-07-29-runway-aware-persistence-survival-design.md`（用戶核可）。

## 一句話
給每支隊一個**糧流感官**（每日算一次、快取、內生-only），三消費者共用，把盲目死守變算過的賭、把「等餓死才反應」變饑荒前前瞻，順手解立國餓死。

## 骨架
- **感官**：`net = inflow − burn`；`runway`。**每日 cadence 算一次 + 快取在 team**（非每 tick，糧流是每日量）。**inflow 只算內生**（這格可持續產出+打獵），外生（trade/母隊/盟友）不預測、只在真到帳以存糧漲現身。
- **三消費者**：
  - **①存活/持守**：`persist_strength` 被 `safe_ratio(=runway÷ETA)` 調制，人格=餘裕門檻（慎重厚早撤/莽薄賭過頭真餓死）。**team14 nuance 根治**。
  - **②派遣/配糧**（離家隊）：出發點糧橋（橋長×(burn−沿路打獵)）配糧 go/no-go + 載重限（接現成 `movement_system` 馬車模型）+ 半路真斷才撤。**立國=極端示範非特例**，解 PARK 的子隊遠征餓死。
  - **③在家前瞻**：糧流下坡（net<0 且 runway<計畫視野）**加前瞻觸發**餵**既有** `maintain_food` goal（`goal_registry.gd:16-40`）→ 既有 planner 拆成擴/立/買/遷。**給既有 goal 加感測觸發，非新 planner。**

## HOW/R② 給你
- **premises 全 file:line 驗過（§8）** → R① 是**覆核**而非重 factcheck；大框你若要升異質 R① 框外審自便（矩陣新維度、觸多子系統）。
- 多為**現有零件接線**（burn/載重/地形回補/打獵/crisis-免疫/persist_strength/lean/maintain_food 皆現成）。
- **後勤補給車隊排除**（現只出發一次性分家 `subteam_system.gd:36-42`），留後續 arc，本設計自動接得住。
- **憲法**：util 偏置非 scripted、人格 weigh 非 gate、更不凍；**糧流狀態+配糧決策+前瞻觸發全接 tap**（撐 QA 逐 tick 稽核）。
- 開放調參見 §7（safe_ratio 人格門檻、計畫視野、可持續 inflow 估法、cadence tick 值、warmup、沿路打獵估法）。

## ★持守 release 關係（別搶跑）
此 arc **根治 team14 nuance**（用戶暫緩 release 的那個）。**release 決策我另跟用戶處理**——你別因這個 arc 就 mark 持守 release-done 或 un-PARK material，等我回。material 續 PARK。

## 序
你 HOW spec → R②（CLEAN）→ 切 slice → dispatch。有 HOW 層設計選擇要我 WHAT 拍板的回我。

## 溯源
`2026-07-28-qa-to-blueprint-persistence-nuance-distribution-verdict`（team14 個案，nuance 根在腦手糧食軸沒接線）；brainstorm 收斂（內生-only/糧橋/載重/三消費者/每日 cadence，用戶逐點戳實）。
