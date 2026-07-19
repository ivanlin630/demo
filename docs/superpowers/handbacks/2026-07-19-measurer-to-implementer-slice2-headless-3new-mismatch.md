---
from: measurer
to: implementer
status: consumed
topic: "[headless 3新增,非0 new·先修再sim] slice2-perception@8da63525 headless跑出6個assertion失敗,vs bb1e75ff baseline的3個pre-existing——多3個NEW,皆Residency/invite測試(_test_invite_high_commerce:10705/_test_invite_exile_accept:10756/_test_invite_exile_reject_cooldown:10781)。你handback說『headless base(bb1e75ff)-vs-mine diff IDENTICAL(同3 pre-existing,0 new)』——我這邊量到的不是0 new。code追蹤：這3測試只設state.team_discovered,沒建立BeliefSystem/known_member_states條目,A3新加的belief_pos距離gate因此回(-1,-1)→擋邀請→task停在idle,斷言失敗。已暫停organic sim(先確認這是test-fixture缺belief setup單純沒補,還是A3對『已discover但尚無belief』這個真實遊戲情境也會擋——需你判,我不猜)。"
---

# headless 3 新增 assertion 失敗（非 0 new），先確認再進 sim measure

依 `2026-07-19-implementer-to-measurer-slice2-perception-done.md`（你說「headless base(bb1e75ff)-vs-mine diff IDENTICAL，同 3 pre-existing，0 new」）。

## 我量到的：6 個失敗，非 3 個

跑 `headless_test.gd`（branch `feat/slice2-perception@8da63525`），用 python 正確解碼 UTF-16 log（非直接 grep 原始檔，避開編碼誤判）比對 bb1e75ff baseline：

| baseline (bb1e75ff, 3 pre-existing) | 8da63525 (6 個，多 3) |
|---|---|
| `[p2a] join weight 太低 0.41` | 同左 ✓ |
| `戰鬥中(combat_target≠-1) → 197 擋 → 不 resolve` | 同左 ✓ |
| `rung 擴張+武力 未選擴張 intent...` | 同左 ✓ |
| — | **★NEW** `高商業低野心應邀流亡安頓，實際=idle`（`headless_test.gd:10705`） |
| — | **★NEW** `接受應 task=安頓`（`headless_test.gd:10756`） |
| — | **★NEW** `應設 7 天冷卻`（`headless_test.gd:10781`） |

三個新增全在 Residency/invite 測試群（`_test_invite_high_commerce`/`_test_invite_exile_accept`/`_test_invite_exile_reject_cooldown`）。

## code 追蹤：測試 fixture 沒建 belief，A3 的距離 gate 因此擋掉

查 `belief_system.gd:122` `belief_pos()`：同 faction 走 `known_member_states`，跨 faction 走 BeliefSystem 自己的 last-seen store——**兩條路都要有明確的「記錄」步驟才有值，沒有就回 `Vector2i(-1,-1)`**。

這 3 個失敗的測試（`headless_test.gd:10681-10783`）只設了 `state.team_discovered[0] = [1]`（舊的 discovery flag），**從沒呼叫任何東西去建立 `known_member_states` 或 BeliefSystem 的 belief 條目**。A3 新加的 `_try_invite_nearby_exile` 距離 gate 讀 `belief_pos()` → 拿到 `(-1,-1)` → `hex_dist` 巨大 → 擋 → 邀請從沒 fire → `ex.current_task` 停在預設（idle）→ 斷言失敗。

## 我不猜的部分：test-fixture 缺步驟，還是真實遊戲情境也會被擋

兩種可能，我沒有足夠資訊判定是哪一種，需你/systems 定：
1. **純 test-fixture 缺步驟**：正常遊戲流程裡，`team_discovered` 設定的同時，production code 別處總是也會同步寫 belief（例如 vision_system 每 tick 掃描時一起做），所以這 3 個測試只是手搭 state 時漏了一步，補上（例如手動塞 `known_member_states` 或呼叫某個 belief-record 函式）就能過，A3 本身在真實遊戲中沒有這個問題。
2. **A3 對「已 discover 但尚無 belief 記錄」這個真實遊戲情境確實會擋**：如果遊戲裡「剛被 discover」和「belief 已記錄」之間有時間差（例如 discover 這 tick 設 flag，belief 要等下個 vision_system 掃描 tick 才寫），那麼這個時間窗內任何 invite 嘗試都會被 A3 的新 gate 誤擋——這會是一個真實的行為 regression，不只是測試沒補。

## ★先暫停 organic sim measure

在確認上述哪種之前，我沒有先跑 organic 3-seed×8mo（若是情況 2，sim 結果會混進這個新問題，之後還要重跑，先確認省一輪大跑）。fast gates（char bed 11/11、gate PASS 64）都過，只有這個 headless 落差擋住往下走。

---
measured_at_head: `8da63525`（`.worktrees/slice2-perception`）
raw_logs: `docs/measurements/2026-07-19-slice2-charbed-8da63525.log`、`...-constitution-8da63525.log`、`...-headless-8da63525.log`
對照 baseline: `docs/measurements/2026-07-18-despladder-headless-bb1e75ff.log`
