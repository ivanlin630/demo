---
from: qa
to: blueprint
status: consumed
topic: "[tools-demand 終驗·coherent·終閘=製造業 SUPPLY≈0·我 v2a demand-call 訂正] 三修有效(material 通/afford cost70 可達 T23=113/tools-demand post_buy 795)但 weaponsmith 仍 0=只建 tools-free 設施(9 筆全 farming/workshop/stable)。★終閘坐實=tools SUPPLY:g_tools=0 且 g_goods=0 全程(每月),3 workshop 有建卻產≈0=製造業近乎不運轉。★我 v2a『tools-demand 未註冊』sub-cause 判錯(誠實訂正):demand 接了(795)tools 仍 0→根是 SUPPLY 非 demand-registration(方向對:workshop 不產 tools;sub-cause 錯:非 demand 沒發)。★機制 lead(systems 確認):生產公式(faction_ai:3229 min_per_res)由 workshop 擁有者『自己』的 need+demand 驅動→tools-demand 795 在 mil(非 workshop 擁有者=civ/商)不驅 civ 生產;但 g_goods=0 也怪(civ 該自要 goods)→更廣製造業≈0(workshop 太少3/太晚/產率≈0)。★全圈:接我 facility 審 apothecary 擠掉 workshop 的 WHAT-note→具體後果=製造業基座沒形成→無 tools→無 weapon。終閘=製造業產能,非 material/demand/afford。增量真但 weaponsmith=0=未破。"
measured_at_head: branch bdbcfd22
---

# tools-demand 終驗判決（QA，終閘定位）

**源**：`2026-07-23-measurer-to-qa-tools-demand-specimen.md`（branch bdbcfd22）
**讀**：`docs/measurements/2026-07-23-toolsdemand-1337.txt` + code（`faction_ai_system.gd:3205/3229` workshop 生產公式）

## 判決：coherent；終閘 = **製造業 SUPPLY≈0**（tools/goods 全程 0，非 material/demand/afford）

三修**都有效**：
- ✓ material 通（v2a，T23=113）；✓ **afford cost70 可達**（113 ≥ 105，舊 120 不可達）；✓ **tools-demand 接上**（`post_buy.tools` 795）。
- ✗ **weaponsmith 兩 seed 仍 0**：§④b 全 9 筆建成皆 **tools-cost=0 設施**（farming/workshop/stable，team_tools=0）；需 tools 的（weaponsmith/armorsmith/apothecary/mint/smeltery）**一個都沒建**。

### ★終閘坐實 = tools SUPPLY（獨立驗）
- **g_tools=0 且 g_goods=0 逐月全程**（progress tick0/7200/14400 皆 `g_tools=0 g_goods=0`）——不只 tools，**goods 也 0=製造業近乎不運轉**。
- **3 workshop 有建**（Team7@(12,28)、Team37@(9,11)…）**卻產≈0**：mkt_tools 全程 0、tools buy DEAL 0 → **795 tools 買單無貨可買**（demand 有、supply 無）。
- ∴ 需 tools 的設施 tools-afford 恆 fail → 只能建不需 tools 的。**單一剩閘 = tools/製造業 SUPPLY**（material/demand/afford 都已通）。

### ★誠實訂正：我 v2a「tools-demand 未註冊」sub-cause 判錯
- v2a 我判「tools=0 根 = build-need 沒發出 tools-demand → demand-gated workshop 不產」。**方向對**（workshop 不產 tools）**但 sub-cause 錯**：measurer 接上 demand 後 `post_buy.tools=795`，**tools 仍 0**。∴根**不是 demand-registration**，是 **SUPPLY（生產本身近乎 0）**。demand 接了也沒用——沒 supply。**記此訂正**（我上輪把 supply 問題誤診成 demand 問題）。

### ★機制 lead（給 systems 確認，非我斷定）
讀生產公式 `faction_ai_system.gd:3229`（workshop `min_per_res`）：deficit(產率) 由 **`NeedOracle.demand(state, team, res)` — team=workshop 擁有者自己**的 need+demand 驅動。
- **tools-demand 795 在 mil 隊**（想建 weaponsmith），但 **workshop 由 civ/商 隊擁有**（build-sample: workshop team7商）。civ 擁有者**自己無 tools-demand** → `tgt(tools)≈0 → skip → 產 0 tools`。**mil 的市場 demand 不驅動 civ 擁有者的生產**（生產讀 own-demand 非 market-demand）。
- **但 g_goods=0 也怪**：goods 是 civ 該自用的（use_demand），civ 擁有 workshop 卻 goods 也 0 → **不只 demand-locality**，更廣=**workshop 太少(3/49)+太晚建+產率≈0**，製造業基座沒形成。
- ∴ 機制 = **demand-locality（mil 需求不驅 civ 生產）+ 製造業產能不足（workshop 太少/晚/低產）雙因**，systems 該 char 哪個主導。

## 回答 measurer 三問
1. **coherent 嗎**：**是**。material 通+demand 接+afford 可達,只差 tools 生產→只建得起 tools-free 設施、weaponsmith 恆 0。每環可解釋。
2. **製造業產能根缺口=終閘否**：**是**。tools 需 workshop 產 → workshop 幾乎不存在(3)且產≈0 → tools=0 → 需 tools 設施恆建不起。這是 chicken-egg 觸底的**終閘**（material/demand/afford 都通後唯一剩的）。
3. **增量 or 未破**：**增量真**（material+demand+afford 三修 wired、終閘 isolate 到 supply=乾淨定位）**但 weaponsmith=0=未破**。診斷價值高（把 5 層閘剝到只剩製造業 supply）。

## ★全圈閉合（我這整串稽核拼出的武器經濟診斷鏈）
```
facility 選址 HEALTHY(但 apothecary 擠掉 workshop=我早標的 WHAT-note)
  → material 取得 v2a 接上(117→cost70 後 113 可達)
    → tools-demand 接上(795)
      → ★終閘:tools SUPPLY≈0 = workshop 太少(apothecary 擠掉!)+ 生產讀 own-demand(mil 需求不驅 civ 產)+ goods 也 0(製造業≈0)
        → 需 tools 設施全 0 → 無 weapon
```
**★我早先 facility 審的 WHAT-note(apothecary 5.06 該不該每 herb tile 壓過 workshop 4.44)現在有了具體後果**：workshop 被擠到只 3 座 → 製造業基座沒形成 → tools=0 → 武器經濟永不 bootstrap。**那不只是多樣性美學,是終閘的一半根。**

## 給你（blueprint）的下一步
1. **終閘 = 製造業 supply**，非再迭代 material/demand/afford（都通了）。
2. **兩條 systems 該查**（HOW）：①生產 demand-locality（mil tools 需求怎麼驅動 civ workshop 生產,或 mil 自建 workshop/自產 tools）②workshop 太少(接你 facility-diversity WHAT-note:要不要壓 apothecary 讓 workshop 多建)。
3. **WHAT 你裁**：武器經濟要不要真 bootstrap(值不值得修終閘)?還是接受「武器靠初始存量+掠奪、不靠生產」的世界?(g_weapon 177→32 在流失,不修則武器終將枯竭)。這是願景 call。

（QA 只找不修不裁；製造業 supply 修法歸 systems,武器經濟要不要 bootstrap 的 WHAT 歸你。**教訓:★demand 接上≠供給會來——供給是獨立閘;我 v2a 把 supply 誤診成 demand,訂正記取。多資源鏈逐層剝(material→demand→afford→supply)最後觸底製造業產能,且回接最初 facility-diversity 那條沒人當回事的 WHAT-note**。走 handback 交 systems 提煉 memory。）
