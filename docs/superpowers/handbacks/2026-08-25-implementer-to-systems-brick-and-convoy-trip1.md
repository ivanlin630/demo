---
from: implementer
to: systems
status: consumed
slice: failure-memory-structural-identity + convoy-return-task-authority
branch: feat/failure-memory-structural-identity @ 9d94b696 ／ feat/convoy-return-task-authority @ c34de246（皆 pushed）
topic: ★磚交件:覆蓋 2 個 option → 19 個結構 id/760 次折價,build_workshop:resource 被折 140 次(那條一直重贏的路咬得到了);過渡窗證實斷代自癒;★det fp 沒變但票面說會變,照實記為「床沒覆蓋 vs 沒生效」需靠覆蓋率分辨·★★convoy:我的分母第一版是同語反覆,已修;修後 QA 那個現象【沒重現】,要 QA 的執行指紋才能對帳
---

# 兩張票

---

# A. 失敗記憶結構身分磚（`9d94b696`）

## §1 ★覆蓋率（`00_roles §覆蓋欄`：記 done 必同記覆蓋率）

| | 舊制 | 新制（peaceful / seed 1337 / 90 天）|
|---|---|---|
| 接線面積 | ★**2 個 option**（表裡寫死 `買糧`／`買料`） | ★**19 個 distinct 結構 id 真的被折價** |
| 失敗記錄 | — | **569 筆**：**569 走結構身分**、**9 筆 fallback** |
| 折價生效 | 只咬得到 `買單` | ★**760 次**，★**含 `build_workshop:resource` 140 次** |

★**那條「一直重贏」的路現在咬得到了** —— 這正是本票存在的理由。
exact-pair 實例（同 id 不同 target **各自獨立**、沒有偷做類級泛化）：
`build_workshop:resource|5,9` ／ `|10,10` ／ `|6,6`。

## §2 ★死水兩欄（§5.5 —— 別做出第三個「恆 1.0」）
- **呼叫頻率**：`failure.entries_written = 569`（非零）
- **折價真的生效**：**760**（★床裡先寫死判準：**若為 0 ⇒ 這就是第三隻，必須回報不得放行**）
- **輸入變異性**：單隊條目數上限 **4**（bounded，不會無限長）

## §3 ★過渡窗（reviewer 建議／你採納：假設要自己喊）
```
首次命中：tick 1210（team 0，key 駐守|-）
逐日活條目數：0,0,0,0,0,16,16,16,17,17,29,29,29,27,27,13,... → 後 10 日穩定在 21～23
```
⇒ ★**「一輪就換完」這個假設【被證實】** —— 不是停在 0、也不是無限膨脹，是**升起後穩定**。
**斷代自癒成立**，記憶清空的代價確實只有過渡窗那幾天。

## §4 ★一件不符票面預期，照實記
**`det fp` 沒變**（`c1e3f7c5…` ×3，與 base 相同），**但 spec §5.4 寫「預期會變 ＝ intended-change」。**

★**我不把它讀成「行為沒問題」** —— 它**同時相容於**：
- (a) a4 那 1000 tick 的床沒跑到被改的路徑（買單到期／candidate 得分），與
- (b) 磚根本沒生效。

★**分辨這兩者的是 §1 那份覆蓋率，不是 fp。**（同 `eta-single-model` 那次的床覆蓋度情報。）
⇒ **建議 measurer 重量時，acceptance 用覆蓋率與 suppressed 分佈，不要用 fp。**

## §5 照裁定做的
`OPTION_FAIL_KEY` **已刪**；靜態 option 與 candidate **同一入口、同一 key 空間**（§4）；
`∅` 是 **fallback 不是預設**（§3b 訂正）；**先 exact-pair、不預做類級泛化**（§3）；
既有四項（連續折價／TTL／失效升 T0）**未動**；記憶斷代標 **`intended-change`**、
**切換當下既有記憶清空**（過渡窗 §3 已證自癒）。

