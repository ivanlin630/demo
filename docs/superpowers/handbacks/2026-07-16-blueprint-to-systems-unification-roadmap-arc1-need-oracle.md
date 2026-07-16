---
from: blueprint
to: systems
status: consumed
topic: "[統一路線圖 + 啟動Arc1 need oracle]用戶定「照路線架」。全庫稽核判讀:DecisionEngine統一半成品,引擎外並存多dispatch路+多份各算各的need(7處)/threat(8處)/估值(5處)。路線=收散亂成單一思考驅動oracle。★Arc1=統一need oracle(B1/B4,最高優先):NeedHierarchy升全域need源,need=自用(消耗率×人格buffer推導)+供應鏈(下游傳導)+貿易(全資源餘量,綁deal側);生產/商業共讀不打架;含停產接需求+溢出落地守恆+消耗品可貿易。解經濟+拆最大打架種子+示範模式。HOW你架,過R①(前提factcheck,7次被推翻)+R②"
---

# 統一路線圖 + 啟動 Arc 1：統一 need oracle（用戶定「照路線架」）

全庫結構稽核完（file:line 坐實）。用戶定案:**照路線收散亂 oracle,先架 Arc 1（need oracle）。**

## 全景判讀（稽核）
**DecisionEngine 統一是半成品**——引擎存在（23 option,吸收 threat/survival/ambition）,但引擎外並存:多 dispatch 路 + 多份各算各的 need/threat/估值。`faction_ai_system.gd`（3781 行）是大雜燴。**路線＝把散在裡面的抽出來收成單一思考驅動 oracle。**

## 統一原則（貫穿全路線，WHAT）
**框架只管規則（世界物理/機制）,思考驅動決策;同一概念收成單一思考驅動 oracle（非常數、人格/情境驅動）,所有子系統讀它,不各養一套。**

## 優先序（用戶定）
1. **統一 need oracle（B1/B4）← Arc 1，本封**
2. 收斂三重 dispatch（威脅/求生全走引擎 rank）
3. 統一威脅 oracle（ThreatAssessment 單一源）
4. 拆 `_threat_recent` 軍備閘
5. 決策門檻死常數人格化
6. 情緒系統
7. 內部政治 / 設施 / 俘虜

---

# ★ Arc 1：統一 need oracle（WHAT 意圖）

## 目標
`NeedHierarchy` 從「引擎內部 coeff 乘子」**升成全域 need oracle**。現在散 7 處各算各的食物需求（`_check_food_shortage` 10天 / `_calc_team_need` 14天 / `_facility_deficit` / diplomatic / order buy / faction need 第4棵樹…）→ **全讀同一個 need。**

## need 的定義（三來源相加，思考驅動非常數）
```
某資源 need = 自用 + 供應鏈 + 貿易
```
- **自用**（消耗品才有）：消耗率 × 人格 buffer **推導**（food=metabolic×security_target;武器=戰耗;tools=造耗;藥=傷耗）。**幹掉隨便給的 TARGET_PER_POP。**
- **供應鏈**（中間品）：下游生產量 × 配方係數**傳導**（要做劍→回推鐵/鋼）。
- **貿易**（全資源餘量）：市場買單 + 致富野心 + 商隊可載。**消耗品也可貿易（非互斥桶,貿易對全資源適用）;goods 特別在只有貿易需求。** 綁 deal 側（能賣掉才算）。

## 生產/商業共讀一個 need（防打架架構）
**一個真值源,兩邊讀:**
- **生產**（規則機制）：need > 手上 且我能做 → 產;全滿 → 停（個別設施各停）。
- **商業**（規則機制）：need > 手上 → 買;手上 > need（餘量）→ 賣。
- **餘量定義天然一致**（手上 − need）,不會兩邊各判「界線在哪」→ 無打架。加新資源/系統只加進 need,兩邊自動接。

## 含（本 arc 一起收，前面深挖的）
- **停產接需求**：需求滿停產（別燒 material 換蒸發 goods）。
- **溢出落地守恆**：溢出 `TileBank.pool_add` 落圖塊自然池（現在 `_add_output` 丟回傳值→蒸發＝毀滅物質違守恆）→ 落地 goods 還在、可撿。
- **消耗品可貿易**：need 的貿易來源對全資源。

## 資源分類（自然掉出，非硬桶）
按「有哪些 need 來源」：純消耗品（food:自用+貿易）/中間品（ore/steel:供應鏈+貿易）/貿易品（goods:只貿易）/軍備（自用+貿易）。**分類是 need 來源的結果,不是預先貼標籤。**

## HOW 全交你（我這 arc 越界猜 HOW 被推翻多次,只給 WHAT+優先）
- `NeedHierarchy` 怎麼升全域 oracle、7 處 reader 怎麼 migrate、供應鏈傳導怎麼算、貿易 need 怎麼綁 deal 側、生產/商業怎麼接同一 need、切幾 slice ＝**你 HOW**。
- 我只要結果：**一個 need oracle,生產+商業共讀;停產+溢出落地;need 思考驅動非 TARGET_PER_POP 常數;7 套餓收斂成一套;守恆;可擴充（加資源/系統只加 need 不改各處）。**

## 閘（本 arc 這麼大,紀律嚴）
- **R①（前提 factcheck）必過**：稽核斷言（食物需求真散 7 處?NeedHierarchy 升級與現用衝突?供應鏈傳導前提?）送 reviewer refute 向 factcheck。**本 arc 判斷層已被獨立查證推翻 7 次（6 measure + 1 R①）,大框前提務必先驗。**
- **R②（審設計）必過**。
- 可能需 measurer 一輪坐實（need 收斂後行為無回歸、經濟真動）。

## 下一站
系統 spec Arc 1 need oracle 架構 → R① 前提 factcheck → CLEAN → R② 審設計 → impl → measurer（need 收斂+經濟動+守恆+無回歸）→ 我批 → Arc 2（三重 dispatch 收斂）。
**經濟卡的 need 模型＝統一路線第一塊。修它同時解經濟 + 拆最大打架種子 + 立「散亂→單一 oracle」模式,後面 threat/估值照做。**
