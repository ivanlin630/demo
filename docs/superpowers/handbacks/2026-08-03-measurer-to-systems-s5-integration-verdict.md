---
from: measurer
to: systems
status: consumed
topic: "[§5一次合量verdict:★★沙盤『部分』活——④勞力池need-driven+⑥全貌世界動態確認活;但①甲distribute兩seed皆完全0 fire(dispatch/deliver/food_delivered全0)+⑤economy全世界trade.deal=0/convoy.dispatch=0/order_fulfilled=0(order_placed 426-476)+③de-patch facility兩seed皆manufacture.fired=0(0/15飽和度)全部誠實回報非paper over。最刺眼:領主T_LORD food穩定3280-3323餘糧看得見，同faction resident T_RESIDENT兩seed皆瀕死(pop10→2,food 2.0-7.3,runway 1.25-4.58天,unrest_add 451-623次持續斷糧從未relieved)——條件教科書等級(真surplus+真deficit+同faction+resident重複掛buy food單g1.food_buy14-18次)卻領主分配政策一次沒fire過。code讀掌握到一個結構觀察(非斷因果):received_buy_orders讀team_known的order_buy訊息(order_system.gd:164-174),非同faction直接全知——post_order有emit_message傳播(order_system.gd:30-34)，但傳播是否曾抵達領主team_known未直接驗證，可能是候選從未生成(訊息未達)或候選生成但argmax輸給其他選項，兩者我都沒法區分只能如實報『0次』。②組織軸ratio 0.498/0.505(兩seed一致)——與§8乾淨fixture既有健康基準(0.845-1.221)方向不同，但本輪confound重(T2/T3多次subteam分裂合併churn+seed42 T3瀕臨famine死亡)，誠實揭露非直接視為機制退化。determinism 3跑byte-identical，2seed皆不凍(60天完工，無hang，惟world層級商業活動完全靜止)。1行gather tap已清除確認clean，新fixture(config/s5_integration.json)+bed(scripts/debug/s5_integration_bed.gd)已刪除。落地docs/measurements/2026-08-03-s5-integration-seed{1337-run1,run2,run3,42}.txt(4檔4206行已ls/wc驗證)。"
---

# §5 一次合量整合驗 → systems（★★沙盤「部分」活——labor pool/世界動態活，distribute/economy/facility 這輪皆 0）

工單：`2026-08-03-systems-to-measurer-s5-integration.md`（已消費）。main `2c25a82c`+後續。**新建**（非複用 §8/peaceful_economy 舊 fixture，兩者皆不符「真 faction 領主+resident」條件——peaceful_economy.json 全隊 faction_id=-1，會讓 distribute 結構性=0 誤判）：`config/s5_integration.json`（8 隊，1 faction：T_LORD 領主+T_RESIDENT 同 faction resident + T_COOP_A/B 共址組織軸 pair + T_SOLO_BIG baseline + 3×小隊）+ 新 bed `scripts/debug/s5_integration_bed.gd` + 1 行 `LABORTEST.gather.*` temp tap（僅 1 個新 tap，其餘全用既有 native Probe：`distribute.*`/`manufacture.*`/`convoy.*`/`trade.*`/`g1.*`）。

## ★★核心答案：沙盤「部分」活——labor pool + 世界動態真動，但 distribute/economy/facility 三線這輪皆 0

| 維度 | 結果 | 判讀 |
|---|---|---|
| ④ 勞力池 need-driven | **活**：T_SMALL_0(pop5) `gather:food fill=0.18` vs `gather:material fill=0.82`（人手不足全線比例分配）；T_LORD/T_SOLO_BIG(pop14-26) 兩線皆 `fill=1.00`（人手多飽和）| 需求驅動分配機制正確運作，人手少/多對比清楚 |
| ⑥ 全貌 | **活**：teams 7-10 隊、總人口 88-89、faction=1，subteam 分裂/合併/famine 死亡真實發生（非凍結）| 世界在真的演變 |
| ① 甲 distribute | **兩 seed 皆完全 0**：`dispatch=0 deliver=0 food_delivered=0.0` | ★★見下 |
| ③ de-patch facility 真跑 | **兩 seed 皆 0**：`manufacture.fired=0`，全隊飽和度 0/15 | 與 mfg-depatch 輪 seed1337/42 的「未完工」結果一致（非新現象） |
| ⑤ economy flow | **世界級靜止**：`trade.deal=0 convoy.dispatch=0 g1.order_fulfilled=0`（`order_placed=426-476`）| 全世界 60 天零成交 |
| ② 組織軸集團生產 | ratio 0.498（1337）/0.505（42）| confound 重，見下，不當乾淨反例 |

## ★★①最刺眼發現：領主有真餘糧、resident 真瀕死，distribute 一次沒 fire
`T_LORD` food 穩定 3280-3323（60 天幾乎沒動用，明顯的真餘糧）；同 faction 的 `T_RESIDENT` 兩 seed 皆瀕死：
- seed1337：pop **10→2**，food=7.3，runway=4.58 天
- seed42：pop **10→2**，food=2.0，runway=**1.25 天**（幾乎斷糧）

`unrest_add` 兩 seed 分別 451/623 次（幾乎每個 cadence 都在累積民怨，`unrest_reduce=0`——**從未被賑濟過**）。`T_RESIDENT` 本身也確實重複掛出 `buy food` 單（`g1.food_buy=14`/`18` 次，log 可見 `[Order] Team1 buy food ×26` 等）。**條件教科書等級：真 surplus + 真 deficit + 同 faction + resident 主動求助——但領主分配政策整輪 0 次 fire。**

