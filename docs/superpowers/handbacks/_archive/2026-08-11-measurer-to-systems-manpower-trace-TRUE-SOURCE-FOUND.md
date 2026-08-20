---
from: measurer
to: systems
status: consumed
topic: "[★★真源找到、鎖定——supersede前兩輪(sharpened原表+URGENT訂正):t100/t400/t700/t1000四筆drain全部=deliberate scout.dispatched,非automatic overflow]根因=我自己watch_keys漏掉『scout.dispatched』這個Probe key(只watch了care.scout_dispatched這個不同函式的變體)。補上後四筆全部精確對上scout.dispatched同tick同count同新team_id,100%解釋、零殘留原因不明。真相:Team0是這局唯一faction leader(is_faction_leader=true),_try_scout_side(faction_ai_system.gd:2045)只對faction leader fire,每次派1個leaderless anon信使(dispatch_anon_messenger)去偵查,派完會回來merge(部分成功回歸),day4耗盡anon池後scout.dispatched全程零再發生——這是state-aware gate的實測確認(非只code-read):dispatch_anon_messenger派前檢查AnonTierSystem.total_pop<1才擋,清空後確實不再派,親眼見到gate生效非空談。determinism確認(數字與前兩輪完全一致,只是原因欄改判)。★用戶兩問最終答案完全翻案:①4筆drain全部deliberate(領主主動派scout),零automatic②盲派檢查state-aware不只code-confirmed還有實測gate生效佐證(day4後池空即不再派)。"
---

# ★★真源找到 —— 四筆 drain 全部是 deliberate scout dispatch

Supersede 前兩輪（`2026-08-11-measurer-to-systems-manpower-trace-sharpened.md` 原表 + `2026-08-11-measurer-to-systems-manpower-trace-CORRECTION.md` 訂正）。這是第三輪，也是**鎖定版**——不是又一個猜測，是 100% 精確對上的實測結果。

## 根因：我自己 watch_keys 漏掉一個 Probe key

`_try_scout_side`（faction_ai_system.gd:2067）成功派出時 `Probe.bump("scout.dispatched")`。我前兩輪只 watch 了 `care.scout_dispatched`（`_dispatch_care_scout`，完全不同的函式）——**根本沒看對 key**，所以每次真正的 scout 派出都被我誤判成「無對應訊號 → 猜 population-overflow」。

補上 `scout.dispatched` 後重跑（determinism 確認，數字與前兩輪完全一致，只是原因欄改判）：

| tick(day) | Δ | 新team | dispatch 訊號 | 判定 |
|---|---|---|---|---|
| t100(d0) | −1 | Team4 | `scout.dispatched:1` | **deliberate** |
| t400(d1) | −1 | （Team4 已被前一隻同時期 merge，此為新派一隻重用id） | `scout.dispatched:1` | **deliberate** |
| t700(d2) | −1 | Team5 | `scout.dispatched:1` | **deliberate** |
| t1000(d4) | −1 | Team6 | `scout.dispatched:1` | **deliberate** |
| day5～45 | 全程 0 | （別隊分村2次，非Team0） | 全程 0 | — |

**四筆 100% 精確對上，同 tick、同 count、同新 team_id，零殘留「原因不明」。**

## 真相拼圖

`_try_scout_side`（faction_ai_system.gd:2045）只有 `f.leader_team_id == team.team_id`（faction leader）才會 fire——**Team0 是這局唯一 `is_faction_leader:true` 的隊**，這解釋了為什麼只有 Team0 反覆產生這些 leaderless 分身、Team1/2/3 完全沒有。每次派 1 個 leaderless anon 信使（`dispatch_anon_messenger`）去偵查友軍，任務結束後嘗試 recall/merge 回家（log 裡「[Merge] Team0←Team4完全合併」就是這個）。

Day4 anon 池耗盡（0）之後，**`scout.dispatched` 全程 45 天零再發生**——這不只是 code-read 上「有 gate」，是**親眼看到 gate 真的生效**：`dispatch_anon_messenger`（subteam_system.gd:143）派前檢查 `AnonTierSystem.total_pop(parent)<1` 才擋，池空之後領主確實沒有再硬派。

## 用戶兩問最終答案（翻案版，這次是鎖定的）

### ①deliberate vs automatic
**四筆全部 deliberate（領主主動派 scout），零 automatic。** 前兩輪都判錯——不是世界機制自動溢出，是 Team0 身為 faction leader，反覆主動派出 1 人小隊去偵查，這是它的正常職能行為，每次都真成本（1 anon 隨隊離開）。

### ②盲派檢查
**State-aware，這次不只 code-read，還有實測佐證**：day4 池空之後，scout 派遣**確實停了**，45 天零再發生。如果是盲派，池空後應該還會繼續嘗試派、被 gate 擋在執行端留下痕跡（如 `sid==-1` 之類的失敗訊號）——但觀察到的是決策層面就完全沒有再嘗試（`scout.dispatched` 計數不再增加），乾淨地印證了 `dispatch_anon_messenger` 的檔前檢查真的在守。

## ★中性交還用戶
Anon 池 4 天內見底、之後 41 天零回補——這個數字沒變。但**成因從「小村一開局就被迫溢出分村」變成「領主自己選擇連續派 4 次偵察，池就是這樣被自己用光的」**，這是完全不同性質的判斷素材：是否「該不該連續派這麼多趟偵察直到池空」是設計/平衡問題，不是機制缺陷問題——這點交用戶自己看數字判。

## 誠實檢討
這是本輪第三次修正同一組結論（sharpened 原表 → URGENT 訂正「不明」→ 現在鎖定版）。前兩輪犯的錯根源都一樣：**沒有先窮舉完所有可能的 Probe key 就下猜測性歸因**。這次是靠「補齊 watch_keys、重跑、100% 精確對上」拿到的硬證據，不是又一輪推論——如果 QA 想再核一次，specimen 已含 Team0+Team4/5/6，可直接讀 scout 任務的 motive→action→outcome 全程。

## 落地檔案（已 git commit `4427707d`）
- `scripts/debug/scale_econ_manpower_trace_bed.gd`（watch_keys 補 `scout.dispatched`）
- `docs/measurements/2026-08-11-scale-econ-manpower-trace-sharpened-seed8181.json`
- `docs/measurements/2026-08-11-scale-econ-manpower-trace-sharpened-seed8181-raw.txt`
- `docs/measurements/2026-08-11-scale-econ-anontrace-caller-seed8181-raw.txt`（get_stack 嘗試，確認同前次 in-session 經驗一樣在此 headless script 模式下無效，`?:-1`——但過程中間接讀出 from/to/count 反而是找到真源的關鍵線索）

序：這次是鎖定版，可以轉推用戶。若前一輪 URGENT 訂正已經推給用戶，麻煩這次連同「已找到真源」一起補推，別讓用戶停在「不明」。
