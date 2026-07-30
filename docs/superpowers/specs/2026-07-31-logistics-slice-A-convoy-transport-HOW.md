---
type: spec
owner: systems
topic: 後勤統一 SLICE A（convoy transport 地基）HOW
status: ready-for-R2
---

# HOW spec：後勤統一 SLICE A — convoy transport 地基

> WHAT `2026-07-31-logistics-supply-movement-design.md`（R① CLEAN、無 premise_contradiction）。**★R① scale correction 併入（reviewer 異質框外審 2026-07-31）**：WHAT §3.1/§4/§7「現成零件」措辭過譽——**真複用只 3 小零件**（載重 model `movement.get_carry_capacity` / ETA 算式 / `_fund_subteam_from_vault` 撥款樣式）；**convoy 生命週期「取貨→送達非母隊目的地→交付→原隊完整返航」＝100% 新核心**（現子隊只「就地安頓」subteam:73-78 或「回母隊格併入消失」try_merge_back:67-83、無「送貨返航」）。∴ SLICE A 是**真新建主體**、非接線。

## 1. scope（誠實 scale：新核心 + 3 小零件）
**新核心（真新建）**：convoy 物件 + convoy 生命週期狀態機（取貨→去程→交付→返航）+ **派 convoy 決策真 fire** + 供給真到手。
**複用（3 小零件）**：`movement` 載重上限 / ETA 算式（距離/MOVE_TILES_PER_DAY）/ `_fund_subteam_from_vault` 撥款樣式（載 cargo 進子隊）。
**SLICE A 只做「需方拉（pull）」**（動機最穩、後勤可靠底）；供方推/領主推=SLICE B；劫掠=延後。

## 2. convoy 物件（新）
一趟運補 = `{源vault位置, 目的位置, cargo(res→qty), 載重上限, ETA, 狀態}`。狀態機：
`FETCH（取貨源vault）→ OUTBOUND（去程）→ DELIVER（卸貨目的vault）→ RETURN（返航母隊）→ 解散釋放抽出pop`。
- **腳夫子隊**＝載體（複用子隊底盤：母隊抽 pop 手 + 馱獸/馬車決定載重），但**掛 convoy 狀態機、非既有 subteam TRANSIT/settle 生命週期**。
- ★**不換手、不涉價**（源/目的皆自家 vault，同所有權調度）。

## 3. convoy 生命週期（新核心，逐段）
- **FETCH**：porter 到源 vault → withdraw cargo（複用 `_fund_subteam_from_vault` 撥款樣式：`TileBank.withdraw(源tile, res, qty)` 載進 porter carry，受載重上限 cap）。
- **OUTBOUND**：travel 到目的（複用 movement；ETA=距離/速度，馱獸/馬車調）。★porter 自身要吃糧路上（複用糧橋「趕路人存活試算」為 porter 生存零件、非運補語意）。
- **DELIVER**：到目的 tile → `TileBank.deposit(目的tile, res, cargo)`（★目的須自家 vault，無所有權換手）。cargo 真交付＝源 vault 少、目的 vault 多。
- **RETURN**：travel 回母隊格 → 到家解散、釋放抽出的 pop（★非「就地安頓」subteam:73-78、非「半路併入消失」——完整返航釋放 pop）。
- 每段接 tap（`convoy.dispatch/fetch/deliver/return` + cargo 量），純算術零 RNG。

## 4. ★★派 convoy 決策真 fire（第一驗收核心，本 session 的鬼）
**需方拉**：隊短缺 res X AND 有**自家 remote vault**（別格自家 outpost）存 X surplus → 派 porter 去取。
- **動機最強**（「我缺我去拿自己的」不易輸 argmax，是後勤可靠底）——但**必驗真 fire**（同 trade-trip/founding-preempt 家族：決策生成 ≠ 真執行）。
- **HOW 決策接點**：pull-convoy 是新 decision option 進 rank 池（`_resolve_resource_prereq` 材料缺口鏈的新取得手段：**取得手段 3＝拉自家 remote surplus**，排在買(S2)/採@forest(S3) 之間或按 util——★缺+有自家 remote surplus 的 util 該高過覓食，這是「拉」動機最穩的體現）。
- ★**防輸 argmax**：pull-convoy dispatch 後，porter 掛 convoy 狀態機（progressive committed）→ 複用 persist-hold 保護免 routine 搶班（★注意 founding persist floor HELD 未 merge；若 convoy 也需 cold-start 保護則本 slice 一併設計 active-convoy floor，或先驗 porter 是否輸 argmax 再定）。

## 5. 重複派協調（dedup，§9.2）
SLICE A 只需方拉（單邊）→ 隊拉自己的 remote surplus、無跨隊重複。跨供需 dedup（pull+push 同需求各派）=SLICE B（push 進場才需看板/認領/去重）。SLICE A：一隊對一需求一 porter（in-flight guard：該需求已有 porter 在途→不重派）。

## 6. 憲法對齊
- **util weigh 非 scripted**：派 convoy=決策層 util 秤（缺 X × 有自家 remote surplus × 距離成本）、非寫死。
- **全量暫態可觀測性**：`convoy.dispatch/fetch/deliver/return` + cargo 量 + in-flight guard 全接 tap（禁 RNG）。
- **★第一驗收（這 session 的鬼）**：決策生成 ≠ 真執行。硬驗 convoy **真派+真到+cargo 真交付**（非只 candidate 生成）。

## 7. TDD（★★第一驗收：真派真到手 execution-verified）
- **★★convoy 真派真到手**：seeded 場景（隊 A 缺 material、有自家 remote outpost vault 存 material surplus）→ **pull-convoy 真 fire**（`convoy.dispatch>0`）→ porter FETCH（源 vault material 減）→ DELIVER（A 的 home vault material 增）→ RETURN（porter pop 回 A）。斷言 **cargo 真移動**（源−、目的+、守恆）+ decision 真 fire（非只生成）+ **不輸 argmax**（porter 不中途被搶去覓食/外交半路棄貨）。
- **供給真到手 vs baseline**：無 convoy 時 remote surplus 永困源 vault（A 缺不解）；有 convoy → A 缺真解。
- 純算術零 RNG（convoy 決策/移動零 randf；specimen determinism）。世界不凍（seed1337 attrition 非→0）。constitution 74 + observability PASS + headless 0-new + determinism 三跑 byte-identical。
- ★守恆：cargo 移動守恆（源 vault + porter carry + 目的 vault 全程守恆、無憑空增減）。

## 8. 交付
→ R²（★異質：新核心 convoy 生命週期 vs 子隊既有生命週期真不衝突/pull-convoy decision 真不輸 argmax（第一驗收）/複用 3 小零件邊界對/cargo 守恆/porter 自身糧/dedup in-flight guard/★不凍）→ implementer（convoy 物件+生命週期+pull decision+TDD 第一驗收硬驗）→ measurer（convoy 真派真到手 + 不凍）→ QA。**★execution-verified：convoy 真派+真到+cargo 真交付（別生成不執行）。**
