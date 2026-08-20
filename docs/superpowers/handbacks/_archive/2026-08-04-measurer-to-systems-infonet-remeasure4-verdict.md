---
from: measurer
to: systems
status: consumed
topic: "[資訊網whole RE-measure#4 verdict(5c7da204 letter-carrier後):★★黑洞真根治——explicit fixture(FACTION bed)help.delivered=8/8(前輪8 heralds全0)、letter_timeout=0、letter_intercepted=0,lifecycle無黑洞驗證通過。領主真聞:help.need_deposited=2(真order_buy訊息landed進lord team_known)。★但distribute.dispatch仍恆0(全部6場景),即使letter真送達+領主真聞,distribute機制依然不fire。讀code定位精確結構觀察(goal_resolver.gd:168-169):_distribute_candidates用_resident_food_runway()直讀resident LIVE team state判斷deficit(非讀delivered belief本身),T1 day60真值runway=4.58d剛好在DISTRIB_DEFICIT_DAYS=4.0門檻之上——這代表candidate生成的『有沒有need』判斷跟letter傳來的『distress訊息』是兩條分開的路徑,letter只決定lord『知道有這個居民』但deficit認定另外重查live值,可能造成timing mismatch(distress訊息landed時當下resident可能已不再deficit,或反之)。resident runway未見真回升:T1終態food=7.3/runway=4.58d(僅存活未紓困)、T3仍死/併。★warring側兩seed跟RE-measure#3逐項byte-for-byte完全相同——letter_dispatched在warring仍恆0,因為target_resolved在seed1337=0/105、seed42=5/62(即使target解出仍未達mini-util門檻),letter-carrier修復根本沒被exercise到(warring世界從未真dispatch過letter,新carrier機制在此完全沒觸發)。determinism explicit fixture 2跑byte-identical。清理main完全git驗證乾淨;worktree本輪index.lock復現(疑implementer活躍寫下一修),已用直接Edit還原確認檔案內容層級乾淨,git層驗證待鎖解開。落地7檔已ls/wc驗證。"
---

# 資訊網 whole RE-measure #4 → systems（★★黑洞真根治——letter 全數送達零黑洞——但 distribute 仍不 fire，定位到精確結構線索）

工單：`2026-08-04-systems-to-measurer-infonet-remeasure-4-faction-bed.md`（已消費）。branch `feat/info-network-whole 5c7da204`（herald 非 team carrier：`state.in_transit_letters`）。同前四輪 fixture 設計直接對照（此 fixture 本身即 lord+resident+固定outpost faction bed）。

## ★★核心答案：黑洞真的根治了，但下一關（distribute）依然沒過

| 驗收項 | 前輪(ea8d4dbd) | 本輪(5c7da204) |
|---|---|---|
| `help.letter_dispatched`（explicit fixture，T1/T3） | 8（T1=8/T3=0） | **8（T1=8/T3=0，完全一致，人格分化持續正確）** |
| `help.delivered`（explicit fixture） | **0/8（黑洞）** | **8/8（★根治！）** |
| `help.letter_timeout` / `letter_intercepted` | — | **0 / 0（lifecycle 無黑洞：全部有明確結局）** |
| `help.need_deposited`（領主真聞） | 0 | **2（真 order_buy 訊息 landed 進 lord team_known）** |
| `distribute.dispatch`（全部 6 場景） | 0 | **仍 0（全部場景）** |
| resident runway 真回升 | — | **未見（T1 終態 runway=4.58d，僅存活未紓困；T3 仍死）** |

## ★★①黑洞真根治：letter lifecycle 乾淨
explicit fixture（seed1337）：T1 派出 8 封信，**全部 8 封都送達**（`help.delivered=8`），`letter_timeout=0`、`letter_intercepted=0`——**沒有一封信憑空消失**。這直接驗證了前輪診斷的「full-sim 黑洞」（on_leader_death 升 named 吃信使子隊）已被 `state.in_transit_letters`（非 team 物件）根治。這條線我認為是紮實的正面結果。

## ★②領主真的「聞」到了——但 distribute 依然不 fire
`help.need_deposited=2`——這代表確實有 2 筆真實的 `order_buy` 訊息被 deposit 進了 T0（領主）的 `team_known`，領主端的資訊確實抵達了。但 `distribute.dispatch` 仍是 0。

我讀 code 定位到一個具體、精確的結構線索（`goal_resolver.gd:168-169`）：`_distribute_candidates` 判斷某個居民是否「該救」時，走的是 `_resident_food_runway(state, resident)`——這是**直接讀 `state.teams[rid]` 的即時（live）狀態**，不是讀 letter 傳來的 belief/訊息本身。也就是說：letter 只負責讓領主「知道有這個居民」（透過 `received_buy_orders()` 掃到訊息），但「這個居民現在算不算 deficit」是**另外重新查即時真值**判斷的（`if runway >= DISTRIB_DEFICIT_DAYS(4.0): continue`）。

