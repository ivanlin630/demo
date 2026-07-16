---
from: blueprint
to: systems
status: consumed
topic: [code審·零跑] 立國redesign喊停重查——B門established現況是否有意圖層(argmax)或純機械gate;立國是否掛在目標錨(5錨/TimeScale)系統上
---

# 立國redesign暫停——查兩題再重新設計

## 背景
之前設計「立國門整體重思」已R②CLEAN、推systems出spec中。**用戶叫停**：原設計只是把B門(統領/野心/readiness)硬門檻降級成加成，主閘簡化為「≥2成員+存續時間」——用戶指出這等於「條件過了就自動立國」，變成**人人可立國**，這不是他要的。他要的是：**閘可以放寬，但要有「立國傾向」的faction才會立國，非條件一過就機械觸發**。

## 待查（零跑，優先於重新設計）
1. **B門(established)現況是否有意圖層**：對照A門「建國」——`_evaluate_independent_strategy:1197 select_strategic_intent`要建國intent先贏argmax(跟致富/守成/防衛等其他意圖競爭)，非條件夠了就自動建國。**B門「立國宣告」(`_declare_established:3349`附近，`faction_ai:974-979`)是否也有類似的意圖競爭層，還是純粹「四條件AND全過→自動設is_established=true」的機械gate？**這是本次redesign最關鍵的前提，我原設計沒查證這點就假設是機械gate，需要file:line坐實。
2. **立國是否掛在目標錨系統上**：user memory提過「5錨+TimeScale骨架」(`project_time_scale_wave`)——查現有錨系統(若存在)是什麼、在哪個檔案、established/立國這個里程碑目前有沒有掛上去，還是完全獨立運作的機制。

## 為何現在查（暫停原設計）
若B門本來就有意圖層(類似A門)，那「立國傾向」這個概念可能已經存在，只是被四重機械門檻擋在意圖評估之前，redesign方向要改成"讓有立國傾向的faction在意圖層有機會贏，而非條件過了就自動觸發"——這跟原設計（降門檻+加成）完全不同路數。若B門確實純機械gate、無意圖層——那才需要**新增**一層"立國傾向"判斷（比照A門pattern，faction要先在decision layer選擇"走向立國"這個路線，贏過其他策略選項，才能進入B門條件檢查），而非只是調條件本身。

## 序
零跑出兩題答案 to:blueprint → 我依答案重新設計（加意圖層，非只調門檻）→ 待用戶確認新設計方向 → 對抗①→systems spec → build。
