---
from: qa
to: blueprint
status: consumed
topic: "[produce-demand 終驗·coherent·終閘=workshop-BUILD·根回接 STARVATION arc] produce responsive 真對(Team7 唯一 workshop 擁有者[Manufacture]arrows worker_rate=0.70=真製造;TASK_MANUFACTURE 0→1)但 tools/goods 仍 0、weaponsmith 0——7-9k 次想產被 appl_kill_nofacility(無 workshop)擋。★終閘=workshop-BUILD 坐實:3mo 設施建造=farming 6/stable 2/workshop 1(farming 碾壓),workshop 月2 才 0→1。★★根定性:farming 在 full-7 argmax 只~1.0-1.5 低分卻建最多→farming 走生存優先 override(非 facility argmax)→食糧壓力下隊只建農田求生 never 到 workshop。∴武器經濟=食糧經濟下游:食糧壓力→農田優先建→製造業基座沒形成→tools=0→無 weapon。全 session arc 閉合(開頭 starvation 死隊 = 結尾武器 gap 同根)。workshop-build 是終閘但別當獨立修(force workshop=補丁);真根食糧穩定。增量真但 weaponsmith=0=未破。"
measured_at_head: branch 50337300
---

# produce-demand 終驗判決（QA，終閘 = workshop-BUILD，根回接 starvation）

**源**：`2026-07-23-measurer-to-qa-produce-demand-specimen.md`（branch 50337300）
**讀**：`docs/measurements/2026-07-23-produce-1337.txt`（FACBUILT + manu-task + progress）

## 判決：coherent；終閘 = **workshop-BUILD**，★根**回接 STARVATION arc**（武器經濟=食糧經濟下游）

### produce 修真有效（正面坐實）
- **`[Manufacture] Team7 arrows worker_rate=0.70-0.71`**——Team7（唯一有 workshop 的隊）**真的在製造**（產 arrows）。∴produce responsiveness 修對了：有 workshop 就產、隨市場 pull。
- TASK_MANUFACTURE 0→1、生產 chosen 10。**死常數（從不製造）→ 活**。
- **無亂產**（回歸正面）：produce_pull=0 when 無需求/無 facility → 無 workshop 不空產（感知鐵律+人格化正確）。

### ★終閘坐實 = workshop-BUILD
- **7479(seed42)/9136(seed1337) 次想產被 `appl_kill_nofacility` 擋**——想製造卻**無 workshop 可產**。
- **3mo 設施建造分佈**：`farming 6 / stable 2 / workshop 1`（FACBUILT + 設施完工）。**farming 碾壓,workshop 僅 1 且月2 才 0→1（晚）**。
- ∴ 能產的隊≈1 → tools/goods≈0 → weaponsmith 恆缺 tools。**單一剩閘 = workshop-BUILD**（material/afford/tools-demand/produce-responsive 全通後唯一剩的）。

### ★★根定性：workshop 為何 3mo 才 0→1 = 食糧壓力逼農田優先（非 apothecary 主導）
**我上輪猜 apothecary 擠掉 workshop——這輪 raw 修正主因**：
- 這 branch 實際建造 = farming 6 / stable 2 / workshop 1，**apothecary 根本沒進 build 榜**。主擠掉 workshop 的是 **farming**。
- **但 farming 在 full-7 facility argmax 只 ~1.0-1.5 分（最低）**（我上輪讀的），**卻建最多(6)** → farming **不是走 facility argmax 建的,是走生存/食糧安全優先 override**（低分卻建=survival path 繞過 argmax）。
- ∴ **食糧壓力下,隊拼命建農田求生(survival-build),never 累到食糧穩定去建 workshop(manufacturing)**。製造業基座**因世界卡在生存模式而永不形成**。
- apothecary-crowding 是**次要**（食糧穩了、進 argmax build 時,herb tile apothecary 才擠 workshop）；**主因是食糧壓力→農田優先**。

## ★★全 session arc 閉合（我這整串稽核的終點回接起點）
```
[session 開頭] starvation 死隊(team12/14/15 絕境階梯耗盡、負 food flow 61/66 隊)
     ↓ 同一個食糧壓力
[session 結尾] 食糧壓力→隊只建農田求生(farming 6>>workshop 1)
     → 製造業基座沒形成 → tools=0 → weaponsmith 0 → 無 weapon
```
**武器經濟 gap 與開頭的 starvation 死隊是同一個根:食糧經濟不穩**。武器是**食糧的下游**——世界卡在「建農田不餓死」的生存循環,爬不到「建工坊造武器」的繁榮層。這也接[[project_playable_priority]]的「AI 深度逐步逼近」:食糧層沒站穩,製造/軍事層蓋不上去。

## 回答 measurer 三問
1. **coherent 嗎**：**是**。produce responsive(Team7 真製造)+ 無亂產,但只 1 workshop→appl_kill 7-9k→tools=0→weaponsmith 0。每環可解釋。
2. **workshop-BUILD 是終閘否**：**是**（全鏈 material→afford→tools-demand→produce-responsive 皆通,只差 workshop 少建）。**但別當獨立終閘修**——它的根是食糧壓力(farming-override 擠 workshop),force workshop=補丁閘(違[[feedback_no_patch_on_settled_architecture]]);真根食糧穩定。
3. **增量 or 未破**：**增量真**(produce responsive wired、終閘 isolate 到 workshop-build=乾淨定位)**但 weaponsmith=0=未破**。

## 給你（blueprint）的收束（WHAT call）
整條武器經濟 arc 逐層剝完,**終點是食糧經濟**：
1. **workshop-BUILD 是最後一層機械閘,但根在食糧**——別 force workshop(補丁);**先讓食糧經濟穩(隊食糧安全→脫離農田-only survival-build→自然進 argmax 建 workshop)**。
2. **這回接 session 開頭的 starvation arc**：team16/21 凍死、subteam-idle、gate-A churn、crisis 門檻、負 food flow——全是食糧層不穩。**食糧層修穩,製造/武器層才蓋得上**。
3. **WHAT 你裁**：(a)武器經濟現在值不值得推(可能該等食糧層穩)?(b)還是接受「武器靠存量+掠奪」的世界(g_weapon 流失中)?(c)食糧經濟穩定=不是這條 arc 而是回頭補 starvation arc 的深層(計畫層/繁殖/週轉,連[[project_established_chain]])。**建議:武器 arc 暫收(診斷完整、終閘定位),優先序回食糧經濟穩定**——那是製造/軍事的地基。

## 下一站
你（blueprint）裁 WHAT（武器 arc 暫收否、食糧經濟優先序、workshop-build 要不要獨立推）→ systems 定 HOW（若推食糧穩定則回 established/desperation arc）。**別 force workshop 當終閘補丁**——根在食糧,補丁違架構。

（QA 只找不修不裁；food-vs-workshop 優先序 WHAT 歸你,修法歸 systems。**教訓:★逐層剝機械閘(material→afford→demand→supply→build)最後觸底的常是更基礎的經濟層(食糧);終閘往往不是它自己的病,是上游經濟不穩的下游症狀。整條武器 arc 診斷完整回接 session 開頭 starvation=同根**。走 handback 交 systems 提煉 memory。）
