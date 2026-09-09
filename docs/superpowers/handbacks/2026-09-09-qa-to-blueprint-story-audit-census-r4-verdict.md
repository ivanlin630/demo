---
from: qa
to: blueprint
status: consumed
slice: 人口卷 90 天(r4)故事稽核
topic: ★故事性判決回覆——四題逐條判(❌1/⚠2/✅1)，兩題套上新判官清單(只印一邊/成對反事實)後降級為「這份卷答不了」
---

# 稽核範圍聲明（先講清楚能不能判）

`specimen_trace: null`（BED_SPECIMEN 本輪關閉，honest_limits 已聲明）。
我判的是 `docs/measurements/2026-09-09-population-census-90d-warring_states-r4.txt`（68978行 print log，非結構化 specimen trace）。
**這決定了判決的天花板**：能判「事件發生了嗎、鏈得起來嗎」，判不了「未印出的另一半分支」。以下逐題標。

---

## 題① Team24 職業土匪：在，且已擴散 ⚠

**trace**：`Team24 勒索 Team68` 首見 :1436，末見 :4441，跨 3000+ 行、全程只打 Team68/Team88 兩家。
**同型湧現**：同一 log 裡至少 **Team16/2/4/18/38/41/48/43/23/68** 也出現 `[Extort]` 反覆勒索同一目標的模式（如 Team48↔Team43 :4997-5340 連續互勒索）。

**判**：⚠ 非 ❌——archetype 沒消失，而是從「單一怪物」變成「普遍職業」。**但這個判決本身踩了新判官清單第一條，見下方降級**：

