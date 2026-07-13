---
from: blueprint
to: blueprint
status: open
topic: [★交接·重開讀我] session狀態——決策引擎架構重構今日收尾,established首次organic>0(1/3 seed)+行為/頻率大幅改善,四個延續選項待裁,main HEAD=cef31e2
---

# ★ 交接：blueprint session 狀態（重開後先讀）

## 主線（今日全貌）：established調查鏈 → 決策引擎架構重構
交接信2026-07-12提到的「農場faction-only雞生蛋死鎖」已在前一輪修完merge。今天接著往established=0這個更大主線深挖，一路查到**決策引擎本身不是真統一框架**（N個獨立term瞎子只在最後加總）——這才是established恆0的真正上游根，farming死鎖只是地基第一塊。

## 今日完整改動鏈（全部merged main，HEAD=`cef31e2`）
1. **S1** 五層需求金字塔急迫度感測（生存/安全/歸屬/尊重/自我實現，inert純感測）
2. **S2** coeff一致性係數表（23個option全覆蓋，非只11個）接入rank_scored + 舊`plan_phase`機制整套retire
3. **normalize T1-T5** term公式量級校準（優先序移到coeff/urgency層，base term正規化成中性執行品質尺度）+ 一個真bug修正（訓練option的eval-gate跟applicable條件對不上）
4. **cadence重構(T-cad1/2)** 拿掉非-unified隊的過強IDLE-lock（原本選一次task鎖死到底，90天只決策1次，蟑螂級行為）→週期重評+crisis-bypass
5. **survival-path** FLEE威脅gate（撤除T1誤加的0.6恆定地板，spurious FLEE 907→0根治）+ survival-latch重選（餓隊不再永鎖覓食到死）
6. **dispatch fallthrough修法** rank[0]選中但目標找不到時，優先落到同需求類別的選項（買糧），非任意次高分選項（生產）
7. **⑦釋放統一** survival/threat/stuck/timeout四套獨立「何時重評」判斷收斂到單一`_should_reeval`（重評頻率過高問題大幅改善：1712→381次/90天）

## 最終驗收結果（systems FINAL報告，已轉告用戶）
- determinism CLEAN全程
- 架構紀律自查通過（判斷點真收斂到單一rank_scored，非合併但內部仍散落判斷的假統一）
- 代表隊trace：行為健康多樣（買糧71%>覓食22%>生產7%），非病態單一選項lockstep
- **established本session首次organic>0**（seed7=1，seed1337/42=0，1/3非全面）
- attrition全面從session初的45-91%降到12-18%

## 待用戶裁（重開後問，四選一或都不選）
1. 穩定established跨seed（現在只1/3點亮，要不要查另外兩個seed為何沒點亮）
2. 調重評頻率（381次仍比理想「低百」略高，要不要再tune）
3. 補不回歸驗證（faction協同/飢荒/戰鬥細部這輪measurer沒空細查）
4. 暫告一段落，這個成果當階段性交付先停

**上次問到「先交接」，用戶還沒回答上面四選一——重開後先問這個。**

## 未收斂的延伸議題（存著，非本輪範圍）
- **守門員全圖②分流入口收斂**：查證後發現「faction成員無個人決策路」這個原本以為的最大洞根本不存在（成員早就走`_decide_unified`），入口收斂變成低價值的「為統一而統一」，已裁定跳過。
- **灰區**（urgency重疊硬gate/COMMITMENT_BONUS逃逸閥/各種豁免exemption）——盤點過但沒動，非本輪範圍。
- **長期展望計畫**（真正多步模擬/前瞻推理）——用戶明確表達的長期夢想，這輪只做了「連續平行混合」帶來的自然前瞻效果，非真正的多步模擬，記錄成未來願景。
- **舊plan-layer S3(survival-bypass)/S4(GUI)**：這兩個slice是稍早「中長期計畫層」設計（Maslow前身）的產物，已經被這次的五層急迫度架構取代retire，不用再接續。

## 關鍵教訓（這輪學到的，延續用）
- **合併≠統一**：把N條散落邏輯塞進同一個檔案/函式，不代表真正統一——要驗證「判斷點數量」有沒有真的收斂到單一決策點，這是這次專門加的硬性要求，之後任何「整併」類工作都要用這條線驗。
- **別在中途量測上燒時間**：模型還沒做完之前，跑量測驗證只是浪費——2小時一輪的成本，要攢一批修法一次做完再驗，不要逐一小改逐一驗證。今天後半段學到這個教訓後效率明顯提升。
- **別自問自答跳過用戶過目關卡**：寫完spec說「請你過目」後要真的停下來等回覆，不能自己Read一遍說「看起來完整了」就當作用戶核准。
- **patch-gate-first紀律貫穿全程**：這輪查到的每一層真根（9-zero/cadence鎖/survival-latch/FLEE地板/dispatch fallthrough）都是遵循「先查是不是死gate/條件錯配，再猜要不要調參數」找到的，屢試不爽。
- **pipeline結構性偏向收束**：reviewer抓風險是對的，但我自己預設值也偏保守（常先提小範圍版），用戶要大願景時要主動扛，不要每次都等用戶反駁才敢做完整版。
- **caveman**：重開會被SessionStart hook自動重啟(full)。用戶要關caveman但保留禁廢話恭維——重開後打「stop caveman」再關一次。

## 一句話
決策引擎架構今天走完一整條大arc，established從恆0首次點亮1個seed，行為從病態(蟑螂鎖死/spurious逃跑/94%單一選項)轉健康多樣。四個延續選項待用戶裁，重開後先問。
