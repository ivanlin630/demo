---
from: blueprint
to: blueprint
status: open
topic: 藍圖 session 交接——本 session 從「GUI 貿易死」滾成 時間/空間統一維度 + 沙盒憲法(NPC行為湧現非腳本)兩大定案;物流 B merged 三病同解;憲法=統一決策 arc finish line(8 違憲溶入,融合非刪);待:系統跑 wave1 threat/solo + tempo(3機械修→A2/60) + 據點密度/A2 承載力值待我裁
---

# 藍圖 Session 交接（2026-07-05）

## 這 session 的弧（一句）
從「用戶開 GUI 發現貿易死」→ 挖出 far 稀釋物流癱（B 修，三病同解）→ 挖出 ×5 是時間污染 → **時間納統一矩陣（新維度）** → 空間尺度也污染 → **空間納矩陣（第二新維度）** → 後勤該 AI 自理 → **沙盒憲法（NPC 行為湧現非腳本，專案定義級）**。

## 兩大定案（已寫死）

### 1. 沙盒憲法（game-design.md 靈魂層 + governing invariant）
> 作者寫世界，不寫決策。給世界（狀態/手段/代價/感知）+ 統一決策引擎；不給行為規則。NPC 行為=引擎輸出非輸入。
- 分辨線：世界規則（食物耗盡/山難走=物理，該有）vs 行為規則（if餓then塞糧/判斷器=腳本，禁）。
- **是所有反覆痛點的根**（沒統一/又判斷器/打補丁）。
- 系統稽核：引擎已對，**8 違憲舊平行路徑**待溶（threat/solo/rung查表/vendetta/prosperity/faction dispatch/ReactionSystem/灰項）。
- **★硬驗收：溶=融合非刪**——選項/考量搬進引擎 option/term，只撕「替 NPC 決定」；每張驗 repertoire 沒少+該出現還出現。

### 2. 時間+空間統一維度（矩陣兩新跨切格）
- **時間骨架**：TimeScale 單源 + 三時間不變量（必導出/移動-遭遇戰連動/語意單位）+ 強制閘掃裸 tick。
- **空間骨架**：遭遇戰動作粒度=錨 → 一格真實距離 → 據點密度/radius 全連動導出 + 閘。
- **真旋鈕**：`TICKS_PER_HOUR 10→60`（非動遭遇戰動作 10=守速度鑑別度）。60 下：動作 24→10 分、一格 1天→4小時（據點密度合理化）。
- **×5→1 + 60 疊乘 = 4小時/格 ≈ 現況 → 抵消餓死潮**。

## 已交付（系統側）
- **B（far elapsed）merged**：物流三病同解（trade 到場 3→21、envoy 4→32、V3 accept 0→1），不塌房、per-tick 守。post-B baseline=**46/8/1/380**。
- 食物收支表：世界一直在餓（60%負流/20%斷糧，速度無關）**但好的餓**（89-96% 搏命）→ 稀缺引擎健康、不灌糧。
- tick60 運算頻率安全證 PASS（唯 1 個 O(N) `_get_near/far` 需 cadence 化）。
- 憲法稽核清單（8 違憲 + 溶法）。

## 待辦（開新 session 接這裡）

### 系統正在/該跑
```
0. 憲法 arc（脊椎主線）：wave1 threat/solo 開撕 + 防新增閘立
   → wave2 faction dispatch(殺統領兩命令+V2-cmd)/prosperity(殺沒征服者根)
   → wave3 rung/vendetta/灰項 → wave4 ReactionSystem(最難,行為溶入/情緒保留)
   每張:融合驗(repertoire沒少+該出現還出現)+R7
1. tempo 平行：3 機械修(unblock 60) → A2(×5→1+60+FOOD/gen重校,gen壓wave2後一次校)
2. 空間骨架導出 → 全掃閘
```

### 待藍圖裁的值（數據回來才裁，別憑推理）
- **據點密度**：等 hex 尺度定死（×1+60=4小時/格）後，按「一日路程內幾聚落」+目標~50隊 裁 min_spacing/total_count/radius。
- **A2 承載力目標**：等最終節奏（×1+60）食物收支重量後裁（好的餓保留、只 recalibrate）。
- **carrier**：deal_merchant=0 需專職商隊（致富→行商湧現+gen priming），排 wave 後段。
- **U5 低識破**：確認技能分層即健康（by design）。

### 懸而未決（低優先）
- envoy accept 低 = 合理的 0（陌生拒，帶禮通了）——傾向調非急。
- V3(b) 直解結盟 0.55 = 合理的 0（QA 蓋章）。
- 空間維度據點密度矛盾（10 據點撒 440 格 vs min_spacing 2）——隨空間骨架解。

## 目標規模 = ~50 隊（五代十國多強並立，已定）

## 關鍵原則（本 session 升的紀律）
- 憲法：遇「X 不足怎麼辦」先問「引擎子需求+手段嗎」，別建 X-subsystem（我犯三次：灌糧/糧道/補給）。
- 尺度變更：先列「所有隱含該尺度的下游量」清單再改（時間常數污染教訓）。
- 加約束前問「這代價已被別的系統承擔了嗎」（長征壓食物=擬真潔癖，被時間暴露+疲勞覆蓋）。
- measure 打臉我多次（V2 假陽性/LOD 二元/PRISONER 誤判）——初掃樂觀必實測證。
- 溶=融合非刪（撕小抄=保留素材、只撕替 NPC 決定）。

## 全 session handback（全 consumed）
lod-remeasure-v2 / time-unification-wave / time-skeleton-anchors / timewave-five-rulings / a2-food-recalib / b-greenlight / hunger-drives-drama / tick-resolution-60 / space-dim-freq-gate / sandbox-constitution / constitution-arc-order。系統回：b-merged / food-ledger / hunger-good / march-food-postb / tick60-safety / constitution-audit（全 consumed）。
