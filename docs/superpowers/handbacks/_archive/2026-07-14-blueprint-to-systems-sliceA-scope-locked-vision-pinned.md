---
from: blueprint
to: systems
status: consumed
topic: [★用戶定序拍板·Slice A scope鎖定+願景拍板] slice A=層1,2,3,5+候選1,2(綁架構一起);跳過層4(判被溶掉);候選3,4排之後;願景=求生是個性加權競爭項非硬中斷
---

# Slice A scope 鎖定 + 願景拍板（用戶親裁）

回你 `2026-07-14-systems-to-blueprint-scope-split-layers45-measure-gated.md` 的定序問。用戶**不選純 measure-first 增量**，選**把兩塊架構綁一起做對**（避免打地鼠：先補丁再重開架構）。

## Slice A scope（一次做完再一次量測驗收）
| # | 內容 | 性質 |
|---|---|---|
| 層1 | 安全網（Fix2 漸進觸發） | 已 branch，measurer 驗中 |
| 層2 | 求生門檻人格化（Fix3） | 已 branch，measurer 驗中 |
| 層3 | 買糧認武器變現（Fix3c 償付能力） | reviewer CLEAN，本輪納入 |
| 層5 | 預算戰略分配（備糧/軍備/發展按個性+處境權衡，任一不吃光） | ★架構 |
| 候選1 | 賣糧 reserve 也人格化（補對稱） | 見下 |
| 候選2 | 全 option applicable 門檻人格化框架 | ★架構 |

**跳過層4（鋸齒觸發線≠收手線）**：用戶採信你的判斷——層3(認武器)+層5(預算分配)+候選2(門檻人格化)+層2 合起來，「買糧買到人格化安全存量才收手」的效果**應自然長出**，不需單獨層4機制。**請你確認這三塊是否真吸收掉層4**；若量測後仍見殘餘鋸齒（真赤貧隊除外），再補層4。

## 排之後（本輪不做，記 known_issues）
- **候選3**：faction 不救成員求生、徵收還從餓的窮成員抽血（無反向補糧 directive）。
- **候選4**：breed「養不起還一直生」正反饋（只看瞬時 needs.food>0.7，無人均存糧剎車）＝Team7 pop 10→4 暴崩候選機制。
- 兩者同型缺陷（只看瞬時、不看前瞻/償付力），跟本輪求生門檻同源，但獨立 slice，排 slice A 驗收後。

## ★候選1/候選2 併入細節（掃描已坐實 file:line）
**候選1 賣糧對稱**：`trade_valuation.gd:58-63` 賣方 food reserve=`pop×0.1×20`=`pop×2`≈**2.5天**（死常數，`interaction_system.gd:790-793,816,823` 都吃它）。三缺口：①不看個性（乞食 aid reserve 已人格化 `lerpf(2,60,hoard)` @`interaction_system.gd:999-1006`，賣糧端沒有＝**同型不一致**）②常數過期（0.1/tick vs 真實消耗 `FOOD_PER_PERSON_PER_DAY=0.8`@`resource_system.gd:3`）③**賣糧留2.5天 < 買糧panic 3天 → 囤貨隊賣到2.5天下一tick自己掉進恐慌**。修：賣糧 reserve 跟買糧安全存量用**同一套人格化水位**，不要各走死常數。

**候選2 全 option 門檻人格化框架**：抽查 applicable 門檻幾乎全是死常數 TEST VALUE、不接人格——佔村 `OCCUPY_MIN_POP=6`(terms.gd:22)、血仇攻擊 `FEUD_ATTACK_MIN=0.5`(options.gd:52)、匱乏搶 `SCARCITY_RAID_MIN=0.55`(terms.gd:19)、囤貨 `SURPLUS_FOOD_DAYS=7`(terms.gd:18)、capability `VIABLE_ARMED_RATIO=0.3`(terms.gd:33)。人格目前只進 weight(terms.gd:216-252 染 HOW)，**沒進 applicable 閘(WHETHER)**。∴ 需一個「applicable 門檻也吃 leader 人格」的框架（謹慎/野心 trait 調變門檻，非各補常數）。這是候選2 的本體，層2/層5/候選1 都是它的實例——**綁一起設計，別各自打補丁**。

## ★願景拍板（用戶親裁，解你 layer5 標的「重觸留議願景大問」）
**求生 = 個性加權的競爭項，非硬中斷。** 用戶選層5（預算在備糧/軍備/發展間按個性權衡）＝明確拍板：不要「餓到某線就無條件停一切去求生」的硬中斷模型；要「求生跟發展在人格化預算裡競爭權重」。整個候選2+層5 架構建立在此前提。**這條之前留議，現正式 close：util 競爭派勝出。**

## 請做
1. 判斷根因+scope 是否可落（你 owner HOW；trait 欄位/映射曲線/預算協調機制你定）。
2. 開架構 spec（層5 預算協調 + 候選2 門檻人格化框架，含層1-3+候選1 的實例化）。
3. **★這輪動架構 + 剛拍板願景 = 大框三對齊 → 建議升「框外異質 skeptic」審（R② heterogeneous），非同質 reviewer**（照 01_architect 大框三對齊升審規則）。CLEAN 才 dispatch。
4. implementer → 修完連原4-fix 一次量測驗收（seed1337/42/7）。驗收點：attrition 回落 + Team10 thrash 治好 + established 不退 + Team14 型「滿手武器買不起糧餓死」消失 + 賣糧隊不再賣到自己餓 + 資源分配浮現個性（非二元擺盪）+ 觀察殘餘鋸齒判層4 要不要補。

## 邊界
HOW 你 owner。恪守用戶原則：**不新增玩家可見 option/行為**，是讓既有 option 的 applicable 門檻 + weight 共同吃「人格化 + 預算權衡」。若你判斷架構 blast radius 需拆內部 slice，回報拆法讓我裁序（仍一次量測驗收全部）。
