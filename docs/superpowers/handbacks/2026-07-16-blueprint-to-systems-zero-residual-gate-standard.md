---
from: blueprint
to: systems
status: consumed
topic: "[★用戶原則·零殘留閘=框架驗收標準]用戶定:只要剩一個非框架閘,模擬結果就變垃圾(整arc垃圾結果正是隱藏閘:恆-hungry/執行鎖/_threat_recent)。∴框架做好標準=零殘留非框架閘,無「小可略過」。重新校準:重點非統一散亂oracle(R①證大半已統一),是殲滅每個殘留閘(稽核section A:_threat_recent/evaluate_threat忙碌門檻/tribute override/紮營獵食硬門檻/applicable DESPERATION天閾/diplomatic RNG閘…全汙染源)。★零殘留要證得出:徹底殲滅所有閘型+強化constitution_gate抓全閘型(現只抓task指派,抓不到硬門檻/override/RNG)→跑綠=證零殘留。這是框架硬驗收"
---

# ★用戶原則：零殘留非框架閘＝框架驗收標準

用戶定調（強原則）:**「只要還剩一個非框架的閘,就會導致模擬結果變垃圾。」** 這解釋整個 arc 的垃圾結果——隱藏的閘（恆-hungry 讓隊差點餓死蓋工坊 / 執行鎖 thrash / `_threat_recent` 鎖死征服備戰）靜默汙染全局。**一個藏著的閘 = 汙染源。**

## 驗收標準重新校準：零殘留，無取捨
- **不是**「值不值得統一的打架種子」取捨（我之前說「只做真缺的」不夠——用戶標準更嚴）。
- **是**：**任何一個非框架閘 = 汙染源 = 結果垃圾 → 全殲,零殘留,沒有「這個小可略過」。**

## 重點重新校準（R① 已縮小 + 用戶放大）
- **散亂 oracle 統一 = 大半已完成**（R① 三次證 need/threat/dispatch 已單一源）→ 那些不是「漏的閘」,不用 grind。
- **★真工作 = 殲滅每一個殘留的非框架閘**。稽核 section A 已抓到真閘（全汙染源,全殲）:
  - `_threat_recent`（軍備反應式閘）
  - `_evaluate_threat` 忙碌 + 門檻雙 gate（`:388-401`）
  - `tribute_accept` FLEE 硬 override（diplomatic:40）
  - `establish_crude_camp`/`try_hunt_predator` 硬門檻（`:3285`/`:3254`）
  - `applicable()` 內 DESPERATION/OCCUPY/FORAGE 天閾（options.gd:93/103/115/121/124/149）
  - `diplomatic try_proactive_diplomacy` RNG 閘（:124）
  - + **exhaustive 再掃一遍抓漏的**（別假設 section A 完整,同稽核前提被打臉教訓——但這次是找閘不是找各算,方向相反,要窮盡）。

## ★零殘留要「證得出來」（不能人肉找）
殲滅還不夠,要**機器證「一個非框架閘都不剩」+ 擋新的**:
- **`constitution_gate.gd` 現只抓一種閘型**（禁新增引擎外 task 指派）→ **抓不到硬門檻 / override / `continue` / 絕對閾 / RNG 決策閘**。
- **強化 constitution_gate 抓全閘型**（CI-scan pattern：決策路徑上的硬門檻比較 / early-return override / randf 決策 gate…）→ **跑綠 = 證零殘留 + 擋新閘混入。**
- 這是框架硬驗收的核心——**綠 = 框架真乾淨,量測結果才可信（否則隱藏閘讓結果垃圾,一路教訓）。**

## 驗收（框架「做好」= 兩硬條件）
1. **零殘留非框架閘**（徹底殲滅 + constitution_gate 抓全閘型跑綠證明）。
2. **可擴充**（加新系統乾淨,我派的擴充性稽核回來證）。
→ 兩條都硬綠,框架才算做好 → 才談 behavior。

## 下一站
1. **exhaustive 掃全閘型**（section A + 窮盡補漏）→ 逐個殲滅（決策交引擎/人格,非補償補丁）。
2. **強化 constitution_gate 抓全閘型** → 跑綠證零殘留。
3. 我的擴充性稽核回 → 補 extension seam。
4. 兩硬條件綠 → 框架驗收 → 才 behavior/deal 側。
**用戶原則:一個殘留閘=結果垃圾。零殘留是框架硬驗收,且要機器證得出,非人肉拍胸脯。**
