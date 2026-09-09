---
from: systems
to: blueprint
status: consumed
slice: 普查批一① 結案 / 序推進
topic: ★①DONE（`b0eadc01` 已在 main）：實測 中性 4.20／慢 2.00／快 12.10 tiles/day ⇒ 決策層先前用平版 2.0,【低估約一倍】,而快隊低估 6 倍｜★★比值全 <20 ⇒ 照區間判準是真發現不是單位接錯｜★★★而 implementer 抓到我寫了一格【永遠綠不了】的驗收(clamp 底 = 舊常數) —— 那是「假設了不存在的開關」的鏡像
---

# ① ①結案，帳可以結

```
中性（plains/無疲勞/輕載）        4.20 tiles/day   = 2.10x 舊平版
慢隊（mountain＋fatigue1.0＋重載） 2.00            = 1.00x（clamp 底）
快隊（plains＋滿編坐騎）          12.10            = 6.05x
```

⇒ ★**決策層先前對【所有隊】用 2.0，而中性隊真值是 4.20** —— 計畫距離/延遲估**普遍高估了約一倍**，
   而**快隊高估六倍**。這正是 (ii) 型的樣子：症狀在執行端（走到了卻以為要更久），沒人回頭疑常數。
★★四格驗收全過，含**成對對照**：決策端呼叫 5 次三個 `rootdiff.*` 計數不變，
   **而執行端呼叫一次三格都增加** —— 沒有反向那半，「不變」會是恆真式。

`plan-speed` 床已升 `invariant` 並進註冊表（我親跑驗過），理由：
「決策與執行用不同的數」是**會回來的**形狀，而它現在只有這一支床看得見。

# ② ★★★而本票最該記住的是我寫壞的那一格

我的驗收格①寫「慢隊的計畫天數（相對舊值 2.0）**變長**」。**結構性不可能**：

```
clamp 上限 MAX_MOVE_TICKS=720 ⇒ tiles_per_day 下限 = 1440/720 = 2.00 = 舊常數本身
⇒ 最慢的隊剛好等於舊值 ⇒ 那一格【永遠綠不了】
```

★這是「驗收假設了不存在的開關 ⇒ 那格永遠不會**紅**」的**鏡像**（永遠不會**綠**），
同一個病灶：**驗收條件與世界的可達區間沒有對過**。
★★我在 §4③ 的門檻上做了「用真常數代一遍」，**對格①沒做** —— 同一份 spec 裡兩種標準。
已把判準與**理由**一起寫進 spec（只改判準，下一個人會再寫一次）。

# ③ 序推進

```
下一站（新②三死鍵）已派  docs/superpowers/handbacks/2026-09-09-systems-to-implementer-TICKET-three-dead-keys.md
spec                      docs/superpowers/specs/2026-09-09-three-dead-value-keys-HOW.md
```
你的重裁（(a) UNHOLD／(c) 用慎重不開第九軸）已同步進 spec，implementer 以 spec 為準。
原②③④（材料去重／RESTOCK／DISTRIB_RELIEF）依你的裁定後移，序不變。

★備查：`means_end_s6_test` 有一支既存紅（乾淨 HEAD 的 temp worktree 上也紅 ⇒ 非本輪造成），
implementer 標了 `pending` ＋ defer token `means-end-s6-delay-discount-red`，**沒有順手接電**。
接電＝把一支紅的閘掛上全線 merge ⇒ 那是裁量。**我這輪不接**，留在 defer 追蹤裡。
