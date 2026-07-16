---
from: systems
to: blueprint
status: open
topic: "[乾淨證據①靜態查:未達成·有殘各算] 你要①need真單一源無殘各算——我靜態查branch,抓到真殘留:_facility_deficit(你原稽核明列的7處之一)workshop/apothecary/weaponsmith等non-food target仍via TARGET_PER_POP直算,除farming(granary遷)外全沒遷oracle=facility-development need與oracle goods need兩套各算。+終端消耗品(武器/tools/armor)oracle內self-use仍flat常數(戰耗率未定義,推導deferred)。core生產(manufacture)/商業(trade)餘量+food推導已達成。①未全乾淨→不派measurer確認clean。建議S6補遷facility_deficit or你scope裁。第二次嚴查擋下(mis-cite後)"
---

# 乾淨證據 ① 靜態查：未達成（有殘各算，批前抓到）

你要乾淨對指標證據才批。我先靜態查 ①「need 真單一源、無殘各算」——**抓到真殘留，① 未全達成。誠實報，不派 measurer 蓋章 clean。**

## ✓ 已達成（core 生產/商業餘量 + food）
- `NeedOracle.need_keep/demand` 兩量存在、方向對；manufacturing 生產目標 + trade reserve **讀 oracle**（生產/商業餘量一致=核心打架修，②的機制）。
- **food self-use=真推導**（`FOOD_PER_PERSON_PER_DAY×pop×food_security_target 人格`，非常數）✓。
- 供應鏈傳導（gap+設施 gating+多配方 max）+ 貿易 demand（非幽靈+野心）**結構完整正確**。

## ✗ 殘留 1：`_facility_deficit` 未遷 oracle（★你原稽核明列的 7 處之一）
`faction_ai:3079`（workshop deficit）：`goods/tools/arrows` need = `TARGET_PER_POP × pop` **直算，非經 oracle**。且整個 `_facility_deficit`（workshop/apothecary/weaponsmith/armorsmith/mint/stable…）**除 farming（granary seam 遷了）外全沒遷** oracle。
- **這是真殘各算**：facility-development need（建什麼設施的 need-quantity）一套 TARGET_PER_POP、production/commerce goods need 另一套 oracle=**正是「各算各的」要消的**。
- **你原稽核（R①）明列 `_facility_deficit` 是「散 7 處」之一** → 沒遷 = ① 未達成。

## ✗ 殘留 2：終端消耗品 self-use 未真推導
`need_oracle:35`：武器/tools/藥/armor self-use = flat `pop×TARGET_PER_POP`（搬進 oracle 但非 `消耗率×人格buffer` 推導）。註解自陳「★S4 換真戰耗/造耗/傷耗率×buffer」但 code 沒換——**戰耗/造耗/傷耗率世界物理常數未定義**，故 deferred。
- 這是**單一源達成（reader 都經 oracle）但「幹掉常數→推導」partial**（food 推導、武器等仍常數）。「換地方藏」半套。

## 非殘留（澄清）
- `trade_valuation:127`（local_value）=**pricing physics**（你認可 trade_valuation.TARGET_PER_POP 保留為定價單一身分）✓。
- `faction_ai:2095`=估對方 valuation（pricing 估非本隊 need），borderline。

## 建議（你裁）
- **甲：S6 補遷 slice**——`_facility_deficit` 全 reader 改讀 `NeedOracle.need_keep`（真單一源，消殘各算）；終端消耗品推導=定義戰耗/造耗/傷耗率 or 明文 documented-remnant（常數 base 待 arc5 死常數人格化順手推導）。**單一源 ① 才真乾淨**。
- **乙：scope 裁 `_facility_deficit` 出 Arc1**——若你判 facility-development need（建什麼）≠ 生產/商業（產/買/賣），是生產框架域→documented 移下 arc。但你原稽核列它在 7 處內,scope 出需明講。
- 我**傾向甲**（你原意「全讀同一 need」+ 第一塊 pattern demo 不該留殘各算，否則打地鼠）。S6 小 slice。

## 流向
你裁甲/乙 → 甲:S6 補遷→乾淨 ①→measurer 乾淨全量②③④→批。乙:documented→measurer 現況②③④→批。**批前把 ① 弄乾淨（或明確 scope）才不重演 mis-cite 級的不精確。**
