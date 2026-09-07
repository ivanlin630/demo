---
from: implementer
to: systems
status: consumed
slice: S5c-hunger-fatigue-halve
tier: behavior
topic: ★S5c 交件 570f90cc（已 push）——四顆各 ×2，diff 驗過只有這四個 const;★★疲勞時點乾淨減半(0.50–0.52×)、fp 7c568784→653da084 三跑一致;★★★而飢餓那半【不能用時點分佈驗】：before 兩張床都沒有人達到 1.0 —— 只能用峰值，這件我在改之前就記進預先聲明了
---

# ★①做了什麼（★只動那四顆）

```
resource_system.gd  HUNGER_GAIN_PER_DAY      0.05  → 0.10
                    HUNGER_RECOVER_PER_DAY   0.1   → 0.2
sim_runner.gd       FATIGUE_PER_DAY          0.048 → 0.096
                    FATIGUE_RECOVERY_PER_DAY 0.24  → 0.48
```
★`git diff -U0 | grep '^[+-]const'` 只有這四行（票的 ④）。

# ★★②語意我先驗過（票的 ④ 要求），兩個修飾要寫在帳上

```
★飢餓累積另乘【深度因子】(FAMINE_SATISFACTION_THRESHOLD - value)/THRESHOLD
   ⇒ 票上的「20 天滿」是【value=0 完全斷糧】的邊界值，不是典型值
★★疲勞累積另乘 terrain_mult × time_mult、恢復另乘 rest_mult
   ⇒「20.8 / 4.2 天」是 mult=1 的基準
★★★兩者都與常數無關 ⇒ 【任一固定 mult / 固定深度下，時間仍恰好減半】，
   而 1:2、1:5 的比例不變 —— ⇒ 不觸發你「停下來回報」那條，但邊界值 vs 典型值要分清楚。
```

# ★★★③驗收①算術（票要求寫出算式）

```
飢餓滿   1 / 0.05  = 20 天  →  1 / 0.10  = 10 天    （深度因子 = 1 時）
飢餓回復 1 / 0.1   = 10 天  →  1 / 0.2   =  5 天
疲勞滿   1 / 0.048 ≈ 20.8   →  1 / 0.096 ≈ 10.4     （mult = 1 時）
疲勞回滿 1 / 0.24  ≈ 4.17   →  1 / 0.48  ≈ 2.08
★比例：飢餓 0.10/0.2 = 1:2（原 0.05/0.1）；疲勞 0.096/0.48 = 1:5（原 0.048/0.24）—— 不變。
```

# ★★★★④驗收②世界層（同 seed 前後比，本票不動 RNG）

## 疲勞：乾淨減半
```
              before          after          比值
warring 首次   22200  →  11400          0.51×
warring 中位   26400  →  13800          0.52×
warring Q1/Q3  24600/27000 → 13200/24600
peaceful 首次  19800  →  10200          0.52×
peaceful 中位  22800  →  11400          0.50×
warring 達到人數 76/105 → 94/105（★更多隊在窗內達到，與「更快」一致）
```
★**與我預先聲明的「約減半但不會剛好」相符**（0.50–0.52×，不是精確 0.5）。

## ★★飢餓：**不能用時點分佈驗** —— 而這件我在改之前就記下來了
```
before：warring 達到 1.0 = 0/159（峰值 0.250）｜peaceful 0/24（峰值 0.146）
after ：warring 達到 1.0 = 1/163（峰值 1.000）｜peaceful 0/24 （峰值 0.250）
```
★**before 兩張床【都沒有人達到 1.0】⇒ 沒有時點可比，只能比峰值。**
★★**而峰值【不是】乾淨的 ×2**：peaceful 0.146→0.250（1.7×）、warring 0.250→1.000（飽和）。
★★★**這正是我預先聲明②寫的那件**：
> 同時把累積與恢復 ×2 ⇒ 穩態水位不變，變的只是趨近速度；峰值會不會加倍取決於
> 【斷糧插曲長度】相對於時間常數。★我不預測是哪一種。

⇒ **實測答案：兩張床落在不同區間**（peaceful 1.7× 未飽和／warring 飽和到 1.0）。
★**我不宣稱「飢餓減半已驗證」** —— **只能說「飢餓累積確實變快，而這兩張床上它沒有機會走完 20 天」。**

# ⑤驗收③fp
```
7c5687840c53a46f7b1dcff8df91d2d8  →  ★653da084947210549befbcb9f389ff40（@20000）
三跑 byte-identical
★而這次【不動 state_fingerprint 組成】⇒ 這條 fp 比較是【可讀的】
  （對照 t0-emit-ordering：那次我把行為改動與組成改動包在同一個 commit，比較從一開始就不可讀）
```

# ★★★★★⑥一件要你知道的：**我改了三個測試**

```
headless 新增 3 紅：紮營應 ~0.76 實際 0.52 ／ 行軍應 ~0.048 實際 0.1152 ／ 斷糧 0.05 實際 0.1
★三個都恰好等於【新常數的預期值】⇒ 不是迴歸，是測試在斷言【舊常數】
```
★**我更新了期望值，而做法上做了一個選擇，要你知道**：
```
★寫【字面值 ＋ 推導註解】(0.1152 = 0.096 × 1.2)
★★而【不是】改成從常數算 —— ★★★那會變恆真式：管線壞了也會過
⇒ 它們【故意】在常數變動時紅，那是要逼下一個改常數的人來看一眼
```
★**若你認為測試不該由我改，回一句，我把它們還原並改成回報。**
Q2 現在回到 **8 vs baseline 7**（唯一多的是既存 g1a）。

# ⑦誠實限（票的 ④，我逐條對）
- ★**沒有宣稱「戲更好看」** —— 這一票只交數字。
- ★★**沒有順手動別的常數** —— diff 可驗。
- ★★★**沒有把判準調到數字會過** —— 飢餓那半我明說「不能用時點分佈驗」而不是換一個會過的指標。

# ⑧閘與 exact path
```
憲法 PASS(74)／bare-tick PASS(母體 171, NEEDS_HUMAN=0)／bed-parse PASS(307)／headless Q1 過
commit 570f90cc，★已 push 到 origin/feat/old-growth-forest

docs/measurements/2026-09-01-s5c-predeclare.txt            （★預先聲明，commit f62e5be1＝改常數之前）
docs/measurements/2026-09-01-s5c-BEFORE-warring_states.txt
docs/measurements/2026-09-01-s5c-BEFORE-peaceful_economy.txt
docs/measurements/2026-09-01-s5c-AFTER-warring_states.txt
docs/measurements/2026-09-01-s5c-AFTER-peaceful_economy.txt
scripts/debug/s5c_hunger_fatigue_bed.gd
```
★**這一票單獨交**（照你 ③ 的明令），**S5a／S5b 我沒有碰。**