**成本照實**：`_mk_candidate` / `_mk_delegate_candidate` **＋ `_delegate_variant`（第三個造 candidate 的地方，你 §0b 沒點名）**
各補結構欄位；`order` 多帶 `fail_id` / `fail_target` 兩欄；四條 dispatch 路都蓋身分
（★含 survival 路 —— 它不設 `current_option`，漏了那條的買單就會沒身分）。
`failure.key_fallback_no_dispatch_id = 9/569` ⇒ 沒帶到身分的**沒有靜默丟失**，看得見。

## §6 閘
headless **8 ＝ baseline 0-new**／憲法 **PASS(74)**／det×3 **穩定**（值見 §4）／
TDD **ALL PASS**（含 §5 四條：測規律不測結果／反面不受影響／同入口／exact-pair 不合併）。
★`seam-gate`（HARD）需 QA verdict，我沒跑、**不用 `SEAM_MODE=soft` 繞**。

---

# B. convoy 第一趟（`c34de246`）★**先講我自己的儀器錯**

## §1 ★★我的分母第一版是【同語反覆】，已修
第一版把「RETURN 期間 task 是不是運輸」的分母掛在 `_tick_convoy` 裡，day25 量到 **886/886 ＝ 100%**。
★**但 `_tick_convoy` 的呼叫條件本身就是 `current_task == TASK_CONVOY`**（`faction_ai:2771`）
⇒ **我只數到「task 還是運輸的那些」，佔比恆等於 100%，是選擇偏差，不是答案。**

⇒ 已移到 `_evaluate_subteam` 入口（**看得到所有子隊、不論 task**），
並在 code 註解寫死「為什麼不能搬回去」。
★**這是我這幾輪一直在別人數字上抓的那個病，這次發生在我自己的儀器上；在報出去之前戳破。**

## §2 修後的數字（★**PARTIAL：day 25/30，warring 30 天再次撞 900s timeout**）
```
convoy.rewrite.try_set / try_set_defy / release / transition  = 0 / 0 / 0 / 0
RETURN 期間 task=運輸：886 / 886 = 100.0%
對照：dispatch 27 / deliver 18 / deliver_settled 9 / return 21 / stranded 0
```
★**已加 sidecar**（每 5 日覆寫、明標 `PARTIAL（不得當完整輪讀）`）⇒ 被 reap 也讀得到，且不會被誤當完整輪。

## §3 ★★QA 那個現象在這張床【沒有重現】—— 我不下對錯結論
QA 報的是 `team123（及 86／162）連續 20+ 個樣本 convoy_phase=RETURN 但 task ≠ 運輸`。
**我這輪（修好分母後）RETURN 期間 task 全部是運輸、改寫路徑全 0。**

⇒ ★**這不是「QA 錯了」**，是**兩份數字的執行條件不同**。照你自己立的規矩（無指紋不對帳），
**要先對口徑再談誰對**。**我需要 QA 那輪的執行指紋**：
1. **config / seed / tick 窗**（我這輪：`warring_states` / 1337 / **只跑到 day 25**）
2. **跑在哪個 branch**（我猜是 `build-eta` 那輪，**在 camp-access 與 build-eta 兩次 merge 之前**）
3. **工作區乾不乾淨**
4. **specimen 的取樣方式**（等距抽樣 vs `SPECIMEN_TEAM_ID`）

★**一個高嫌疑但未驗的可能**：QA 那輪在 `eta-single-model` 之前／之中，
而**那張票把 T3 預算從「餘裕 0」改成「真 3×」**⇒ porter 在路上的時間分佈本來就變了。
**這是假說，我沒有證據，標待驗。**

## §4 下一步（等你裁）
- **要不要把這張床跑滿 30 天**（拆成兩段跑，或降到 20 天換完整輪）
- **要不要先跟 QA 對指紋**再決定第一趟結論
★ 在那格定案之前，**原本那兩個假說我不動**（你說「這一格定了，它們才輪得到」）。
