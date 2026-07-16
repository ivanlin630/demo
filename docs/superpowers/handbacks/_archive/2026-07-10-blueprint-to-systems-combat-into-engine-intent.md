---
from: blueprint
to: systems
status: consumed
topic: 下一序意圖——combat-into-engine：逃/戰/追 local 決策 defer 進統一 DecisionEngine，戰場人格連貫湧現
---

# 藍圖意圖：combat-into-engine（下一 slice，用戶排序 2026-07-10）

用戶選此為敗北逃 rev2 後下一序。我給 WHAT/意圖 + 地板守則，架構(HOW/seam/terms/options)你定。

## 為什麼要（玩家體驗買什麼）
現戰場決策（逃/戰/追）是 **hardcoded 門檻/ad-hoc local**（膽量常數 flee_thr、PURSUIT_RATE 固定 5%、追擊與否無人格秤）。統一進既有 **DecisionEngine rank_scored** 後：
- 逃/戰/追跟其他 NPC 決策**同一顆腦**秤（人格值/目標/脈絡 utility），非各自寫死。
- 湧現例：貪婪/殘忍領袖為掠奪窮追、謹慎領袖早脫離、忠誠部隊為護主血戰、疲兵見劣勢即散——同一戰局不同人格出不同 逃/戰/追。
- 呼應決策統一框架 arc 真根（AI 決策不統一 [[project_unified_decision_framework]]）；戰場是最後幾塊 local 決策孤島之一。

## 地板守則（不可退化，這是我 signoff 的硬條件）
1. **rev2 三端配比行為保住**：逃常態(~83%)/俘中頻/殲滅稀但機制在。統一決策**不得**把已定案的三端配比打亂——新框架下逃/戰/追的 utility 權重須**重現**（或更好地表達）rev2 的膽量秤語意，非砍掉重來。
2. **殲滅端質感不變**：仍是雙勇均等死戰專屬（不藉統一偷渡放寬 courage 窗——那是被否的稀釋）。
3. **追擊三管道語意保留**：放血/俘殘/跨tick逐擊仍在，但**追擊與否/多凶**改由人格秤（殘忍/貪婪 term）決定，非固定 5% 無腦觸發——這正是統一的紅利點。
4. determinism/融合閘/憲法 site-freeze 綠（你的閘）。

## 給 systems（HOW，你定）
- characterize：現逃/戰/追 local 決策點清單（`npc_combat_system` mortal_flee/pursuit/force_retreat + faction_ai 戰略追擊）、哪些 defer 進 DecisionEngine、terms/options 缺什麼。
- 補丁閘優先查：若某戰場決策現由硬 gate/override pre-empt → 統一時 de-patch 交人格秤。
- 分 slice 或一次到位你評（arc 可能大，建議先 characterize 出範圍再切 spec）。

characterize 完 handback to:blueprint 對意圖（我確認範圍不漏地板守則）或直接 spec→implementer，你判粒度。
