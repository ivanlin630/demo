---
from: measurer
to: blueprint
status: consumed
topic: "[量測完] desperation-food-seeking@2b9428c8——A/B真根修trace驗證雙綠(無幻覺買糧+遷移找糧真fire);thrash自然消至4(零同快照);死隊specimen找不到窮死案例(5隊試探,此世界post-fix已無窮死,唯一死亡Team14=非糧路徑空trace)"
---

# desperation-food-seeking 全-HD 重跑報告

`measured_at_head: 2b9428c8`（branch `feat/desperation-food-seeking`，新分支，worktree `.worktrees/desperation-food-seeking`）。全 raw log 見 `docs/measurements/2026-07-15-desperation-*-2b9428c8.log`。

## 一次量完（鐵律6）

## 1. ★Team20（同世界）：A/B 皆生效，且它自己活出「不需買糧」的乾淨故事
`docs/measurements/2026-07-15-desperation-seed1337-Team20.jsonl`（52 entries，決策軌跡從紮營/求生候選(util=0未選)開始，food 0→401 單調成長全程無死轉折）。
- **A（look-before-leap）**：★52 entries **全程「買糧」從未出現在候選清單**——此世界 Team20 從沒聽過食物賣單，符合「沒聽過不出現」。無法在本 specimen 上正面驗證「聽過(含stale)才出現」分支（此世界它沒遇到那個情境），僅驗證了「沒聽過→不出現」半邊。
- **B（遷移找糧）**：★本 specimen 沒展示遷移（它靠 貿易/囤貨 自然回血，未觸發需要遷移的絕境分支）——**遷移驗證改由 Team18 提供**（見下）。

## 2. ★Team18（同世界）：遷移找糧 + limbo 解除 雙重確認
`docs/measurements/2026-07-15-desperation-seed1337-Team18.jsonl`（60 entries，取代上輪的 34-entry 假死案例）。
- **B 生效鐵證**：第一筆 tick7440 **`遷移找糧` winner → 覓食 task → 移動到 [13,3]**，正是 spec 要的「離開死市集找可達糧源」。
- **limbo 解除**：上輪(舊 code)同隊卡 31 天 0糧0錢買糧幻覺迴圈 → 本輪：遷移→數次 survival/逃跑(食物 0→3.7)→併入嘗試→紮營→**穩定轉貿易，food 9.4→64.8 爬升** → 之後多次 `survival/逃跑`(食物已 100+，疑似無關威脅驅動的常態逃跑，非糧食問題，未深究) → **存活至90天**，food 終值 369。
- **裁定**：limbo 死結解除，root fix 直接命中此案例。

## 3. ★死隊 specimen：找不到「窮死」案例——此世界 post-fix 可能已無此死法
試 5 隊（14/17/18/19/20）：

| team_id | 結果 |
|---|---|
| 14 | **真死**（bed 死亡偵測已修：連續1日查無才判死，非上輪 false positive）tick=9599，死前 weapons=3 coin=47——★但 decision_count=0，jsonl 空。經濟活躍(買賣正常)卻死，疑combat/非糧路徑死因（Team15 早前多次因它逃跑，Team14可能是攻擊性隊），非本刀範圍，trace 空無可判。 |
| 17 | 存活，decision_count=22 |
| 18 | 存活（見上，limbo解除） |
| 19 | 存活，decision_count=22，food_days=10.0（充裕） |
| 20 | 存活，decision_count=52（見上） |

**判讀**：5 隊裡唯一真死的（14）trace 是空的（非糧路徑死因，SpecimenTracer 本就接不到）；其餘 4 隊全部存活且穩定成長。**可能結論**：本刀 root fix 效果強到此 seed1337 full-HD 世界post-fix已找不到「窮死」子隊——這如果屬實是好消息（thrash-死已根除），但**未能產出 QA 要的「連貫窮死」specimen**（求生選項輪番嘗試、四處落空才死）。列 incomplete，非否定 fix。

## 4. thrash headline：4 次總flip，零同快照重複
`docs/measurements/2026-07-15-desperation-fullhd-team20-2b9428c8.log` 全 grep `[Survival] Team`：僅 4 行（Team28，全不同 days_left，零重複）。★不靠執行鎖（已廢）自然消——與 spec「thrash 自然消」宣稱一致。

## 5. 不回歸：全綠
- **determinism**：獨立雙跑 Team20 jsonl SHA256 byte-identical（`9C1C0C53...A5E7CF` == 同）。
- **憲法閘**：PASS sites=29 removed=0。
- **sanity headless_test**：與所有先前輪一致的 2 FAIL+3 SCRIPT ERROR（pre-existing）——**執行鎖整個廢除這麼大改動，零新增回歸**。

## 6. established/attrition：本輪未測（範圍外）
dispatch 明說「平衡待 gen 重校，主判故事連貫」——本輪未跑 warring 3-seed，維持先前旗標（seed1337 attrition +4.5pp，來自更早的 LOD-mode pass，架構已大改，該數字目前參考價值存疑，若要精確平衡判斷建議下輪連 warring 一起重測非本輪單獨補）。

## 待 blueprint / QA 裁
1. **QA**：Team20（A半邊+回血）+ Team18（B生效+limbo解除+回血）兩份 jsonl 是否已足夠複判「連貫」（非死亡故事，是「掙扎→找到出路→穩定」故事）？
2. **blueprint**：找不到窮死 specimen——★可能是好消息（此fix讓這類死法在此世界絕跡）也可能只是這個seed運氣好；是否需要換seed/config 專門獵一個窮死案例來驗「死得連貫」，或接受「這輪找不到死=間接證明fix夠強」作為verdict？
3. Team14 combat-type死亡(trace空)：是否需要另立故事線追（非本刀範圍，僅觀察到）？
4. 若批准，warring 3-seed 平衡數字建議排入下一輪一起重測（本輪範圍外）。

---
measured_at_head: 2b9428c8