T1 在 day60 的即時 `runway=4.58d`——**剛好落在 4.0 門檻之上**（非 deficit）。這代表 letter 抵達的那個時間點跟領主實際評估 distribute 候選的時間點之間，**T1 的即時 runway 可能已經飄回門檻之上**（因為 T1 中途曾有過短暫的糧食好轉），導致即使訊息真的送達了，distribute 候選判定時看到的即時真值已經不再是 deficit。**我不代下這一定是根因**（我沒有直接在 `_distribute_candidates` 求值當下 tap 出 T1 的即時 runway 快照，只看到 day60 這個單一時間點的巧合），但這是一條具體、可驗證、值得你追的線索。

## ★③resident runway 未見真回升
T1 終態：`food=7.3 runway=4.58d`——比起完全斷糧稍微好一點，但**沒有 distribute 送糧的痕跡**（`distribute.food_delivered=0.0`），T1 是靠自己（覓食等既有機制）撐住，非 info-network 症1 鏈救的。T3 依然餓死。**端到端的真實效果（[[feedback_verify_execution_end]]）沒有達成**。

## ★④warring 側：兩 seed 跟前輪逐項 byte-for-byte 完全相同——letter-carrier 修復完全沒被 exercise 到
seed1337：`attrition_pct=1.13%`、`teams=105`、`combat.ended_n=16`、`trade.deal=58`……**跟 RE-measure #3 的對應數字一模一樣**。seed42 同樣完全一致。原因很清楚：`help.letter_dispatched=0`（兩 seed 皆是）——因為 `target_resolved` 在 seed1337 是 **0/105**、seed42 是 **5/62**（即使 5 次解出 target，也沒有一次真的派信，代表 mini-util 依然沒過門檻）。**letter-carrier 這個修復本輪根本沒有機會在 warring 世界被真正跑到**（連 dispatch 都沒發生過，delivery 機制自然無從測起）。這不是本輪修復失敗，是上游（target-resolve/mini-util）依然卡住，跟前兩輪的結論一致。

## regression 檢查（Part1/3 不退）
`trade.deal`/`board.relay_deposit`/`scout.dispatched` 兩 seed 皆與前輪一致（因整個世界軌跡沒變），非退化。

## determinism + 不凍
- **explicit fixture**：seed1337 兩跑，`diff -B -w`（排除 TickPerf）逐行 byte-identical。
- **warring 側**：本輪同前三輪判斷，未做 3 跑 determinism repeat（時間考量；6 個場景皆在延長 timeout 內順利完工無 hang）。

## specimen trace
`docs/measurements/2026-08-04-infonet-remeasure4-specimen-seed1337.jsonl`（已 landed），沿用 canonical hook。

## 清理確認
main 側：完全 `git status --short` 確認乾淨。
worktree 側：**本輪 `index.lock` 再次出現**（疑另一 process/session 正在寫下一個修復，未強制解鎖）——`resource_system.gd`/`warring_harness.gd`/`faction_ai_system.gd` 三處 temp tap 已用 `Edit` 直接還原（檔案內容比對確認乾淨），`config/infonet_whole.json`/兩份 bed 副本已用 `rm` 刪除；**git 層驗證因鎖擋住做不了**，建議你/implementer 方便時順手補驗 `git status`。

## 落地
raw（7 檔，已 `ls`/`wc` 驗證）：
- `docs/measurements/2026-08-04-infonet-remeasure4-whole-seed1337-run{1,2}.txt`
- `docs/measurements/2026-08-04-infonet-remeasure4-warring-{main,branch}-seed{1337,42}-1mo.txt`
- `docs/measurements/2026-08-04-infonet-remeasure4-specimen-seed1337.jsonl`

## ★誠實淨判（[[feedback_genuine_value_not_crank]] 精神，非 accept 結論）
**這輪修復做到了它宣稱要做的事**——letter lifecycle 真的乾淨了（8/8 送達、0 timeout、0 intercepted），這是連續 5 輪量測以來第一次看到「派出的信全部有交代」。但**症1（distribute 鏈）依然沒有端到端打通**——這次卡點又往下游移動了一格：以前是「送不到」，現在是「送到了，但收信人（distribute 候選判定）看的是另一份即時真值、不是這封信本身」。我定位到一條具體、file:line 可查的結構線索（live-state re-check vs belief-delivered），但沒有直接證據證明這就是唯一/主要原因，如實回報供你判斷。escaped_defects：`_distribute_candidates` 的 deficit 判定與 letter 傳遞的 distress 訊息之間可能存在 timing mismatch（值得加一個「letter 剛送達時 resident 即時 runway」的 tap 直接驗證）；warring 世界裡 target-resolve/mini-util 上游瓶頸仍未解（連續 3 輪一致）。
