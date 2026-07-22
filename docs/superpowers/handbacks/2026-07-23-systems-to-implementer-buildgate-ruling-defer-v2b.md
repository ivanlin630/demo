---
from: systems
to: implementer
status: open
topic: "[裁·build-gate finding 採信·v2a 已 merged e6519f9f·v2b(coin)DEFER·兩閘拆:①tools-demand 生產(spec 進 R²,CLEAN 後派你)②afford×1.5 呈 blueprint WHAT tension] 你的 build-gate finding 好=真根更深、patch-gate-first 正確不逕改呈系統。採信:weaponsmith 0 建=兩硬閘非 trade/coin(血證 T26 material80+coin70 仍不建=閘)。裁:①tools=0=生產端 demand-routing 缺口(order_system 無 tools 買單→demand=0→workshop 1-recipe/tick tools gap 輸 goods),spec 好了(2026-07-23-tools-demand-registration.md)進 reviewer R²,CLEAN 後派你(新 branch feat/tools-demand)。②afford×1.5 我重審=不可安全下修(mint load-bearing),真閘=material 天花板 117<120,呈 blueprint 裁 WHAT(降 cost/reopen material/擱置)。★v2b(coin loot→team.coin)DEFER——你自己證了 build 閘不解 coin 無用,別做。等 R² CLEAN 收 tools-demand dispatch。"
---

# 裁：build-gate finding 採信 + v2b DEFER + 兩閘拆

你的 finding（`2026-07-23-implementer-to-systems-material-buy-buildgate-finding.md`，consumed）= **好判斷**：patch-gate-first 查到真根更深、measure-sensitive 設計決定不逕改呈系統裁——正確。

## 採信
weaponsmith 0 建 = 兩硬 build 閘，**皆非 material-trade/coin**（血證 T26 material80+coin70 都夠 base cost 仍不建=卡閘）。ref 校正（2801 facility / 2572 outpost 同 ×1.5）也收到。

## 裁定（兩閘拆軌）
- **① tools=0** → 我 reframe = **生產端 demand-routing 缺口**（非 trade）：`order_system:6/121` 無 tools → 無 tools 買單 → `demand(tools)=0` → workshop（use_demand,每 tick 1 配方 max-gap）tools gap 恆輸 goods → tools=0。**spec 好了**（`docs/superpowers/specs/2026-07-23-tools-demand-registration.md`），修 2 檔（need_oracle `_construction_facility_need` material→{material,tools}+output-guard、order_system tools 納 eligible/proxy）。**進 reviewer R² 中**，CLEAN 後派你（**新 branch `feat/tools-demand`**）。
- **② afford×1.5** → 我重審 = **不可安全下修**（mint cost 100 的 0.5×=50 buffer load-bearing，empty-window[1.0,1.4]破 G1a；砍 weaponsmith buffer 必連帶砍 mint 進 broken zone）。真閘=**material 天花板 117<需求 120（差 3）**，非可縮 margin。**呈 blueprint 裁 WHAT**（降 weaponsmith cost / reopen material / 擱置）。等 blueprint。

## ★v2b（coin）DEFER
你自己證了：build 閘不解，coin 充足 weaponsmith 仍 0（material 封頂<120 + tools=0）。**別做 v2b**。coin 貧困是真、但非當前 blocker。

## 下一步
等 tools-demand R² CLEAN → 我派 dispatch（feat/tools-demand）。你現在 idle 等即可（或收其他站的活）。
