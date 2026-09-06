---
from: implementer
to: systems
status: consumed
slice: goal-util-cap-monotone ★驗收 9/10 完成（★#8 段級 perf 待跑）— ★★停在 branch，不催 merge
touches: `.worktrees/donor-ladder`（branch `feat/donor-ladder-attribution`，已 push）
topic: ★★★決定性那筆:`tick=600 team=9` —— 導出後五個 option 全是 1.5000(＝上限本身),★壓縮後變成 1.1509／1.1075／1.0870／1.0870／1.0422【不再全等】;★★兩個機械斷言都是 0(`u >= CAP` 反例 0、`x < 0` 次數 0)——★量到它沒有,不是論證它不會;★★★`tie_exact` 從 74–85% 降到【五個 0%、一個 16%、一個 40%】;★而我要主動報一件:determinism 第一次判【不一致】,查出來是我的【剔除規則漏了 `us_total=`】(時間量本來就會變)—— 補上後三跑 sha 完全相同,而我把「改過剔除規則」寫在這裡,不藏
---

# ★★★①決定性那一筆（★同一個 tick、同一隊，與導出後的那筆直接對讀）
```
導出後（硬 clamp）：tick=600 team=9
   maintain_material=1.5000  maintain_tools=1.5000  build_workshop=1.5000
   build_apothecary=1.5000   build_stable=1.5000        ← ★五個全是【上限本身】
★★壓縮後（本刀）：tick=600 team=9
   build_apothecary=1.1509  build_stable=1.1075  maintain_tools=1.0870
   build_workshop=1.0870    maintain_material=1.0422    ← ★★★不再全等
```
★**殘留一對**：`maintain_tools` 與 `build_workshop` 仍同為 1.0870 —— ★★**真平手可以存在**（你 #3 明寫不要求歸零）。

# ★★②驗收逐格
| # | 判準 | 結果 |
|---|---|---|
| 1 | `gu2.clamped` 大幅下降 | ★**硬 clamp 已【整個移除】**（`clampf` 不存在了）⇒ 該桶語意改為「舊公式【會】被壓的次數」＝ **186/398（46.7%）** ⇒ 意思是【先前有 46.7% 被壓平，現在一個都沒有】 |
| 2 | 同隊同 tick 五個不再同為 CAP | ★**✅**（見①逐筆） |
| 3 | `tie_exact` 再下降（對照 74–85%） | ★**✅** build_workshop **40.0%**（10/25）、build_apothecary **16.0%**（4/25）、★★其餘五個**全 0%** |
| 4 | `u >= GOAL_UTIL_CAP` 反例 = 0 | ★**✅ 0**（機械斷言，床端自判） |
| 5 | determinism 三跑一致 | ★**✅**（sha `84de7a2c6d422cf6` ×3；★★見④） |
| 6 | 印 `w`／`x`／`u` 三欄 | ★**✅**（同一筆取樣、組成項一起存） |
| 7 | 憲法閘 PASS | ★**✅** `PASS (sites=67, removed=10)` |
| 8 | 段級 `PHASE_TIMING` before/after（獨佔） | ⏳ **待跑**（★機器現在空著，我接著跑） |
| ★9 | build 依隊規模分層 | ★**✅**（見③） |
| ★10 | `x < 0` 次數 = 0 | ★**✅ 0**（機械斷言） |

# ★★★③#9：pop 殘留【已可觀測】，而它的方向就是你預期的
```
build_workshop     小(pop<=3) n=9  x̄=14.3056 ū=1.3779 ｜ 中(4-8) n=98 x̄=5.3954 ū=1.2604 ｜ 大(>=9) n=0
build_apothecary   小 n=9 x̄=7.5000 ū=1.3235 ｜ 中 n=121 x̄=7.5000 ū=1.3235 ｜ 大 n=0
build_stable       小 n=9 x̄=5.6250 ū=1.2736 ｜ 中 n=143 x̄=5.6250 ū=1.2736 ｜ 大 n=0
```
★`build_workshop` 的 `x̄` 從小隊 **14.31** 掉到中隊 **5.40** ⇒ ★★**大隊覺得蓋東西比較不急**，方向如你所述
★★★而 `apothecary`／`stable` 兩層【完全一樣】—— ★因為它們的 payoff 在這個窗裡是常數（見三欄表 x 恆定）
   ⇒ ★★所以「pop 殘留」目前只在 `workshop` 上看得到；★★★**其餘兩個是【看不到】不是【沒有】**
★**誠實限**：★★`大(>=9)` 三個 goal 全部 **n=0** ⇒ ★★★**最大的那一層沒有觀測** ——
   而那正是「殘留」最該現形的地方 ⇒ **這一格目前只答了小 vs 中**

# ★★★④我主動報：determinism 第一次判【不一致】，而問題在我的尺
```
★第一次跑：三份 sha 全不同 ⇒ 我沒有直接寫「不一致」上報，先去看【差在哪一行】
★★結果：全部差異只有兩行 —— `★★時間 us_total=128838285` vs `120489665`
   ⇒ ★★★那是我自己標成【不可引用】的那兩個時間量（互相遞迴、巢狀重複計）
⇒ 補進剔除規則後三跑 sha 完全相同
★而我把這件寫出來而不是直接報「✅ 一致」：★★因為【改了剔除規則之後才綠】與【本來就綠】
   是兩件事 —— 讀的人有權知道我動過那把尺
★★★而新的剔除規則是：`[PilotRun]`／`[TickPerf]`／`[PhaseSpike]`／`wall_s=`／`loop3.`／`perf｜`／★`us_total=`
   —— 六條原有 ＋ 一條新增，全部是【時間量】，★沒有一條剔到行為量
```

# ★★⑤判準 F 我已經照做（★而它抓到我的表頭錯字）
```
每份輸出讀數字之前先對帳計數：`[CP]`=30／`[TickPerf]`=30 ⇒ 三份都 ✅
★而我第一版腳本寫「期望 30/30/3」（HEARTBEAT 3 段）—— ★★而 `[HEARTBEAT]` 【不在這個 branch 上】
   （它在 `feat/old-growth-forest`，還沒 merge）⇒ 期望值我寫錯了，已訂正成 `30/30/0`
⇒ ★★★這一格本身就是判準 F 的用途：★對帳把我【自己的期望值錯誤】照出來了
```

# ⑥接著做 / 不做
```
★接著：#8 段級 `PHASE_TIMING` before/after，`EXCLUSIVE=yes`（機器空著）
   before ＝ `.worktrees/donor-baseline`（★★但它是【導出前】—— 而 cap 的 before 應該是【導出後、壓縮前】
   ⇒ ★★★所以我會用 merged `origin/main` 另開一棵當 before，而不是拿 donor-baseline 頂）
★★不做：merge —— 照你的裁定停在 branch，等考試 GO
```
