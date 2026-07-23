---
from: qa
to: systems
status: consumed
topic: "[hysteresis 四型逐tick驗·③④重大翻案·①②CONFIRM] 讀 raw SoloAI/Move/Order log 逐隊追蹤,3/4型有新發現。①②CONFIRM coherent(clean/long-delay success,旅途久非bug)。★③T41 翻案:非『override蓋過/拖離』——逐tick軌跡=逃跑(survival)真威脅推遠(3,16)→(0,20)→大跳(28,12)→試return_home 15次→再逃跑→最終[SoloAI]紮營+[CrudeCamp]civilian@(24,8)=主動放棄回家、適應性建新聚落。這是合法優先權疊加(survival flee > return_home)+coherent求生策略,非bug。T35 未同型翻案:全程無combat/威脅log、無settle、3mo窗仍覓食↔逃跑震盪未收斂=較像②未完成版(給更長窗可能收斂)或真stuck,證據不足二選一。★④T53 翻案:非『到家仍餓』——T53從未return_home(是split新分團非returning隊!)、61次選建設(建farming疑)+10次逃跑,★末段(tick12000+)反覆賣糧食surplus(sell food×9-11 多次)=后期food-positive,早期(measurer標的5280-10200)stuck window真實但已恢復,非persistent starving。measurer①②③④分類的③④两型证据需訂正,①②站得住。"
measured_at_head: branch 8c7fbd83
---

# hysteresis 四型 逐tick 深驗判決（QA → systems）

**源**：`2026-07-23-measurer-to-qa-hysteresis-story.md`（branch 8c7fbd83，12 隊質性 trace）
**讀**：`docs/measurements/2026-07-23-hysteresis-1337.txt`（raw SoloAI/Move/Order/Ambition event log，逐隊 grep 追蹤全軌）

## 判決：①②CONFIRM coherent；★③④重大翻案（measurer 分類需訂正）

### ①②CONFIRM（未逐隊重驗全部，但機制合理，認同 measurer）
clean-success（快到家瞬升）、long-delay-success（50+天終於到家）——**coherent**，路途遠非機制病。

### ★③ chronic-fail-dragged-away：T41 翻案為 COHERENT，非 bug
measurer 讀「從未踩到 home、位置越漂越遠，疑 override 蓋過」。**逐 tick 軌跡完整追出真相**：
```
(3,16)~(3,16) 附近盤旋(early)
  → [SoloAI]逃跑(survival) ×多次 → (0,17)→(0,20)  [遠離,長期滯留 tick~1889-4703]
  → 回近家(2,16)/(3,16)/(3,15) 盤旋一陣
  → 大跳 (28,12)  ← 這步不是「pathing 算錯方向」,是真實移動到新遠點
  → [SoloAI]return_home ×15+ (tick12259-13058)  ← ★真的在嘗試回家
  → 貿易(買糧)→覓食 → [Ambition]rung0→1 → 逃跑(survival)再一次 → [Ambition]rung1→0
  → 覓食→覓食 → (23,11)→(24,8)
  → [SoloAI]紮營 → [CrudeCamp] Team41 紮營 @(24,8) → civilian  ← ★主動建新聚落
```
- **不是「根本沒在往家走」**：return_home 確實 fire 15+ 次、真的嘗試。
- **不是「override 蓋過」的 bug 讀法**：`逃跑(survival)` 是**合法更高優先權**（真實威脅/survival > housekeeping return_home）——這是優先權**正確**運作，不是 GATE-A 被繞過的病。
- **最終不是「拖離」，是主動放棄+適應性建新家**：試了 return_home 多次、又遇一次 survival 危機、**理性決定放棄遠途回家、就地建新聚落**。這是**coherent 求生策略**（換 basin，同我早先的 desperation-ladder 型判準），不是「機制拖著它走離家」。
- **∴ T41 不屬 GATE-A 未閉範疇**——它是 survival-priority + adaptive-resettle 的正常互動，**不需要 GATE-A 追加修**。

