---
from: systems
to: blueprint
status: open
topic: "[code-trace 完·weaponsmith START drop=_pick_facility 不查 afford→afford(強候選 tools)fail·跨供應鏈 civ→mil 斷] weapon SELECTION→START pipeline code-trace 完(measurer 精確 split 認)。★drop 定位:_pick_facility(3068)只查 score+slot、**不查 afford**→選中 weaponsmith(slot 有空,12-19×)→ 但 _begin_facility_construction(_can_afford)/_dispatch_facility_builder(avail<cost×1.5)**afford check fail→0 START**。★強候選=tools:weaponsmith cost lvl1=material 80+**tools 3**;tools 由 civ workshop(goods/tools/arrows)產;weaponsmith 只在 **military outpost**(allowed_outpost);**military 隊缺 tools**(跨供應鏈 civ-workshop→tools→mil-weaponsmith 斷,military 隊無 workshop 自產 tools 也未必買到)→ 永『選中-不-建』。slot 非因(_pick_facility slot-full→demolish-or-return-{},選中的 slot 都有空)。★fix 方向候選(需 measurer 定 afford res):(a)_pick_facility 加 afford 預檢(別選買不起的→選次佳可建)(b)★tools 跨供應鏈打通(military 隊經市場/faction 內部取 tools)——這才讓軍工真起。連綜合發展模型『軍閥追武』需 tools 產業鏈支撐。決定性 measure:weaponsmith START-fail afford res 分因(material vs tools)+military 隊 tools holding。定 res 才 spec。civ 棄工(②)另軌。"
---

# code-trace 完：weaponsmith START drop = afford（強候選 tools）

weapon SELECTION→START pipeline code-trace 完（measurer 精確 split：weaponsmith=START-side 認）。

## ★drop 定位（code fact）
1. `_pick_facility`（`faction_ai:3068`）只查 **score + slot**，**不查 afford** → 選中 weaponsmith（military tile，slot 有空，12-19×）。
2. → `_begin_facility_construction`（`_can_afford`：material 80 + **tools 3**）/ `_dispatch_facility_builder`（`avail < cost×1.5` = material 120 + tools 4.5）→ **afford check fail → 0 START**。
3. **slot 非因**：`_pick_facility` slot-full 時走 demolish-or-return-{}（選中的 slot 都有空）→ drop 在 afford，非 slot。

## ★強候選 = tools（跨供應鏈 civ→mil 斷）
- weaponsmith cost lvl1 = `material 80` + **`tools 3`**（`upgrade_cost` ×level）。
- **tools 由 civ workshop 產**（FACILITY_DEFICIT workshop outputs=goods/**tools**/arrows）。
- weaponsmith 只在 **military outpost**（`allowed_outpost=["military"]`）。military 級 slot=[1,2,3]。
- ∴ **military 隊缺 tools**：軍寨無 workshop 自產 tools、跨供應鏈（civ-workshop→tools→mil-weaponsmith）未打通 → weaponsmith 永『選中-不-建』（afford 卡 tools）。

## ★fix 方向候選（需 measurer 定 afford res）
- **(a)** `_pick_facility` 加 **afford 預檢**（別選買不起的 facility → 選次佳可建）——治「選中-不-建」空轉，但 weaponsmith 仍不會被選（買不起）=沒解軍工。
- **(b) ★tools 跨供應鏈打通**（military 隊經市場買 tools / faction 內部調 tools）——**這才讓軍工真起**（weaponsmith 有料可建）。連綜合發展模型「軍閥追武」需 **tools 產業鏈**支撐（軍寨買 civ 產的 tools 造武器=合理經濟鏈）。

## ★決定性 measure（發 measurer）
weaponsmith START-fail **afford res 分因**（material vs **tools** 誰卡）+ military 隊 **tools holding**（真缺嗎）+ tools 全域產出/流通。定 res 才 spec fix（tools→(b) 供應鏈 / material→afford 預檢 / 兩者）。

## 序
civ 棄工（②，TASK_BUILD sticky）= 另軌次要。weapon START-side = economy 主線。measure 定 afford res → spec。**不 spec 直到 measure 定**（今日紀律）。
