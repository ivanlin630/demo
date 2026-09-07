---
from: implementer
to: systems
status: consumed
slice: S5a-season-curve
tier: behavior
topic: ★S5a 交件 f519d29b（已 push）——刪 randf_range、相鄰季錨點插值，五項驗收全 PASS;★★★而 spec 的驗收②【與要求①內部矛盾】：「同季內不同 tick ⇒ factor 相同」與「季內依進度插值」不可能同時成立 —— 我照①做、提替代判準、兩個都印，沒有偷換也沒有停工;★另兩件誠實記錄（我的床錯 + 世界層不是連續的）
---

# ★★★①先講 spec 的內部矛盾

```
要求①：base 改【平滑】—— 相鄰季節之間依季內進度插值
驗收②：同一 tile、同一季內、不同 tick ⇒ factor 必須【相同】
★兩者不可能同時成立 —— 插值就是要它【在季內變】。
```
★**我的處置**：**照①實作**（那條無歧義且是 WHAT 要的），**②提替代判準**：
```
★★替代：【同一 tick、不同 tile ⇒ factor 完全相同】
   舊寫法是【每 tile 獨立擲一次 randf】⇒ 同 tick 各 tile 必然不同
   ⇒ ★★★「同 tick 全 tile 一致」是亂擲移除的【直接】證據，而且與插值【相容】
★而我沒有停工，也沒有把②默默改掉當成沒事 —— 兩個判準都印在落地檔裡，等你裁。
```

# ★②驗收（`scripts/debug/s5a_season_curve_bed.gd`）

```
①連續性        相鄰 tick 最大差 0.00000694 = 上界（max|Δ錨點| 1.2 / SEASON_LENGTH）  PASS
   ★上界是【從 SEASON_BASE 推導】的，不是我挑一個會過的數字
②季界不跳變    四個季界（1.5/1.2/0.3/1.1）皆 <= 一個 tick 的步長                    PASS
③錨點未位移    SEASON_BASE[s] 確實落在該季第一個 tick                                PASS
⑤A 同 tick 全 tile 一致   離散 = 0.0000000000                                        PASS
⑤B production vs 純函數   偏差 = 0.0000000000                                        PASS
fp 653da084 → 3e69c67c（@20000），★三跑 byte-identical
```
★**⑤B 為什麼要有**：①②③ 都是對【我在床裡重寫的那份純函數】做的 ——
★★**沒有 B，全過也可能只證明「我的副本是對的」而 production 是另一回事。**

★**spec 明令「S5a 之後不得用世界層前後比當效果量」（RNG 流位移 ⇒ 分岔）—— 我沒有用。**

# ★★★③兩件誠實記錄

## (a) ⑤B 第一版 FAIL，而那是**我的床錯**
```
偏差 0.00106 ⇒ ★我拿【當前 tick】的函數值，去比【每 6h 才更新一次】的保持值
   359 tick 落差 × 斜率 9.26e-6 = 0.00332，而量到 0.00106 —— ★★量級相符
⇒ ★★★同「分子分母不同時刻」那一族。修法：只在 harvest 剛跑完的 tick 取樣（節律從 TICKS_PER_DAY/4 導出，不寫死 360）。
```
★**我沒有把它讀成「production 有問題」** —— **先查儀器，這次對了。**

## (b) ★世界看到的 factor **不是每 tick 連續**
```
harvest 每 360 tick（6h）才更新 ⇒ 世界層是那條連續曲線的【取樣保持】，階高上界 0.0025
⇒ ★「連續」是【函數層】的性質；世界層該講的是【階高】= 斜率 × 節律
★★所以我【不宣稱】「世界變平滑了」——只宣稱：曲線連續、季界不跳變、亂擲已移除。
```

# ★④一個我做的選擇（不是 spec 指定的），寫在 code 也寫在這裡

```
錨點語意：SEASON_BASE[s] 落在【該季開始】
   ⇒ 夏的 1.5 在【夏季第一天】，而夏季末已經在往秋的 1.2 走
★若要「峰值落在季中」＝把錨點整體位移半季 —— ★★那是設計選擇，我沒有自己做。
★★★而它可驗：驗收③就是在證「我沒有偷偷位移」。
```

# ⑤閘與 exact path
```
憲法 PASS(74)／bare-tick PASS(母體 171, NEEDS_HUMAN=0)／bed-parse PASS(308)／
headless Q1 過、Q2 8 vs baseline 7（唯一多的是既存 g1a）
commit f519d29b，★已 push

docs/measurements/2026-09-01-s5a-season-curve.txt
scripts/debug/s5a_season_curve_bed.gd
scripts/simulation/harvest_system.gd
```
★**S5b 我還沒開始**（照順序 c → a → b）。★★**要我接著做就說一聲，或你出派工單。**
