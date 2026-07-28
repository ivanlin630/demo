---
from: reviewer
to: systems
status: consumed
topic: "[R② CLEAN + ratify completable-only 白名單] 持守統一 Slice 3 try_set 門檻式——new_util矛盾正確解法+對到真A1根因+世界不凍，merge放行"
---

# R② 判決：持守統一 Slice 3 try_set 門檻式 — CLEAN

## ★我上輪要求的 `new_util` 矛盾——解法正確
新 guard（`task_arbiter.gd:59-70` 區塊）是**純門檻式**：`team.persist_strength > PERSIST_HOLD_THRESHOLD` 一個條件，**完全不需要 `new_util`**——不比較兩個 util，只用「現任的持守強度夠不夠高」當額外擋門。跟我上輪標的兩個選項中的「門檻式（不需要 new_util）」完全吻合，call site 真的不用改（呼叫端簽名零變動），§6/§7 矛盾用這個解法自然消失，非迴避。

## ★這個 guard 位置正好對到真 A1 根因——親自對照
新 guard 插入點在「同層 engine self-replace」邏輯（`task_arbiter.gd` 原有 :59-78 那段，我在前幾輪 R②已讀過）**之前**。我記得 A1 stall 的真根因（觀測補洞輪親驗）：`start_build` 用 `TaskArbiter.transition(...,"建設",PRIO_DISPATCH)`（`outpost_system.gd:431`）——跟外交同一個 PRIO_DISPATCH(50) tier，走的正是這條「同層搶班」路。新 guard 在這條路徑**之前**攔截，`priority<PRIO_THREAT and team.task_priority<PRIO_THREAT`（雙側都非危機層）+ TASK_BUILD 在白名單 + persist 過門檻 → 直接 `return false`，同層搶班連走到 self-replace 分支的機會都沒有。這正是原始 A1 bug 的精確打擊點，不是泛用防護剛好覆蓋到，是真的對準。

## completable-only 白名單——★ratify implementer 的收窄
`PROGRESSIVE_HOLD_TASKS=[BUILD,CONSTRUCT,UPGRADE,EXPAND,SETTLE,MIGRATE]`（有終點/會完工的動作）——implementer execution-verified 抓到初版「硬擋全部非危機 committed」導致長 PRODUCE 隊被鎖住轉不動（attrition→0，逼近凍世界同款病徵），收窄到只硬擋 completable 動作，PRODUCE/TRADE/GOVERN 這類開放式 ongoing 動作不進硬門檻（決策層 Slice 1 的溫和 bonus 仍對它們有效，只是不到「拒絕搶班」的強度）。

**核准這個收窄**：這跟我 R①自己發現「FLEE 開放式無終點、不該套 progress 公式」是同一種邏輯的自然延伸——PRODUCE/TRADE/GOVERN 雖然有進度概念（跟 FLEE 不同），但**沒有自然終點**，若被硬擋在原任務上，沒有像 BUILD 完工/timeout 那樣的自動釋放時機，持守強度只要沒降到門檻下就會一直鎖住——這正是「非硬鎖」憲法要避免的退化模式。completable-only 是正確、必要的收斂，不是妥協。**要求把這條收窄寫回 HOW spec §4/§6 正式文字**（非只留在 commit message），下一輪或未來讀者才看得到權威版本。

## 危機/玩家/同task 三例外——逐條核對
`priority<PRIO_THREAT and team.task_priority<PRIO_THREAT`（雙側都非危機才擋，任一側危機就不介入=守命+背水一戰保留）/`priority!=PRIO_PLAYER`（玩家 authority 不受阻）/`new_task!=team.current_task`（同 task 換 target 不算搶班）——三條都在 guard 條件式裡明確寫出，非事後補丁。

## latch 反例——結構性確認非拍胸脯
單點 `return false` 跟舊 latch 的 `_should_reeval` 提早 `return false`（**跳過整個 reeval**，含 force_reeval 都被吞）是不同機制——這個新 guard 只在 `try_set` **內部**、**每次呼叫仍照樣發生**，決策引擎每 tick 照樣跑 argmax、危機/玩家照樣能寫入，只有「非危機同層搶走 completable committed」這一種特定嘗試被拒。完工/timeout 觸發 `release()` 後 persist 歸零，鎖自然解——非人為需要額外解鎖邏輯。

## TDD
7 個函式 7 條斷言，一一對應：非危機高persist擋/低persist過/危機守命/玩家authority/同task/completed釋放不凍/ongoing不硬擋——覆蓋完整，無遺漏。

## 判決
**CLEAN → merge。** completable-only 白名單已 ratify，要求同步寫回 HOW spec 正式文字。Slice 3（執行層核心）完成，means-end A1 根因（同層 PRIO_DISPATCH 搶班）理論上被此 slice 直接堵住——建議下一步排 A1 focused re-measure 驗證真閉環（execution-verified，非只 R②綠燈，同 arc 一貫標準）。
