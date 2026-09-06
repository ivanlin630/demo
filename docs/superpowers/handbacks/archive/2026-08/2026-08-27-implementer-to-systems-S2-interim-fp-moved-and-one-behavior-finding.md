---
from: implementer
to: systems
status: consumed
slice: S2-root-reanchor
tier: behavior
topic: ★中途報(after 30 日窗還在跑,不等它是因為有一件你現在就會想知道的);★fp 兩床都變了=根旋鈕真生效;★★headless 修掉 7 題【全是測試把舊根 tick 凍死】非行為變;★★★剩 1 題 g1a 是【真的行為差異】:料 200→7 進了農田3級,鑄幣坊買不起——而那是 behavior 因果,我不自判,會附 specimen 送 QA;★★★★裸 tick 守衛 FAIL 2 筆(新根常數待判),我等 after 跑完再動工作樹
---

# ★①`fp` 兩床都變了 —— **照你說的，這票「沒變才是警訊」**
```
warring   06580e7f\u2026 \u2192 4f1c0eda a9cdeecb9b07beeea3503717
peaceful  533ebf68\u2026 \u2192 c5ef5b06 320f9f432071fdc2ee358c67
```
★**根旋鈕真的生效了。** ★★**新基線我會在完整回報裡正式落檔。**

`time_const_check` PASS：**動作 10 tick ＝ 10 分鐘｜世界格移動 ＝ 4 小時｜徵收 ＝ 24 小時**。
憲法閘 PASS。

# ★★②headless：修掉 7 題，**而 7 題全是同一個病**
★**沒有一題是行為變了 —— 全是【測試把舊根的 tick 數字凍死】：**
```
state.ticks_per_day == 240        \u2192 == WorldState.TICKS_PER_DAY\uff08\u9a57\u3010\u6b04\u4f4d\u63a5\u4e0d\u63a5\u6839\u3011\uff09
eta == 240                        \u2192 == 5 * TimeScale.MOVE_TICKS_PER_HEX
threat cadence == 240 / 480       \u2192 == THREAT_CADENCE / 2\u00d7THREAT_CADENCE\uff08\u9023 current_tick \u4e00\u8d77\u6539\uff09
_step6d_fatigue(state, [0], 10) \u00d72  \u2192 SimRunner.NEAR_CADENCE\uff08\u2605 10 \u662f\u820a\u6839\u7684 1 \u5c0f\u6642\uff0c\u5beb\u6b7b\u5728\u6e2c\u8a66\u88e1\uff09
resolve_consumption(state, [0], 10)  \u2192 \u540c\u4e0a
\u665d\u591c tick 25 / 220             \u2192 int(TICKS_PER_DAY * 0.104 / 0.917)\uff08\u2605\u665d\u591c\u662f\u3010\u6bd4\u4f8b\u3011\u4e0d\u662f\u3010\u7b2c\u5e7e\u500b tick\u3011\uff09
g1a range(6000) \u8a3b\u300c\u7d04 25 \u5929\u300d   \u2192 range(25 * TICKS_PER_DAY)\uff08\u2605\u91cd\u9328\u5f8c 6000 \u53ea\u5269 4.2 \u5929\uff09
```
★★**跟 `time_const_check` 是同一個形狀** —— **凍的是【當時的實作】不是【意圖】。**
⇒ **改成對具名常數／比例／遊戲日斷言後，下次重錨【這幾題一行都不用改】。**

## ★而 `Q1` 一度是 NO —— **那件事本身值得記**
**`[TEST-SUITE-COMPLETE]` 印在 `_run_sim_test()` 尾端，而它被中途的 assert 攔停** ⇒ **標記消失。**
★**所以「Q1 NO」不只是「沒跑完」，它還會【蓋掉 Q2 的可讀性】** —— **修完那批 assert 後 Q1 自動回 YES。**

# ★★★③剩 1 題 `g1a` 是【真的行為差異】—— ★而我不自判
**我把失敗訊息改成會講「卡在哪一站」的形狀（沒料／沒決定建／建到一半是三件不同的事），拿到機制：**
```
mint_level=0  vault_ore=24  \u65bd\u5de5\u968a=-1  \u958b\u5de5tick=-1  \u968a\u6599=7  \u5de5\u5177=20
\u8a2d\u65bd={ outpost_L:1, farming:3, workshop:0, mint:0, \u2026 }
```
★**料 200 → 7，進了【農田 3 級】** ⇒ **鑄幣坊（需 100 料）買不起** ⇒ 鏈末端不通。
★★**我排除掉的假說**：「根 ×6 讓建設多 6 倍機會動工」——
**`_evaluate_infrastructure` 由 `INFRA_INTERVAL = 50 * TICKS_PER_HOUR` 閘住、隨根縮放 ⇒ 每遊戲日評估次數不變。**
★★★**剩下指向的是 intended 的「徵收 30h → 24h」讓料變多** ——
**但那是 behavior 因果結論，★不歸我自判**，會附 specimen 送 QA。
⇒ ★**我不會把這題硬弄綠。** **headless 現況：baseline 7 ／ 實測 8。**

# ★★★★④裸 tick 守衛 FAIL 2 筆（★預期內，但我還沒動）
```
world_state.gd:9        const TICKS_PER_HOUR = 60          \u2190 \u65b0\u7684\u6839\u5e38\u6578\u672c\u8eab
encounter_system.gd:17  WorldState.TICKS_PER_HOUR / 6      \u2190 \u906d\u9047\u52d5\u4f5c\uff1d10 \u5206\u9418\uff1d1/6 \u5c0f\u6642
```
★**兩顆都該進 (c) 白名單**（前者是根本身、後者是單位結構），**理由會寫進 code 註記＋規則表。**
★★**而我現在【不動工作樹】** —— **after 的 30 日窗正在跑，那正是我自己警告 measurer 的活工作樹風險。**

# ⑤還在跑 / 還沒做
```
\u2605after \u4e24\u5e8a 30 \u65e5\u7a97\uff08\u80cc\u666f\uff09\u21d2 \u56de\u4f86\u624d\u80fd\u505a\u7d71\u8a08\u7b49\u50f9\u5c0d\u6bd4
\u2605\u2605\u5c0d\u6bd4\u6703\u7167\u4f60\u7684\u88c1\u5b9a\uff1a\u4e0d\u8b8a\u9805\u7528 taken\uff0ccredited \u8207\u6bd4\u503c\u5f53\u9644\u8a3b\u4e0d\u5217\u5165 <5% \u88c1\u6c7a
specimen trace \u9001 QA\uff08\u4e16\u754c\u7bc0\u594f\u6539\u8b8a\u5f8c\u6545\u4e8b\u4ecd\u8aaa\u5f97\u901a\uff0b g1a \u90a3\u4e00\u984c\uff09
```

## 落地 exact path（★S2 仍未 commit，全在工作樹）
```
A:\GDS\demo\.worktrees\old-growth\scripts\data\world_state.gd
A:\GDS\demo\.worktrees\old-growth\scripts\simulation\time_scale.gd
A:\GDS\demo\.worktrees\old-growth\scripts\simulation\encounter_system.gd
A:\GDS\demo\.worktrees\old-growth\scripts\ui\sim_bridge.gd
A:\GDS\demo\.worktrees\old-growth\scripts\ui\turn_controls.gd
A:\GDS\demo\.worktrees\old-growth\scripts\simulation\faction_ai_system.gd
A:\GDS\demo\.worktrees\old-growth\scripts\debug\time_const_check.gd
A:\GDS\demo\.worktrees\old-growth\scripts\debug\headless_test.gd
```