我讀 code 找到一個結構性觀察（**不代下因果判定**）：`FactionAISystem._distribute_candidates`（`goal_resolver.gd:126-201`）掃的 `buy_orders` 來自 `OrderSystem.received_buy_orders()`（`order_system.gd:164-174`）——這讀的是 `state.team_known[team.team_id]` 裡的 `order_buy` **訊息**，不是「同 faction 直接全知」。`post_order()` 確實有 `emit_message()` 傳播副本（`order_system.gd:30-34`），但**這條訊息是否真的傳到了 T_LORD 的 `team_known`，我沒有直接 tap 驗證**——可能是（a）訊息從未抵達（distribute candidate 從未被生成）、也可能是（b）candidate 生成了但在 `DecisionEngine` 的 argmax 競爭中輸給別的選項（T_LORD 全程 `task=覓食`，從未見過它做 distribute 相關的 convoy 派遣）。這兩種可能我分不出來，只能如實回報「0 次」+ 這條可疑的 file:line，判斷屬於你。

## ⑤ economy flow：不只 distribute，整個世界的商業都是死的
`trade.deal=0`、`convoy.dispatch=0`、`convoy.fetch=0`、`convoy.deliver=0`、`g1.order_fulfilled=0`——**兩個 seed、60 天、8-10 隊、400+ 張掛單，沒有一筆成交**。這不是新東西：這條「`order_placed` 量大但 `order_fulfilled=0`」的模式，跟本 session 更早的和平經濟床調查（`Q3 order_placed=1833/fulfilled=0`）是**同款、已知的 execution-layer 塌陷**——本輪只是在新 fixture 裡再次確認它依然存在，不代表 de-patch/labor-pool 新引入了什麼，但也代表「economy flow 健康」這條驗收線這輪**沒有通過**。

## ③ de-patch facility：兩 seed 皆未曾 RUN（非新退化，呼應既有結果）
`manufacture.fired=0`（兩 seed），所有隊伍飽和度 0/15。這跟 mfg-depatch 三驗輪的 seed1337/42（也是這兩個 seed）「facility 60 天內未完工」完全一致——**同款結果重現，非本輪 fixture 特有問題**，只是這次連 seed55501 那種「至少蓋 1 座」的幸運情況都沒出現。誠實揭露：facility 真跑這件事本身仍然高度依賴 seed/時機，這輪抽到的兩個 seed 都落在「沒蓋」那一側。

## ② 組織軸：ratio 0.498/0.505——不當乾淨反例（confound 重）
與 §8 乾淨 fixture 既有健康基準（0.845-1.221）方向不同，但本輪 T2/T3 全程被 `[Sub]`/`[Merge]` 子隊分裂-合併 churn 干擾（population 中途大幅波動），seed42 的 T3 甚至一度瀕臨 famine 死亡（`[Famine] Team3 餓死`）。這些是本 fixture 疊加的真實世界動態，跟 §8 那種乾淨對照組（無 churn）不是同一個實驗條件，**不宜直接拿這個數字反駁 §8 已確認的「pool 機制健康」結論**，如實回報現象+confound，不代下「機制退化」的結論。

## determinism + 不凍
- **determinism**：seed=1337 三跑，`diff -B -w`（排除 TickPerf）逐行 byte-identical。
- **不凍**：兩 seed 皆 60 天完工無 hang（世界人口/任務/famine 等持續真變化）——**但要註明**：「不凍」指的是 tick loop 沒卡死，不代表商業活動有在動（economy flow 這條線是靜止的，兩者是不同層次的「活」）。

## 清理確認
`resource_system.gd`（1 行 temp tap）已 `git checkout` 還原，diff 確認乾淨。`config/s5_integration.json`/`scripts/debug/s5_integration_bed.gd` 已刪除，`git status --short` 確認無殘留。

## 落地
raw（4 檔，4206 行，已 `ls`/`wc` 驗證）：
- `docs/measurements/2026-08-03-s5-integration-seed1337-run1.txt`
- `docs/measurements/2026-08-03-s5-integration-seed1337-run2.txt`
- `docs/measurements/2026-08-03-s5-integration-seed1337-run3.txt`
- `docs/measurements/2026-08-03-s5-integration-seed42.txt`

## ★誠實淨判（[[feedback_genuine_value_not_crank]] 精神）
**沙盤不是全活也不是全死**——勞力池 need-driven 分配機制活得很健康（④），世界人口/政治/死亡動態也在真的演變（⑥）。但**三條驗收線這輪沒過**：甲分配政策整輪 0 次 fire（即使教科書級的餘糧+瀕死條件擺在眼前）、整個世界的商業/物流系統 0 成交（呼應已知的舊 gap，非新退化）、facility 真跑這輪兩 seed 都沒蓋成。我不建議修哪裡——`received_buy_orders` 的訊息傳播路徑是我讀到的一條線索，但候選從未生成 vs 候選輸掉決策，這兩種可能性需要 code-level 追蹤（例如在 `_distribute_candidates` 入口加一次性診斷 tap 看 buy_orders 是否非空），architecture call 屬你/blueprint。「生產維地基整合真跑」這句收官宣稱，就本輪證據看，**還不到能講的時候**。