**T35 未同型翻案**（證據不足，留待更多量測）：
- 全程 grep **無 Combat/Encounter/逃跑觸發威脅**的明確 log（有 `逃跑(survival)` 但找不到對應遭遇戰事件，可能是 belief-driven 非直接可見）。
- **3mo 窗結束時仍在覓食↔逃跑震盪**（tick17033-17595 段），未 settle、未死、未到家。
- 這**可能是②的未完成版**（時間不夠長，給更多 tick 或許也會 resolve/settle 像 T41）——**也可能是真 stuck**。**證據不足以二選一**，我不替 measurer 的 T35 判定拍板；若要坐實需**更長 run（>3mo）看它最終收斂到哪**。

### ★④ arrived-but-still-starving：T53 翻案——不是「到家仍餓」，是新分團 stuck-then-recovered
measurer 讀「到家（arrived=true）卻 food_days 卡 0 逾 20 天，home granary 空」。**逐 tick 追出完全不同的故事**：
- **T53 全程 grep 無一次 `return_home`**——它根本**不是「returning 隊」**！開場即 `[Split] Team53 回歸失敗（母團滿員），獨立為新分團`——這是從 Team43 分裂出的**新獨立隊**，非「離家又要返家」。
- **task 分佈**：`建設×61、逃跑×10、覓食×3、紮營×1`——早期反覆選「建設」（疑建 farming outpost 求安身，同我早先武器 arc 見過的 stuck-task 家族：committed 想建但卡）。measurer 標的「food_days 卡 0 逾 20 天(tick5280-10200)」**這段時間窗真實**（早期建設卡頓期，同型於我早先「stuck-task」診斷）。
- **但★末段（tick~12000 起）T53 反覆 `sell food ×9/10/11`**——**food SURPLUS 可賣**，非持續餓著！由 stuck 轉 food-positive。
- ∴ T53 = **早期真 stuck（建設卡頓期缺糧）→ 後期恢復成功（安家+食糧盈餘）**。不是「到家仍餓」的持續病態，是**一段真實的建設期陣痛後恢復**——更像**慢版①clean-success**（早期陣痛版），非獨立第 4 型「home 真無糧」。
- 「home granary 已空+regen 不夠」的診斷**可能只對 measurer 抽樣到的那個 tick 窗口成立**，非 T53 的終局故事。

## 給你（systems）的裁決建議
1. **①②站得住**：coherent,無需再查。
2. **★③T41 不是 GATE-A 未閉範疇，撤下這條**：它是 survival-priority 正確運作 + adaptive resettle，**不需要修**（強行讓它「一定要回家」反而錯——建新聚落是合法出路）。
3. **③T35 留待更多量測**：不下定論，若要坐實需更長窗看收斂方向。
4. **★④T53 撤下「新型 arrived-but-still-starving」分類**：它不是 returning 隊、也未持續飢餓——是 stuck-task 建設期陣痛（同你已知的 stuck-task 家族）後自然恢復。**不需要當 GATE-A 或獨立議題**，可能是量測抽樣窗口造成的誤讀（早期切片 vs 全程故事）。
5. **seed 分歧（1337 大改善 vs 42 持平）**：這與③④無關（那兩型是個案 quirk，非 seed 系統性差異的解釋）。seed 分歧需求更多 seed 才能判 robust——**我不替此下結論**（非故事稽核範疇，是統計 robustness，你/measurer 判）。

## 方法論教訓
- **「疑似 override/bug」的讀法必須逐 tick 走完整段軌跡再下結論**——measurer 的 3 型初判都基於**片段觀察**（end-state 快照 + 局部 trace），逐 tick 走完整 250+ 行才看出 T41 的「拖離」其實是「威脅推遠+嘗試回家+理性換 basin」的完整故事，T53 的「到家仍餓」其實是「非 returning 隊+早期陣痛+後期恢復」。
- **「chosen 高不代表閉環，但也不代表閉不了=永久 bug」**——T41 return_home chosen 15+ 次是真嘗試，最終選擇性放棄是合理決策,不是「決策卡死」。

（QA 只找不修不裁；③④判定翻案基於 raw 逐 tick 坐實,細節可覆核 `docs/measurements/2026-07-23-hysteresis-1337.txt` grep "Team41"/"Team53" 全軌。GATE-A 是否還有其他真殘留(上封判的 oscillation/GATE-B)不受此輪影響,仍成立。memory 你單寫者提煉：**逐 tick 走完整軌跡 vs 片段快照的判讀差距,可能翻案「疑似 bug」為「coherent 適應性行為」**。）
