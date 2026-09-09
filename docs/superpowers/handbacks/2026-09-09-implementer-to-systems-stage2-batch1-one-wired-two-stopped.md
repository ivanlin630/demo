---
from: implementer
to: systems
status: consumed
slice: 失敗反饋 階段 2 第一批
topic: ★三條裡只接了一條（`96291e95`）：乞食接線＋三個拒絕入口全記｜★★**外交／求和【停工】**——它們已經有 `diplomacy_reject_cooldown` 硬 gate，再加折價＝**同一個失敗長出第三種形狀**，而那正是鐵律寫著「別再擴散」的那件事｜★★★而 `rejected_aid` 原本是【三處寫、零處讀】：這條訊號在 code 裡活了很久，從來沒有人消費它
---

# ① 乞食：接了，三題答案逐條

```
①什麼算失敗  乞食被拒（aid_refused）——【做不成】：對方拒絕給糧,不是「給得太少」
②target 是誰  被乞求的那一隊,走 "ctx:aid_target_id"（★逐次目標）
   ★理由：施主是每次決策當下選的;寫死字串 ⇒「對一個人乞食失敗,對【所有】施主折價」（spec §5② 的接太粗）
   ★★而「不知道對誰」(-1) ⇒ 不折價,不是退回粗粒度 ——【不知道對誰】與【對誰都一樣】是兩件事
③TTL          BeliefSystem.BELIEF_STALE_TICKS（＝3 天）
   ★不是挑一個數字,是【借這件事自己的週期】（同 order_system:226 借 ORDER_LIFETIME 的做法）：
   乞食目標由 `_find_aid_target` 從 belief 選出,而【沒有 belief 的隊直接跳過】
   ⇒ 這筆「他拒絕過我」只在【當初讓我去找他的那份情報還新鮮】時有意義;
   ★★情報過期後那個目標本來就選不到了 ⇒ 折價再活下去是多餘的。
   ★★★這是【推導】不是【抄先例】,你要否掉我照改。
```

★**三個拒絕入口都記了**（`interaction_system:1493` NPC 拒絕／`player_command_system:1000` 玩家拒絕／
`sim_runner:331` 玩家逾時視同拒絕）—— ★★**被誰拒絕不該決定有沒有學到。**

★★★**而我要單獨報一句**：`rejected_aid` 這個訊號**原本是三處寫、零處讀**。
它不是「還沒接上」，是**寫了很久而從來沒有人消費** —— ★**跟死鍵那族同形**：
`values.get("順從")` 是讀一個沒人寫的鍵，這是寫一個沒人讀的事件。**兩者都不會報錯。**

# ② ★★外交／求和：這批【不接】，而理由不是 TTL

**它們已經有失敗反饋了，形狀是【硬 cooldown】**：

```
diplomatic_ai_system.gd:7    const REJECT_COOLDOWN = TICKS_PER_DAY * 7
                    :178/187 sender.diplomacy_reject_cooldown[target] = tick + REJECT_COOLDOWN
interaction_system.gd:528/536/583  同上（三處寫入）
decision_context.gd:730      c.pacify_target_on_cooldown / c.diplo_target_on_cooldown
options.gd:379/486           applicable 直接讀那兩個 flag ⇒ ★cooldown 內【option 消失】
```

⇒ ★**再加一層連續折價 ＝ 同一個失敗事件長出第三種形狀**（硬 gate ＋ 折價並存），
而〈執行失敗反饋鐵律〉§1 寫的是：
> 形狀統一走「連續折價」、不走「硬 cooldown」…… `join_rejected` 的 cooldown 形狀**列為待統一項**
> （非本輪、但**別再擴散第三種形狀**）。

⇒ ★★**正解是 de-patch**：拿掉 `applicable` 上的硬 gate、換成折價（TTL 借現成的 `REJECT_COOLDOWN` 7 天，
零新數字）。★★★**那是行為改動**（cooldown 內的 option 會重新出現、由引擎自己秤），
**scope 比「接一條線」大，而且它會動 fingerprint** ⇒ **我不自決，交你裁**。

★**這也解釋了為什麼第一批只剩一條**：spec 的候選排序沒有把「**這個 option 已經有另一種形狀的反饋**」
當成一個過濾條件 —— ★★**而那正是階段 1 第三格（已有等價機制）的隔壁那一格**：
第三格是「**已有等價、形狀合法**」（`SettlementMemory` 折價）；
外交/求和是「**已有等價、但形狀是憲法要溶掉的那種**」。⇒ **需要第四格，或把它們改標成第三格＋註明待 de-patch。**

# ③ 驗收五格（`SECTIONS=5/5 FAILS=0`）

```
①join 表 28 列全印｜候選 13 條只從【待接】取
  ★成對對照：unmapped 排第 2 的『迎戰』（判準不成立）被擋在候選外 ⇒ 這張表真的在守
②三題答案在 code 裡看得到；三個拒絕入口用同一個既有週期常數（3/3）
③連撞同一施主 0.800 → 0.600 → 0.400｜failure.suppressed.乞食 非零
  ★換一個施主(9) 回 1.0（折價沒波及無辜目標）｜★★目標未知(-1) 不折價
④買糧 0.800/0.600/0.400 與【公式重算】一致（本票不動折價公式）；買單失敗不波及乞食
⑤raw 0｜eff 0｜gate n/a
```

# ④ ★⑤那個 0 我做了分解（沒有只交一個 0）

```
raw=0 的分解：★入絕境的隊 0 ｜ aid.calls 499（找施主被呼叫 499 次）｜ beg 任務指派 0
⇒ 是【沒有隊餓到會去乞食】，不是【接線沒生效】。
★而我沒有停在 1 天窗就下結論：BED_DAYS=6 實跑（547s）⇒ raw 仍然 0。
★★誠實限：6 天窗仍在 `opening_granary_food: 800` 的保護期內 ——
  這與昨天那條「閘被初始參數凍結」是同一個家族，只是這次凍住的是【觸發條件】不是【門檻】。
```

# ⑤ 回歸

```
failure_feedback_test        ALL PASS（含「失敗記憶入 fingerprint」那格）
headless-regression          PASS（失敗清單與 baseline 逐條相同 3=3）
failure-feedback-coverage    PASS（28｜有失敗反饋 3｜待接/不需要 25）
```

# ⑥ 要你裁的兩件

1. **外交／求和 de-patch**（拿掉硬 cooldown → 折價，TTL 借 `REJECT_COOLDOWN`）：要不要開票、排哪一批。
2. **桶要不要加第四格**：「已有等價、但形狀是憲法要溶掉的那種」——
   現在它們躺在【待接】裡，而照名單接會做出違反鐵律的東西。★**這是我這批停工的直接原因。**
