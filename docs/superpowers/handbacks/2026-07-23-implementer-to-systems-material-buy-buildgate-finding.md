---
from: implementer
to: systems
status: consumed
topic: "[finding·material-buy 真根更深=build 閘非 trade·patch-gate-first·v2b 前請裁] weaponsmith 0 建卡兩硬閘皆非 material-trade/coin:①facility afford×1.5 實在 faction_ai:2801(非 verdict 引的 2572=outpost 閘,同 ×1.5)→material 120 vs 隊封頂~117 差3 ②tools=0 全域,source=workshop(3205,civilian-only)但 weaponsmith military-only=cross-outpost-type 供給缺口。血證:baseline T26 material80+coin70 都夠 base cost 仍沒建=閘非供給/錢。∴我計畫 v2b(coin)也建不了。請裁 afford×1.5 對 facility 是否過嚴(×1.3=104 可達)+tools 產/取鏈設計,再定 v2b 序。"
branch: feat/material-buy
commit: 1076c0d5
---

# finding：material-buy 真根更深 = build 閘非 trade（patch-gate-first）

measurer v2a 量測 + 我獨立 code-confirm。**v2a 三修有效但 weaponsmith 仍 0 建**——真根比
trade/coin 更深，卡兩硬閘皆**非 material-trade**。[[feedback-patch-gate-first]][[feedback_no_patch_on_settled_architecture]]
→ 呈報系統裁，**不逕改**（afford×1.5/tools 鏈=measure-sensitive 設計決定，非補丁層）。

## v2a 本身 = 真進度（measurer verdict→blueprint）
- ①full-need：mil material peak T28=**117**（baseline 全場最高 98）稀釋修對。
- ②util 繫建設：買料 chosen 80-307 競得過。
- ③food-ok gate：extinct.starve **0** 無餓死回歸。determinism 採信、無迴歸。
- measurer 建議可作**增量 merge**（累積推高+food-safe）。

## ✗ 但 weaponsmith 0 建 = 兩硬閘（皆非 trade/coin）
### 閘① facility afford ×1.5 — ★ref 校正
- **實在 `faction_ai_system.gd:2801`**（`_dispatch_facility_builder`：`if avail < float(cost[k]) * 1.5: return false`）。
  measurer verdict 引 `:2572` = **OUTPOST_COST 建 outpost 閘**（`OUTPOST_COST[type][level-1]`），
  weaponsmith 是 **facility upgrade** 走 2801。**兩處同 ×1.5**，結論不變（僅 ref 校正）。
- weaponsmith material 80 → 需 **120**。v2a 隊 material 封頂 ~**117**（full-need 最高 T28=117）→ **差 3 不可達**。

### 閘② tools=0 全域
- weaponsmith 需 tools 3（×1.5=**4.5**）。tools source = **workshop**（`faction_ai:3205`
  `"workshop": {"outputs": ["goods","tools","arrows"]...}`），但 workshop **civilian-only**
  （`OutpostSystem.FACILITY_DEF.workshop.allowed_outpost=["civilian"]`）；weaponsmith **military-only**。
- → **cross-outpost-type 供給缺口**：military 隊建 weaponsmith 卻無 workshop 產 tools，
  且無 material-trade 式的 tools 取得路徑 → tools 恆 0 → afford tools 條件恆 fail。

### 血證（measurer）
baseline **T26 material80 + coin70**（都夠 base cost）**仍沒建** → 卡閘非供給/錢。

## ∴ 我計畫的 v2b（coin loot→team.coin）解不了 build
即便 coin 充足，team material 封頂 ~117<120 + tools=0 仍擋 weaponsmith。

## 請裁（HOW owner）
1. **afford×1.5 對 facility 是否過嚴**：120 vs 隊封頂 117（×1.3=104 可達）。統一 buffer 還是 facility 該降？
2. **tools 產/取鏈**：military 隊 tools 供給——workshop 跨 outpost-type 供給？tools 納 material-trade 式買？
   還是 weaponsmith cost 去 tools？（全域 tools=0=產鏈斷點）。
3. v2b（coin）序：build 閘不解，coin 修完 weaponsmith 仍 0 → 建議 **build 閘先於 v2b**。

裁定後派 spec。v2a 可增量 merge（等 blueprint verdict）。
