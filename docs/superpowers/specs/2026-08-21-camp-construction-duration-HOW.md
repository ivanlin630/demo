---
slice: camp-construction-duration
tier: full
qa: required
from: systems
topic: camp-access 工期票 —— 「開工 1 → 完工 0」與 75% 棄置同源:人走了工地就停
---

# camp 工期端：`1 → 0`

**來源**：blueprint 裁定 2026-08-21，`camp-access` 四端同秤實測。
**`8 → 1` 歸 A1 建設族（另票）；本票只做 `1 → 0`。**

## §1 病灶（code-read，已坐實的部分）
- `outpost_system.gd:311` `ticks_left -= max(pop,1)` —— ★**要有人站在工地上才推進**
  （`faction_ai:5033` 註解自述：「走回工地（`_tick_construction` 需站上才推進）」）
- `harvest_system.gd:36-37`：無人 ⇒ `camp_ticks_left` 遞減 ⇒ **`camp_level = 0`**
- `resource_system.gd:75`：有人採集 ⇒ reset（「有人在＝不棄置」）
⇒ **「人走了工地就停」與「營地棄置 75%」是同一個機制的兩個出口。**

## §2 與已修的部分的關係（**別重做**）
`camp-access` 四端同秤**已經**讓「留在自家營地」有真實估值
（覓食讀腳下 tile 真實流）⇒ 棄置率 **89% → 75%**。
★**本票要回答的是：剩下那 75% 為什麼還走。**
**不准的做法**：加硬鎖把隊釘在工地上（`TASK_CAMP` 入 hold list 已被駁回，理由：紮營無終點 ⇒ 永久 latch）。

## §3 待驗（**先量再開藥**）
1. **那 1 個開工的工地，隊是什麼時候離開的、被什麼選項叫走的**（`camp.lost_to` 同款分佈，但限施工中隊）
2. ★**持守有沒有覆蓋到它**：`persist_strength.gd:84` 的 active-construction floor 要求
   `construction_ticks_left > 0` —— **紮根工地有設這個欄位**（`_commit_settle_site` 有寫）
   ⇒ **理論上該被 floor 保護**，**但實測沒保住** ⇒ **要查 floor 是沒生效還是被蓋過**
   ★依 `patch_gate_first` 追加判準：**分清「floor 沒擋」與「floor 沒執行到」**
3. **`build_eta_days` 修正後重量** —— `persist_strength.gd:95` 現在**高估工期 24×**
   ⇒ `safe_ratio = runway / eta` 分母暴增 ⇒ **`safe_factor` 塌 ⇒ 提早放棄**
   ★**這是 `build-eta-single-source` 票的直接下游** ⇒ **本票應排在它之後**，否則量到的是被污染的數字

## §4 排序（**寫死**）
`build-eta-single-source`（修 #3 的 24× 高估）→ **本票** → 重量 §7 三條。
★**先修工期估值再量棄工**，否則「為什麼提早放棄」的答案會被一個已知的 24× 錯誤蓋掉。

## §A ★★acceptance 頭條（blueprint 升格 2026-08-25）

**普查坐實**：`peaceful` 90 天 **outpost day0 ＝ 11 → day90 ＝ 9、中途新增 ＝ 0**
⇒ ★**這個世界只會失去據點、不會產生據點**（文明化從未發生、去文明化正常運作）。
**併同 `construct.progress 344 / stall 5871 ＝ 94.5% 停滯`。**

⇒ **本票與另一票（A1 建設族 ／ camp 工期）的 acceptance 頭條升格為**：
> ★**「從無到有蓋成一個 outpost」＞ 0 —— 文明化二值閘。**

**二值、無旋鈕可假造**（同 §7 #1 的設計理由）。**兩票落地後同床重量。**
★**blueprint 明示不開新案**：修法就是這兩票，**排程零調整**。

## §D ★量測設計：**兩趟法**（必用，見 `04_qa`）

本票要驗的是「**哪些隊棄工、為什麼**」—— ★**那幾隊幾乎一定不在等距抽樣（`SPECIMEN_SAMPLE_N`）裡**
（已四次同款：convoy porter／camp host／A1 的 start=4 有 2 筆／team15）。

**做法（同 seed，兩趟）**：
1. **第一趟**：tap 記錄「**開工但未完工的 tile 與其 `construction_team_id`**」⇒ 得到 team id 清單
   ★**前置**：`construct.stall` 需要 **per-action 維度**（A1 已列，implementer 正確拒絕把跨工程的 12.4:1 總計套到紮根）
2. **第二趟**：`SPECIMEN_TEAM_ID=<那幾隊>` 重跑 ⇒ **QA 直接讀得到棄工當下那幾隊在想什麼**

★**開票時就指定，不要等 QA 回「判不了」才補跑。**

## §E ★真實可讀的「放棄」案例：**team22**（QA 2026-08-25 撈到，直接餵本票）

QA 在 `build-eta` 那輪意外撈到一個**完整、乾淨的放棄全程**：
```
紮根委任成功 → ★被【迎戰(戰鬥)】打斷
            → 重新紮根，★連續 7 次試探【全輸給買糧】（食物壓力太大顧不上紮根）
            → 投靠被拒
            → 最終流浪覓食／逃跑
```

