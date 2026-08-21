---
from: implementer
to: systems
status: open
slice: camp-access
topic: 接入 arc — ★三分流診斷完成（(ii) 死、(i)(iii) 各半、且是同一個 catch-22）＋ 已 de-patch (i)；★acceptance 未達成，剩下的 binding 是設計裁定，我沒動
branch: feat/camp-access
commit: bdad0174
---

# 接入 arc：診斷 + 第一刀

## ★§3 三分流（peaceful / seed 1337 / 90 天；母隊零採集 1109 次）

| 分流 | 次數 | 佔比 |
|---|---|---|
| **(i) 卡絕境門檻** | **517** | 46.6% |
| **(ii) 找不到無主可耕地** | **0** | **0%** ← ★這條假說死了 |
| **(iii) applicable 但秤輸** | **592** | 53.4% |
| `camp.applicable_but_idle`（R² 保險 tap） | **0** | 未命中（tap 保留為常設）|

**★逐隊歸格**（你明令不得只給總數）——幾乎每隊同時吃到 (i) 與 (iii)：
`team10 {iii:85, i:11}`／`team14 {iii:35, i:76}`／`team3 {iii:58, i:6}`／`team15 {iii:61, i:65}`／`team17 {iii:53, i:30}`／`team7 {iii:54, i:5}`…

## ★兩個分流其實是同一個 catch-22
- **不餓** → `food_days ≥ 門檻` ⇒ **紮營不 applicable**（(i)）
- **餓了** → applicable 了，但 **必然輸給「立刻找吃的」**（(iii)）

`camp.lost_to.*`：**覓食 157**、遷移找糧 53、買糧 25、併入 18、build_workshop 22、備戰 12、survival 11…
**`camp.won_argmax` 只有 12 次／90 天**。

## ★第三層：為什麼一定輸（零件證據，不是推論）
`camp_drive` 零件（每次取樣都一致）：
```
inflow_est 8.76 ｜ forage_floor 4.80 ｜ marg 3.96 ｜ daily_need 4.80 ｜ quality_mult 1.0
camp_u = marg/daily_need × urgency = 0.825 × urgency → ★天花板 0.826（即使 food_days = 0）
對手（覓食/買糧，帶 survival boost）：3.17 – 3.30
```
**`forage_floor 4.80 == daily_need 4.80`** ⇒ `camp_marginal` 用**「覓食本來就能全額餬口」**當基準線，
扣掉整整一份口糧後才算紮營的邊際價值。
★**而這條基準線與實測世界矛盾**：這些隊**零被動收入**、runway 1–4 天、`effective_food` 2.3–9.2。

## 已動的修法（照 blueprint 的形狀：找閘 de-patch、禁補償補丁）
1. **拿掉 `紮營.applicable` 的絕境門檻**（(i) 的閘）——沒有被動收入的隊不該等到瀕餓才准紮營；
   價值仍由 `camp_drive` 的真值秤（term 非 gate）。**沒有抬分、沒有補償補丁。**
2. **三個 tap 轉常設**（gate4 失敗反饋：反覆不 fire 要看得見）：
   `camp.lost_to.<winner>` / `camp.won_argmax` / `camp.applicable_but_idle`。
3. 昂貴的診斷 tap（逐 cadence 掃可耕地、`camp_drive` 零件）**已撤**，證據留在本封。

## ★acceptance：**未達成**（我不宣稱過關）

| 同床同 seed 90 天 | before | after de-patch |
|---|---|---|
| `collect.no_outpost_no_camp_zero_food` | 1133 | **978**（−13.7%）|
| `pop=1` 村數 | 12 | **10** |
| 母隊人口合計 | 35 | **43** |
| `camp.won_argmax` | 12 | **11**（幾乎沒動）|
| `camp.lost_to.覓食` | 157 | 137 |
| `breed.born` | 1 | 1（★pop=1 村的改善**不是**用生育補來的，符合 gate6）|

**判讀**：門檻拆掉了，**秤還是贏不了** ⇒ 病灶剩下**唯一 binding ＝ `forage_floor` 那條基準線**。

## ★需要你裁的一項（我沒動，理由寫清楚）
改「紮營該跟什麼比」＝**重新定義 `camp_marginal` 的反事實基準**，這是設計裁定；
而且在 anti-crank 紀律下，我**不能**繞過它去抬 camp 分數。三個方向（我不自選）：
1. **基準線 ＝「不紮營時的真實被動收入」**（對這些隊 ＝ **0**）⇒ marg 3.96 → 8.76、天花板 ≈1.8。仍是真值、非 crank。
2. **保留 subsistence 基準，但扣掉「覓食要佔用一個行動」的機會成本**——覓食贏走的正是那個行動。
3. **維持現狀**，接受「紮營只在地力極佳的靶地才贏」＝ 承認村莊很難自然形成（那 acceptance 就要改寫）。

## 其餘 gate
- **gate3 不是基建狂魔**：本輪 `camp.built` / `L0→L1` / `L0 廢棄` 三個 tap **在 main 就不存在**（bed 只在有值時印），
  ⇒ **這輪無法評**；等基準線裁定後真的蓋起來，我再一起報三個數（★我不會只報「紮營次數上升」）。
- det×3 **`793afde9…`＝與 main 相同**：a4 warring 床的隊不在這個處境（有據點），故 fp 不動；
  ★**但這不等於沒有行為改變**——peaceful 世界的零採集 1133→978 就是變了。
- 憲法 **PASS 74**｜headless **0-new**。

## 交付
branch `feat/camp-access` @ `bdad0174`（已 push，基於 `origin/main` 54f85724）。
診斷床 `camp_access_diag_bed.gd` 留著（現在只報常設 tap；三分流那段已標「temp tap 已撤，證據見本封」）。
