---
from: systems
to: implementer
status: consumed
topic: observer 後續——#2 設施顯示全欄(非零) + #1 據點列表面板（feat/observer-inspect 續做）
---

# observer 續：設施全欄 + 據點列表

worktree `feat/observer-inspect`（接 15b6de7）。用戶手驗抓兩項。read-only，自決 seam（同原 slice 免 reviewer）。

## #2 設施顯示全欄（真缺陷：原只露 weaponsmith）
`query_outpost`（`observer_query_api.gd`）現只回 `weaponsmith_level`（單一）。8 設施都真實建（`outpost_system.gd FACILITY_DEF`，`upgrade_facility` 施工設 level）。改：
- `query_outpost` 回 **`facilities_nonzero`**：iterate `OutpostSystem.FACILITY_DEF`，取各 `current_level_key` 的 tile level，**>0 才收**（DRY=用 FACILITY_DEF 當權威，未來加設施自動出）。移除單獨 `weaponsmith_level` 欄（併入）。
  - 8 設施 key→中文：farming=農場 / workshop(manufacturing_level)=工坊 / apothecary=藥坊 / mint=鑄幣坊 / stable=馬廄 / smeltery(smelter_level)=冶煉廠 / weaponsmith=武器坊 / armorsmith=護甲坊。標籤映射抽 const（或複用 FACILITY_DEF 補中文名欄，實作自決）。
- panel（`observer_inspect_panel._render_outpost_detail` + team 附段 `_outpost_lines`）：設施行改列 `facilities_nonzero`（「設施：農場Lv2 冶煉廠Lv1」或分行）；空則「（無設施）」。

## #1 據點列表面板（UX：免逐隊翻找）
現只能點隊列表逐個看誰駐據點。加**據點列表**（鏡射 `ObserverInspectPanel` 的 team list 模式）：
- `ObserverQueryApi.query_all_outposts(state) -> Array`：iterate `state.world.tiles`，`outpost_type!="" and outpost_level>0` 的 → 一行摘要 dict（tile_pos/type/level/owner_label/faction/主要設施 or 設施數）。sort by tile_id 穩定。
- `ObserverBridge.query_all_outposts()` wrapper。
- UI：`ObserverInspectPanel` 加第二 `ItemList`（據點清單，標題「據點」），或新 `ObserverOutpostListPanel`（實作自決；傾向同 panel 加 tab/區塊省 layout）。點列表項 → `select_tile(tpos)`（複用既有據點詳情路）+ 地圖同步高亮該格（可選）。
- 與隊列表並存，互不干擾 sentinel（點據點列表→`_selected_tile` 設、`_selected` 清，既有互斥契約）。

## 驗
- `--headless --import` 綠；query 層測補：`query_outpost.facilities_nonzero`（建多設施的 tile 驗全出）、`query_all_outposts`（civ+mil 各若干 → 列表非空、非據點不入）。
- GUI 手驗交用戶：據點列表可瀏覽點選、詳情見全設施非零。

## 完後
handback to:systems status:open。read-only 不動 sim。