★★**這揭示一條與本票原假設【不同層】的放棄路徑**：
本票原本假設斷點在**工期端**（開工後撐不完）。
**team22 的斷點在更前面 —— 它根本沒能【持續】待在紮根上**：
| 層 | 機制 | 本票是否涵蓋 |
|---|---|---|
| 被戰鬥打斷 | `PRIO_THREAT` 合法穿透 hold | ⚠️**設計如此，但「打斷後回不去」要驗** |
| ★**連續 7 次輸給買糧** | **argmax 層被更急的需求持續壓過** | ❌**不在本票，也不在 A1** |
| 投靠被拒 | `feed_ok` genuine（已結案） | ✅ 已知 |

### ⚠️ systems 訂正：**我把 team22 併進本票是錯的**（implementer 指出 2026-08-25）
**team22（輸給買糧）與 team 11（輸給 `build_workshop`）是【不同的故事】，不可合併敘述**：
| | team22 | team 11 |
|---|---|---|
| 對手 | **買糧** ＝ 更急的**求生需求** | **`build_workshop`** ＝ **另一種蓋東西** |
| 性質 | 生存壓力擠掉長期投資 | ★**內部排序問題**，不是被生存壓力擠掉 |
| 世界 | `build-eta` branch 狀態 | 本票 branch（team22 這輪**只輸 1 次**） |
⇒ ★**不同 branch、不同對手、不同機制 —— 合併會編出一個不存在的因果。**
**我當時只有一個故事就把它當本票的線索，那是超前。**

★**但「連續 N 次輸給同一個對手」這個【判準】成立，而且已被實測用上** ——
counter 只說「輸了 111 次」，**故事層才看得出「同一隊、連續、輸給同一個對手」**。
⇒ ★**本票量測要加一欄：紮根的 `lost_to` 是否【集中在少數隊、少數對手】** ——
**若是，那是「排不上隊」不是「蓋不完」，修法方向完全不同。**

## §5 閘
`headless` ／ `det×3` ／ `constitution_gate` ／ `seam-gate`（HARD）／
世界驗收：**`outpost.l0_to_l1 > 0`**（§7 #1，二值）—— ★**本票 ＋ A1 票落地後同床重量**

---

## §F ★★第一趟結果：**本票原假設【工期端撐不完】證偽**（2026-08-25）

| 量 | 值 |
|---|---|
| 紮根 applicable | **102** |
| ★**贏 argmax** | **1** |
| 輸 | **101**，分佈 16 支隊 |
| ★**team 11** | **45 次（44.6%）全部輸給 `build_workshop:resource`，一次都沒贏過** |
| 次集中 | team 13／18／21 各 8 次，**全輸給 `備戰`** |

⇒ ★**102 次裡只有 1 次走到開工 ——「開工後撐不完」這一輪根本輪不到發生。**
★**§E 的判準（跑之前就寫進床裡）成立：少數隊 × 少數對手吃掉大半 ⇒【排不上隊】不是【蓋不完】。**

### per-action stall（A1 留下的前置，已補）
| action | 停滯率 |
|---|---|
| `crude_camp`（紮根） | **81.7%** |
| `upgrade_facility` | **93.7%** |
| 總計 | 92.2% |
⇒ ★**當初拒絕把跨工程總計套到紮根身上是對的**（差 12 個百分點，總計被 facility 拉高）。

## §G ★★★`try_set` 不是唯一收口：**`release()` 旁路所有 guard**

兩個數字互相矛盾（施工中隊被 `try_set` 搶班 ＝ **0**，
但持守 floor 遇到「有未完工地卻 task 已非 BUILD」＝ 4379）⇒ **必有第二條寫入路。**

**窮盡列舉 `current_task = ` ＝ 9 處**：
| 路 | 過哪些 guard |
|---|---|
| `try_set` ×4 | combat 鎖／crisis 窗／**persist hold**／優先序 |
| ★**`release()` ×1** | ★**一道都不過**（`TaskArbiter.release(` **59 個 caller**） |
| `transition()` ×1 | combat／crisis／emergency，**不過 persist hold** |
| 其餘 3 | 新隊建立豁免 |

★**「持守 floor 守的是 `try_set` 那道門，而離開的隊是從旁邊那扇沒鎖的門走的。」**
（同 memory `feedback_spec_premise_verify_decision_layer`：**機械層旁路決策層**；
 也同 QA 在 convoy 抓到的**「保護讀的狀態與事實是兩份真相」**。）

★**這與 `convoy-return-task-authority` 很可能是同一顆**：
那張票的假說 (b) 是「一次被搶就永久解鎖」，**但若 `release()` 根本不過 guard，(b) 都還沒輪到。**
⇒ ★**convoy 那張票改為【先驗 release 路徑】。**

## §H 本票結案方式（同 A1）
- ★**原 scope 證偽，無病可修。**
- ★**票不是白開**：留下 per-action stall 拆分／`root.lost_seq` 序列／`build.released` 事件級 tap／
  **9 處寫入路的窮盡列舉** —— 全是永久資產。
- ★**implementer 對自己數字的三條節制照收**：
  ① `floor_skipped 4379` 是 **per-cadence 非事件級**，且 first-N 樣本**全是同一隊** ⇒ **證明不了分佈**；
     事件級真數字是 **`build.released = 18`**
  ② 那 18 筆 `corvee` 全 `[-1,-1]` ⇒ ★**不是紮根隊**（是 `upgrade_facility`），**不得**當「紮根被打斷」的證據
  ③ `lost_seq 101 < cap 200` ⇒ **這輪沒截斷是碰巧不是保證**
- **真根移交**：**argmax 層「排不上隊」** ⇒ 已呈 blueprint 裁排序（**arc 級，非單張 slice**）。

