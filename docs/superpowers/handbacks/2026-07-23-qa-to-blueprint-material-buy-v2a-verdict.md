---
from: qa
to: blueprint
status: consumed
topic: "[material-buy v2a 故事判·coherent·tools=0 是 demand-routing 缺口深一層·非只 build 閘] v2a 讓 mil 真累積 material 到 117(vs baseline 98)、買料 chosen 80-307、餓不買料——但 weaponsmith 仍 0。兩深閘坐實:①afford×1.5=material 120(117 差 3)+tools 5;②★tools=0 全域。★關鍵獨立發現:tools 全程從未>0,且 workshop(有建!Team6/30/3/19/45 完工)output『use_demand=true』demand-gated——tools=0 不是『沒 workshop』是『weaponsmith build-need 沒發出 tools-demand→demand-gated workshop 不產 tools』=同 material 的 demand-routing 缺口深一個生產層。∴material-buy arc 治不到對(tools 是平行未解 demand 鏈,一層更深:tools 需 workshop 應 demand 生產,非市場取得)。afford×1.5 是系統性 margin 稅(也擋 faction civil site material62 需 50×1.5=75)。v2a=進度真(material 取得 wired+暴露深閘)但 weaponsmith=0 目標未達。下個閘=tools demand 註冊+重審 afford×1.5,別再迭代 material(117≈夠)。"
measured_at_head: branch 1076c0d5
---

# material-buy v2a 故事驗證判決（QA）

**源**：`2026-07-23-measurer-to-qa-material-buy-v2a-specimen.md`（branch 1076c0d5）
**讀**：`docs/measurements/2026-07-23-gateb-v2a-1337.txt` + code（`outpost_system.gd:86` weaponsmith cost、`faction_ai_system.gd:3205` workshop output）

## 判決：coherent；weaponsmith 卡在兩深閘，★tools=0 是 demand-routing 缺口**深一層**（非只 build 閘）

v2a **真讓 mil 累積 material 逼近閾**（T28 peak **117** vs baseline 98）、買料 chosen 80-307、餓時不買料（starve 0，food-safe ✓）。**但 weaponsmith 兩 seed 仍 0**。逐項驗兩深閘：

### 閘① afford×1.5 = material 120（117 差 3）——系統性 margin 稅
- weaponsmith cost（`outpost_system.gd:86`）= `material 80 + tools 3`；afford ×1.5 → **需 material 120 + tools 5**。
- T28 累到 117 → **差 3 卡在 ×1.5 margin**（有 base 80 綽綽有餘，卡在 1.5 倍緩衝）。
- **★不只擋 weaponsmith**：raw 顯示 faction civil site 也被 ×1.5 廣泛擋（`material 有 62 需 50` 但 **1.5×=75 > 62 → 派工失敗`資源不足 1.5x`**）。∴×1.5 是**全域 margin 稅**，非 weaponsmith 專屬。

### 閘② ★tools=0 全域——workshop 有建、卻不產 tools（demand-gated + demand 未註冊）
**這是我獨立挖到、比 measurer「tools=0」更深一層的機制**：
- **tools 全程從未 >0**（grep 全 v2a raw，零 tools>0）。
- **但 workshop 有建**：raw `[Outpost] 設施完工 workshop Lv1 at (9,28)/(26,8)`、Team6/30/3/19/45 都建 workshop。**∴不是「沒 workshop」**。
- **workshop output（`faction_ai_system.gd:3205`）= `["goods","tools","arrows"]` 且 `use_demand=true`**（demand-gated 生產：有需求才產）。
- ∴ **tools=0 根 = weaponsmith 的 build-need 沒發出 tools-demand → demand-gated workshop 不產 tools**（它產 goods/arrows 但 tools 無需求信號 → 不產）。
- **★這正是 material 的 demand-routing 缺口，深一個生產層**：material 是「build-need→買單」沒接（v2a 修了、市場取得）；tools 是「build-need→tools-demand→workshop 生產」沒接（更深，需生產端應 demand，非市場買現貨）。

## 回答 measurer 三問
1. **coherent 嗎**：**是**。累積 117→卡 afford 120（差 3 margin）+ tools=0（demand 未註冊，workshop 不產）。每環可解釋機制態。**血證 baseline T26 material80+coin70 仍沒建 → 坐實閘非供給**（我 CONFIRM，且進一步：閘=afford margin + tools-demand 未接）。
2. **真根在 build 閘（afford+tools）非 trade**：**部分對、需細分**——afford×1.5 是 build 閘（margin 稅）；但 **tools=0 不是「build 閘常數」，是 tools 這資源的 demand-routing/production 缺口**（同 material 模式，深一層）。∴不是「build 閘 vs trade」二分——是**多資源遞迴 demand-routing**：material 接了(v2a)、tools 沒接(workshop demand 未觸發)。material-buy arc **治不到 tools 對**（tools 要生產端應 demand，市場買不到現貨——tools=0 市場也空）。
3. **v2a merge or 未破**：**進度真、目標未達**。material 取得 wired（117 逼近）+ food-safe + 無迴歸 + **暴露深閘（診斷價值高）**。但 weaponsmith=0（硬指標）→ **未破 Gate B**。可當 incremental merge（material 取得是真能力）或 hold，你裁；**別宣告武器經濟修好**。

## ★給你（blueprint）的下一閘（別再迭代 material）
material 基本解了（117≈夠，afford margin 差 3 是 tuning）。**別再做 material-buy v2b/v3**——真下個閘：
1. **tools demand 註冊**（HOW,systems,★主）：weaponsmith build-need 要**發出 tools-demand**，讓 demand-gated workshop 產 tools（同 material 當初接買單的模式，但接的是「生產」不是「市場買」——tools 市場也 0，得靠 workshop 應 demand 產）。**不接這條，material 修再多 weaponsmith 永 0**（tools=0 絕殺）。
2. **重審 afford×1.5**（HOW,systems）：117 vs 120 差 3、faction site 62 vs 75——×1.5 margin 是否過嚴？降 margin 或讓累積目標對齊 1.5×（隊該囤到 120 不是 80）。WHAT 你裁要不要保這安全緩衝。
3. **material**：基本 OK,收工。

**整條武器經濟診斷鏈全圖**（我這串稽核拼出）：facility 選址 HEALTHY → material 取得 v2a 接上(117) → **tools demand-routing 沒接(workshop 不產 tools)+afford×1.5 margin** = 現閘。根是**遞迴 demand-routing**：每加一資源需求就要接一次 demand→供給,material 接了、tools 沒。

## 下一站
你（blueprint）裁 WHAT（tools demand 要不要接、afford margin 保不保、v2a incremental merge 否）→ systems 定 HOW（tools-demand 註冊 + workshop 應 demand + afford margin）。**別憑「material 累到 117」宣告 Gate B 破**——tools=0 是絕殺,weaponsmith=0。

（QA 只找不修不裁；tools-demand/afford 修法歸 systems,margin 保留 WHAT 歸你。**教訓:★demand-routing 是遞迴的——修一個資源(material)暴露下一個(tools),tools 更深(要生產端應 demand 非市場買);tools=0 despite workshops built = demand-gated 生產+demand 未註冊,不是產能不足。逐層剝到 code(use_demand=true)才見真根**。走 handback 交 systems 提煉 memory。）
