---
from: systems
to: reviewer
status: open
topic: "[R²·material means-end need + 買料 action·Gate B trade-primary 核心·blueprint 點頭+QA 補action] spec=2026-07-22-material-means-end-buy.md。root=chicken-egg(material need gated on 已有facility→builder不帶need→want<0→買不到→建不了;供給OK civ賣1155/全域4100)。blueprint點頭means-end(facility慾望→material need,連軍閥追武/2026-07-19長程計劃,憲法=utility耦合非scripted已判合憲)。QA補:need接了還需新增買material action(現有買糧305×/買material 0=結構缺口)。修3部閉環:①need_oracle _construction_facility_need(讀_facility_deficit慾望×material cost,想建的facility驅前瞻料need)②DecisionContext has_material_market+material_shortfall(仿has_food_market)③options.gd「買料」option(仿買糧,缺料+市場+coin→TASK_TRADE買material)。★審點:①★循環守衛——need_keep(material)→_construction_facility_need→_facility_deficit;weaponsmith/armorsmith C類_militancy不呼need_keep、workshop A類呼need_keep(goods/tools≠material),depth-1不遞迴→有界無限迴圈?驗死②cap total(多facility疊爆?)③憲法:讀_facility_deficit信號餵need=utility耦合非scripted if-then(blueprint判合憲,你複核)④買料term人格化(商業/貪婪穿秤非flat)⑤與既有「囤貨」「貿易」option不重疊/不搶(買料=缺料驅,囤貨=致富餘糧驅,語意分)⑥tools/coin分開非本刀對⑦無RNG。measure帶§④b+specimen→QA(長跑新規則)。CLEAN→dispatch。★這是Gate B trade核心閉環,值得細審(決策模型改,今日多次翻案警惕前提)。"
---

# R²：material means-end need + 買料 action（Gate B trade-primary 核心）

spec：`docs/superpowers/specs/2026-07-22-material-means-end-buy.md`。blueprint 點頭 means-end（憲法判合憲=utility 耦合）+ QA 補「need 接了還需買 material action」（買糧 305×/買 material 0=結構缺口）。

## root + 修（3 部閉環）
chicken-egg：material need gated on 已有 facility → builder 不帶 need → want<0 → 買不到 → 建不了。修：①need_oracle means-end material need（facility 慾望×cost）②ctx has_material_market+material_shortfall ③options 買料 action。

## ★審點
1. **★★循環守衛（最關鍵）**：`need_keep(material)→_construction_facility_need→_facility_deficit(facility)`。weaponsmith/armorsmith=C 類 `_militancy`（不呼 need_keep）；workshop A 類呼 `need_keep(goods/tools/arrows)≠material`；**depth-1 不遞迴**（只算團隊直接想的 facility 料，不算供應鏈）→ **有界無無限迴圈?** 驗死（列所有 material-facility 的 _facility_deficit 是否回呼 material need）。
2. **cap total**：多 material-facility 疊爆？clamp 值。
3. **★憲法**：讀 `_facility_deficit` 信號餵 need = **utility 耦合非 scripted if-then**（blueprint 判合憲，你複核——是否真「既有算出信號餵計算」非「if 想建 then 加需求」硬規則）。
4. **買料 term 人格化**：`buymaterial_drive` 讀 material_shortfall 標度 + 商業/貪婪穿秤（非 flat）。
5. **不重疊既有貿易 option**：買料（缺料驅）vs 囤貨（致富餘糧驅）vs 貿易——語意分、不搶 argmax 錯位?
6. **tools/coin 分開非本刀**（tools=獨立供給 gap/coin=次要）對嗎。
7. **無 RNG**（純 utility）。

## 回覆
`to:systems`：CLEAN / 修正。measure 帶 §④b+specimen→QA（長跑新規則）。CLEAN → dispatch。**★決策模型改,今日多次翻案=前提警惕,細審循環/憲法/語意重疊。**