**★降級**：`interaction_system.gd:432-443` 三分支（accept/combat/noop-想搶未成）都在，**只有 accept 有 print（:488, print("[Faction]..." 附近, 實際勒索 accept 分支在別處）**。
全庫掃 `拒絕|反抗|打起來|想搶未成` 在此 log 命中 **1 次**（且是 `[Diplomacy]` 進貢拒絕，不是 `[Extort]` 分支）。
⇒ **3587 次 Extort print 全部是 accept 分支**，這不能讀成「零拒絕」——**分母（noop/combat 分支）從沒被印過**。
`_probe_raid`（04_qa.md 已指名）本輪未開 Probe dump，四格加總對不上。
**★這題正確結論＝「archetype 擴散了」（可判，因為這只需要「事件存在」不需要比例）；「拒絕率≈0」則不可判——這份卷答不了。**

---

## 題② 子隊鏈抽查：兩種鏈並存，各自完整 ✅ + ❌

### ✅ 健康鏈（分裂擴張的戰國）：`Team37 → Team49`
```
:40   [Sub] Team37 派出子隊 Team49 (擴建)
:41   [Infra] Team37 派擴建子隊 Team49 → (8,8) farming
:276  [Combat Start] Team-1000003 vs Team49（撐過野外遭遇）
:338  [Outpost] Team49 設施施工 farming → Lv1 at (8,8)（真的蓋出東西）
:620  [Order] Team49 buy weapon_melee_low ×1
:2312 [Merge] Team37 ← Team49 完全合併 (pop=10)
```
motive(擴建缺地)→action(派隊蓋Lv1據點)→outcome(帶著新資產合併回家，pop 3→10)，鏈完整。**擴建類 21 筆全庫掃，21 個不同 leader/parent 組合分散在 69 天全程**（:40~:58891），非批次複製。

### ❌ 病鏈（復讀機刷隊）：`Team38 + leader=P140` 反覆派運輸子隊
```
:20307 [Sub] Team38→Team169 leader=P140 task=運輸
:20615 [Sub] Team38→Team171 leader=P140 task=運輸 → :20616 送 food×1 → demand 市場(16,14)
       :20634 [Survival] Team171 urgent days_left=0.6 運輸→覓食（任務被生存立刻蓋台）
       :20858 [Merge] Team38←Team171 合併（沒有任何「送達」相關 print）
:20865 [Sub] Team38→Team173 leader=P140 task=運輸（同一人、同一路線，剛合併完立刻再派）
       :20891 同款 urgent days_left=0.6 運輸→覓食
       :21205 [Merge] Team38←Team173 合併
:21316 [Sub] Team38→Team177 leader=P140 task=運輸（第三次，仍同一人同路線）
       :21337 urgent days_left=0.6 運輸→紮營 …:23274 合併
```
同一 leader P140 在 :2400(擴建)/:20307/:20615/:20865/:21316/:24983(偵查) **六次被反覆派出**，其中三次運輸任務**在同一 tick 附近立刻被「days_left=0.6」的生存緊急蓋台**——61 次運輸派遣裡 **19 次(31%)** 命中一模一樣的 `days_left=0.6` 觸發字串（:17265/17870/20290/20327/20590/20634/20891/21337/21384/25077/25124/29665/29945/30137/30883/31680/32595/33398/45127）。

**★這個「0.6」固定值本身可疑**（同判官清單「完美比例」型恆真信號的親戚：19 次觸發值完全相同，像是出隊時食糧配額寫死，不是逐次算出的真實剩量）——**這題我只能提出來，判不了**，因為我讀不到 spawn 時的 food 配給算式，需 systems 查 `_dispatch_sub`/spawn 附近有沒有寫死初始 days_left。

**delivery 有沒有發生 = 這份卷答不了（新判官清單第二條命中）**：
`faction_ai_system.gd` 裡 Convoy 只有 2 個 print 點——`:5033` 派遣、`:3561` 「回不了母隊→轉獨立」。
**成功分支 `convoy.deliver`/`convoy.deliver_settled`（:3464/3479/3484）是 Probe 計數器，本輪 BED_SPECIMEN 關閉沒被印出來**——log 裡也沒有一次 `:3561` 打在 Team171/173/177 身上（它們都乾淨合併回家）。
⇒ **能確定**：這三隊「回家了」（合併成功，沒觸發 stranded 分支）。**不能確定**：途中有沒有真的送到市場——這是「只印一邊」的第二個活案例，不是「送達率≈0」，是「這一格沒開 Probe，答不了」。

**判**：❌ 這條鏈本身（同一人被連續三次派去做同一件被同一常數打斷的事，中間沒有任何「這次不一樣」的訊號）——**是復讀機形狀，不是戰國形狀**。但「有沒有真的白做工」判不了，只能判「派遣-被打斷-合併」這個殼子重複，殼子裡裝的內容不可知。

---

## 題③ 晉升 121 次死 not_enough_exp：這份卷答不了個案 ⚠→答不了

`anon_tier_system.gd:406-412`：`try_promote` 只有 `Probe.bump("promote.kill.not_enough_exp")`，**沒有 `bump_sample`**——log 裡對應行（如 :6033/:17997/:31056/:46143/:62298）全部是**跨全域的彙總數字**（`死在[not_enough_exp]=121`），**沒有任何一次帶 team_id/tier/實際 exp 值的逐筆記錄**。
機制本身讀起來是純函數式（`anon_exp[from_tier] < threshold(50/100/200) × count`），沒有看到「資深誤判」的旁路邏輯——**但這是讀 code 得出的推論，不是讀 trace 驗出的事實**（母體塌陷家族：不是「查了 121 筆都合理」，是「一筆都抽不出來查」）。

**判**：這題**降級**，不判 ❌/⚠/✅——**這份卷沒有個體樣本 tap，回答不了「有沒有可疑樣本」**。要答，需要 `try_promote` 加一個失敗時的 `bump_sample`（team_id, tier, exp, threshold）。

---

## 題★★（主稽核题）49→137、嬰兒僅 4：兩種故事並存，不是單一答案

**帳面**：223 次 `[Sub]` 派遣，170 次 `[Merge]` 合併回家 ⇒ **53 隊淨留下獨立**（加上生育 3-4 隊 ≈ 對不齊 137-49=88，中間差額落在「轉獨立隊」等本卷未逐項算的路徑，屬本卷 scope 外，不在這裡硬湊）。
- 擴建類（21 筆）：**分散在 69 天全程、21 個不同 parent-leader 組合**，抽樣看到蓋出真資產（Team49 Lv1 farming 據點）——**這部分是「分裂擴張的戰國」，站得住**。
- 運輸類（61 筆）：至少一條 6 次連派同一人的鏈（P140）+ 19/61(31%) 命中同一固定 `days_left=0.6` 中斷——**這部分带「復讀機」形狀，且送達與否本卷答不了**。

**★給藍圖的結論**：這題**不能只回一句話**——「隊數 49→137」這個彙總數字底下混了至少兩種不同因果鏈（真擴張 vs 派遣被固定常數打斷後空手合併），**任一種單獨拿出來都會誤導**。若要下一輪繼續追，優先度：①開 Probe/bump_sample 補「convoy 送達」與「promote 逐筆」兩個母體塌陷格；②查 spawn 時 days_left 是不是寫死常數。

---

## 摘要表

| 反例 | 判 | 卡在哪環 |
|---|---|---|
| Team24 archetype 還在/擴散 | ⚠ 可判(存在性)，比例題降級 | 只印 accept 分支 |
| Team37→Team49 擴建鏈 | ✅ | 無斷點，motive→action→outcome 完整 |
| Team38+P140 運輸鏈 | ❌ 殼子重複 / 送達本身答不了 | 固定 days_left 常數疑點 + convoy.deliver 未開 Probe |
| 晉升 121 死 not_enough_exp 個案 | 答不了 | 母體塌陷(無 bump_sample) |
| 49→137 主因 | 拆成兩股答，不給單一裁定 | 見上 |

不修 code、不裁 WHAT。兩懸案（0.6 常數是否寫死／convoy 是否真送達）需 systems 查或 measurer 補 Probe，WHAT 終審在用戶（你正呈報）。
