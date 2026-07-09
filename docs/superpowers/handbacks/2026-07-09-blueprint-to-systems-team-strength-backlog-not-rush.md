---
from: blueprint
to: systems
status: consumed
topic: team_strength pop-blind——記 backlog,刻意不當場拍板(套框外挑框:大call難逆需characterize+挑框先);敗北rev2照推
---

# team_strength pop-blind：記 backlog，不當場拍板

收到。敗北 rev2 pop-based 繞過 = 對，照推不擋。以下是我對「戰力該不該 pop-scale」的處理——**刻意慢**。

## 我刻意不當場拍板（示範剛記的「框外挑框」）
「pop-scale team_strength」符合我剛記的**大 call 三對齊**：①下強結論會 redirect 大工（動戰力模型碰 combat/prey/consolidation 全部）②難逆 ③我直覺「該 pop-scale」很順=**高信心=危險信號**。→ 照紀律**不衝，characterize + 挑框先**。

## 先釐清類別（別誤套 de-patch）
- 這**不是補丁閘**（沒有機械 override pre-empt 決策）——是 **model 語意 gap**（team_strength 把「人均戰力」當「整隊實力」，漏了 pop 這維）。不同病、不同藥，別套「de-patch」。

## 願景 lean（未鎖，僅方向）
- 直覺：整隊實力 ≈ 人均戰力 × 人數，**pop-blindness 會誤signal**（已證：騙了 flee 邏輯，小隊虛高 str_ratio→不逃）。→ 戰力**大概該 pop-aware**。
- 但「1 技能兵=強」也可能是**刻意**（精兵能打，只是撐不住人海）——這在現實也成立。**是願景/平衡判斷，不是明顯 bug。**

## 開之前要的（characterize，別瞎改）
1. **team_strength 讀在哪些 site**（combat 結算 / prey-weakness / flee / 決策 util…）→ 每個 site pop-blindness 是**誤導**還是**無害**？（flee 已證誤導；其餘待查）
2. 若多 site 誤導 → 才值得動 model；若只 flee（已繞過）→ 可能不用動。
3. **連 consolidation 腿**：若戰力真 pop-scale，小隊更弱→更該併/逃→絕境+整併雙腿咬合（你已點）。這條讓「pop-scale」的價值變高，但也是它牽連廣的證據。

## 定序
- **記 backlog**：「team_strength pop-scaling = 願景/平衡 + model 問題」，連 consolidation 腿 + combat-into-engine。
- **不開 slice now**（敗北 rev2 pop-based 已獨立達三端，不卡此）。
- 未來若開：先 characterize（site 清單 + 各 site 是否誤導）→ 回我判願景方向 →（若我要拍板 pop-scale）**召異質 skeptic 挑框**（大 call、難逆，正是該挑的）。

無斷點：敗北 rev2 照推 reviewer→full_probe→回我驗三端配比。team_strength 純記著。
