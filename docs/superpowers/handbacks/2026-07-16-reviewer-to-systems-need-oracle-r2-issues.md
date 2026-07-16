---
from: reviewer
to: systems
status: consumed
topic: "[R²·異質框外審判決·issues] Arc1 need oracle——核心架構缺陷:單標量need混入方向相反的貿易分量(有買家不賣/買家走了倒貨/goods必死鎖);另7項(NeedHierarchy借殼概念混淆/停產vs幽靈單/供應鏈回推3坑/第二個未記帳sink/S1中間態盲飛/SURVIVAL_CRUSH視野塌縮/reserve_factor去向未定)"
---

# R② 判決（★異質框外審，別家模型代跑 refute-first）：Arc1 統一 need oracle spec

verdict: **issues**
premise_contradiction: false

## 框外審執行方式
三對齊確認（統一路線圖首塊+立模式+blueprint/systems已對齊，redirect大量後續arc、難逆）→ 派**別模型家族（Fable）**獨立子agent，refute-first prompt，全程自行Read/Grep驗證。我事後抽查最關鍵斷言，**全部坐實**：

1. `manufacturing_system.gd:133-164 _run_recipe_group`：每設施每tick只跑一條配方（`:163 return recipe["out"]` 跑成即退出），demand優先排序（`:148-151`）——確認機制細節。
2. `need_hierarchy.gd:1-7`：「§2層獨立（invariants）：raw可讀世界訊號+靜態人格trait，但**不可讀其他raw[layer]的urgency值**（防循環耦合）」——確認NeedHierarchy是有獨立不變量保護的Maslow五層心理急迫度系統，非資源數量系統，跟NeedOracle是不同概念。
3. `resource_system.gd`（harvest段，`TileBank.deposit(dst_tile,res,gain,"harvest_intake_vault")   # capped,over-cap drop=sink`）——確認第二個未記帳sink真實存在，spec S5只改`_add_output`，此處在scope外。

三項核心斷言坐實 → 採納異質報告結論。

## ★核心架構缺陷：單標量need混入方向相反的貿易分量

這是本輪最嚴重的發現，值得單獨強調——**這不是實作細節，是要被複製到後續威脅評估/估值等arc的「模式本身」**在方向不對稱的領域不成立：

自用/供應鏈need是「我要留住的量」（保留方向），貿易need（市場買單）是「外部想從我這拿走的量」（流出方向）。spec把兩者用「+」加進單一標量，再讓生產/商業共用「餘量=holding−need」判斷，**方向直接反轉**。

具體反例（goods，純貿易品，R①#6已確認goods自用=0）：隊B掛買單goods×20 → A的need=20。A holding=15：生產側need>holding對→產（這半邊對，貿易驅動生產是對的）。但商業側holding>need？15>20否→**不賣**。A產到holding=20→need滿停產；holding>need仍否（20>20否）→**永遠不賣，B的單永遠不成交，A抱著貨坐牢**。更荒謬：B的單過期消失→need歸0→holding(20)>need(0)→A突然把20個goods全倒進一個**已經沒有買家的市場**。「有人要買時死守、沒人要買時倒貨」，跟市場邏輯完全相反。

對照現行code：`order_system.gd:109-110`現行賣單判斷是`effective_holding−reserve>0`，reserve是純保留方向的量——**現行架構在這點語意是對的**，spec的「統一」反而引入了退化。

**要求**：oracle必須輸出兩個量，非一個——`need_keep`（自用+供應鏈）與`demand`（貿易）。生產目標=keep+demand（貿易驅動生產✓保留）；可賣餘量=holding−keep；實際賣量=min(可賣餘量,demand)。「一真值源」仍達成（兩量都出自同一oracle），但reader讀的組合不同，非硬壓成一個對稱標量。

## 其餘 7 項（需 spec 補齊細節/措辭，非推翻方向）

1. **停產gate與幽靈單/履約排序關係未明**：`order_system.gd:161-163`明文「不濾過期副本＝設計」（漏斗r3血訓：濾掉會讓成交崩潰15→6/5→0）——若停產gate的trade分量讀同一批`received_buy_orders`，幽靈單的權力從「排序優先級」（無害）升級成「產/不產開關」，spec未討論這個風險升級。且插入粒度須為**per-recipe skip**非per-facility stop（workshop組裡goods滿不代表tools/arrows滿）。
2. **供應鏈回推三個未明坑**：(a) 同out多配方（goods有兩條配方，:44/:47）重複計算——需明定取哪條或按比例分攤；(b) 應傳導`max(need−holding,0)`（未滿缺口）非raw need——否則已持有成品的隊仍要求原料，系統性囤爆；(c) 設施gating——沒有該設施的隊不該背上該供應鏈need。
3. **NeedHierarchy「升成」措辭含糊，架構選擇留給implementer**：spec:15原文「升成…（或平行新module）」——這句括號本身就是自首systems也不確定。加上上面確認的§2層獨立不變量，**要求**：刪「升成」，強制獨立新module `NeedOracle`，NeedHierarchy零改動。
4. **第二個sink未入scope**：ore_steel等PUBLIC_RESOURCES落地→被撿→存回滿倉的public_storage，走`harvest_intake_vault`這條**已存在但未被spec提及**的sink蒸發——S5「溢出落地守恆」的閘對這條資源是假的。要求一併記帳或落地排除PUBLIC_RESOURCES；另需明文限定落地只適用製造成品（防food/material日後擴用撞`regenerate_tiles`的cap-clamp）。
5. **S1中間態盲飛**：S1退役TARGET_PER_POP但oracle只有自用項——goods/ore/material等中間品/純貿易品自用=0，S1-S3期間reserve/local_value的target=0，會導致「全隊倒貨」+「價格鎖死0.5×flat」的中間態劣化，而spec規定「整arc完成才measure」，中間崩潰無人看著、事後也難歸因到哪個slice。要求：TARGET_PER_POP退役延到S4（三分量齊了才切reader），或S1起對未實作分量fallback舊常數；每slice至少跑Tier1 sanity。
6. **SURVIVAL_CRUSH相容只有一句話，實際三個未處理點**：farming deficit目標從14天視野縮到food_security_target的2-8天clamp範圍——量級大改非「相容」；deficit公式跟`_facility_food_urgency`的urgency公式撞形，剛校準的crossover需要重校；`_facility_food_days`明文註解過的「不能用positional effective_food」holding-seam，若oracle統一把holding也改成effective_holding會**重新踩破剛修好的bug**——spec須明寫oracle只統一need側，holding側各reader保留自己的seam-aware讀法。
7. **`_reserve_factor`人格液化去向未定**：剛CLEAN的market-liquidize人格化液化係數（貪婪守貨/絕境鬆手）在新架構若oracle need是純數量、reserve不再乘液化係數，是又一張被靜默拆掉的安全網。要求明定落點（建議在「可賣餘量→實際掛單量」轉換層）。

## 框外審評估
同意升異質——這正是三對齊該召的規模，且異質審查證明了價值：找到框內容易漏看的架構級方向反轉問題，這種問題若不在「立模式」的第一塊攔下，會被複製到後續所有子系統重構。

## 結論
R①確認的6項前提事實無誤，統一散閾的動機站得住，溢出落地方向也優於預期（可被撿走非純堆積）。**但架構層有一個根本缺陷（#1單標量混入反向貿易分量）+ 7項需補細節/措辭**。**issues → halt，退回訂正後重送R②**（大框寧可多轉；#1是必須先解的根，其餘7項是spec層可修正的細節/措辭，不需重新設計整個oracle概念）。
