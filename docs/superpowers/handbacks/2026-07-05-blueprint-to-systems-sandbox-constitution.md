---
from: blueprint
to: systems
status: open
topic: ★沙盒憲法(專案定義級)——作者寫世界不寫決策,不得限制NPC行為邏輯;凡NPC行為必經統一決策引擎,禁繞過引擎的行為規則/判斷器/subsystem;請表達成governing invariant+矩陣強制閘+稽核既有碼溶違規;附tick60三裁(PRISONER收下/3機械修先做/60併A2/後勤=引擎domain非subsystem)
---

# 沙盒憲法 = governing invariant（+ tick60 三裁）

用戶下專案定義級約束。已寫進 `game-design.md` 靈魂層「沙盒憲法：作者寫世界，不寫決策」。請系統表達成架構層 governing invariant + enforcement。

## ★ 憲法（WHAT，我 owner 已定稿）
> 模擬沙盒——NPC 行為湧現非腳本。我們給世界（狀態/手段/代價/感知）+ 統一決策引擎（utility weigh，人格調製）。**不給行為規則。NPC 行為 = 引擎輸出，永不是輸入。**

**分辨線**：
- ✅ 世界規則（物理，該有）：食物耗盡/山難走/遠征累/被打傷/資訊霧 = 手段空間+代價。
- ❌ 行為規則（腳本，禁）：`if 食物<X then 塞糧`、判斷器、行為 subsystem = 替 NPC 決定。
- 判準：描述「世界怎麼運作」(作者) vs「NPC 該怎麼選」(引擎)。

## 請系統做（HOW，你 owner）
1. **表達成 governing invariant**（納 invariants.md，凌駕級）：
   > 凡 NPC 行為必經統一決策引擎（means-end 子需求 + utility weigh）。禁繞過引擎的行為規則/判斷器/行為 subsystem。行為是引擎輸出。
2. **矩陣強制閘**：掃「替 NPC 決定的碼」——硬編 action selection 在引擎外、判斷器 prescribe 而非 weigh、行為 subsystem。= 違憲，fail。
3. **稽核既有碼**：哪些是替 NPC 決定的行為 subsystem/判斷器 → 列出 → 溶進引擎（非特例）。這是統一矩陣的收斂主軸（連「架構已定別打補丁」+「統一決策框架」arc）。
4. **零例外確認**：絕境=survival utility 支配（引擎內非 override）、遠方=疏非慢非笨（引擎決策非變笨）。驗這兩處沒偷寫行為腳本。

## ── tick60 三裁（承 `tick60-safety`）──

**PRISONER_CHECK 誤判收下**：measure 翻我初判（encounter-tick 凍結框、非 world-clock，類別錯）。measure-first 又擋我樂觀初掃。✓

**裁1：3 機械修 = 獨立 slice 先做**
`_get_near/far gate（per-tick有界閘,順餵A-arc）+ 10裸常數導出 + eta/240 + FLEE硬編240（時間量必導出閘）`。零/小行為、unblock 60。先做。

**裁2：60 併 A2**（收系統建議）。關鍵算：×5→1 + 60 疊乘 → 移動一格 240 tick ÷ 1440 = 1/6 天/格 = 4 小時（≈現 ×5 的 4.8 小時）→ **60 抵消 ×5→1 的食物懲罰、根本沒餓死潮**。×1+60=最終節奏，gen/food 一次重校。

**裁3：後勤 = 統一決策引擎 domain，非 subsystem（憲法首個應用）**
- **砍 A2b 沿途補給 subsystem**（YAGNI + 違憲）。
- 改成：驗「食物不足-on-journey 登記成引擎子需求？塞乾糧/買/搶/覓食 被當 affordance 匹配？」= 引擎接線檢查，非建機制。
- 缺 → 接進引擎；全 → AI 自理（隊餓死路上=選錯[戲]或感知/手段缺[修接線]）。
- 距離的戰略代價 = 時間暴露（老家空虛）+ 疲勞 = 已有世界代價，非替 NPC 寫反應。
- **食物/carry = 最終節奏（×1+60）重量**，別用 ×1/10hr 中間態高估（38-47% 是 1天/格 的高估，4小時/格 下不餓）。不預設「該壓長征」——AI 自己權衡。

**裁4：空間維度 = 全連動導出**（矩陣永久格）。本 arc 落空間骨架（遭遇戰錨→據點density/min_spacing/radius 全導出）+ 閘。據點密度具體值=等 hex 尺度定死後我裁（按「一日路程內幾聚落」+目標~50隊）。

**驗收補**：60+×5→1 後**物流三病 QA 重驗脫 0**（節奏變，R7 全環對照確認 B 沒被推翻）。

## 序
```
0. 憲法 invariant + 強制閘立 + 既有行為 subsystem/判斷器 稽核清單（系統，最高，貫穿矩陣）
1. 3 機械修（獨立 slice，unblock 60）
2. A2 = ×5→1 + 60 + FOOD/gen 重校（最終節奏一次校，砍補給 subsystem）
3. 空間骨架導出 + 據點密度（待我裁值）
4. QA 物流重驗 + 食物最終節奏重量 + 憲法違規稽核
5. cadence③/carrier/V2-cmd = 後段
```

## 藍圖自檢
我連三次 subsystem 思維（灌糧/糧道/補給 subsystem）被用戶拉回。**憲法講死後這類自動判違規**——這正是「根講死免逐個抓」的價值。升紀律：遇「X 怎麼辦」先問「引擎子需求+手段嗎」。
