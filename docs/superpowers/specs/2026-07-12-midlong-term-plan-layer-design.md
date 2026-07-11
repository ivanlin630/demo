# 中長期計畫層 — 設計（blueprint WHAT）

> 2026-07-12 brainstorm 定案（進行中，用戶續思考）。blueprint 願景層。HOW（公式/TEST VALUE/seam）交 systems。屬決策模型完善，[[project_unified_decision_framework]]。

## 動機
- **決策只有短期反應、無中長期規劃**：既有 option（覓食/乞食/投靠/返家補給/攻擊/貿易…）全是**極短期反應**；`AmbitionLadder` 目標錨只是**反應式方向/水位讀數**（rung 生存→稱霸 + archetype），每 10h 反算 food_flow → **抖動不穩**，且**幾乎不主動驅動爬升**（唯一主動偏置=FORCE-archetype→練兵，見 `decision_context:248-254`；`ambition_gap` 算了幾乎沒用）。
- **後果**：隊反應式苟活、卡低階（GUI 全 階0/1）、never 建國（established 恆0）→ coast 然後餓死崩潰（default.json 12mo 實測）。
- **經濟需蓋在中長期判斷上**：貿易/財富/投資/累積本質是中長期行為，沒有中長期規劃層，經濟湧現不出來。
- ∴ 加**中長期「承諾式攀爬計畫」層**：把「被動讀數」變「主動攀爬」。

## 核心原則：延伸階梯，非新求解器
計畫**透過同一顆 `rank_scored` 表達**（偏置 term），**複用**既有階梯條件/archetype/COMMITMENT_BONUS/survival·投靠·整併·遷移 option/敗北模型/threat。**不建 bespoke planner**（違統一框架）。

## 四層模型
```
1. 目標階（既有階梯）：rung + archetype + 目標階(=現階+1,野心cap)。設「往哪爬」。
2. milestone(a)：目標階的達成條件(複用 target_rung)——food_flow≥MIN / pop≥8 / faction≥N。
3. phase(c)：抽象「在幹嘛爬」——求糧/成長/聚勢。由(缺口×個性×隊形)導出。
4. 承諾+偏置(rank_scored)：當前 phase 偏置相關 option 效用 + 跨cadence承諾。
```

## phase 選擇 = 缺口 × 個性 × 隊形式（三者，複用既有）
- **缺口 → 候選 phase**（機械）：缺糧→求糧、缺人→成長、缺勢→聚勢。
- **個性 → 選哪個 + 承諾強度**（多缺口時誰先）：慎重→先求糧穩、野心→先成長賭、貪婪→求糧走囤積貿易。用**現有 person values**（野心/慎重/好戰/貪婪），不新建個性 scorer。
- **隊形式/archetype → 怎麼執行 + 爬到哪**：商隊(貿易,可能封頂積累)/定居有據點(生產,能立國)/武力(練兵征服)/子隊(服母團,可能無完整計畫)/獨立野心(全爬)。archetype 已人格導出，複用。

## 計畫 = 導出的承諾軌跡（湧現，非寫死）
- **階梯條件有天然依賴序**（沒糧沒法長人、沒人沒法立國）→ 從當前階到目標階**排出 phase 序列 = 計畫**（求糧→成長→聚勢→立國）。**導出非手寫**。
- **承諾夠強 → 完成一 phase 才進下一 → 軌跡浮現**（非每cadence挑最大缺口亂跳）。**承諾強度是計畫能否湧現的關鍵**。
- **湧現 = 不同個性/隊形不同軌跡**：慎重商隊「求糧→(停積累)囤財」；野心軍閥「求糧→成長→聚勢→稱霸」；危機隊暫退求糧後恢復。= 各隊不同的、看得見的人生故事。
- **GUI 可讀**：`階1 求糧→[成長→聚勢]→立國`。

## 韌性：逃生閥 + 劇變重規劃（完整回應）
```
milestone 達成       → 進下一 phase（展開）
瞬時噪音             → survival/threat 覆蓋+恢復原計畫（韌性）
phase 卡住(內因,停滯) → 換approach(同phase多option) → 降目標 → 策略轉向(投靠/遷移/整併)
局勢劇變(外力/慘敗/天災/降階) → 重評目標+重導計畫(+pivot)
緊急(餓死線)         → survival 高 priority 覆蓋（既有）
```
- **卡住偵測**：追蹤「離 milestone 有沒有變近」（window 內）；有進度→承諾撐；持續停滯→re-plan。**承諾=進度條件式**（有進度就穩、卡死才鬆）=「不僵化」的答案。
- **劇變 vs 噪音**：看幅度（大 pop/據點/領袖失、壓倒性威脅=劇變；小波動=噪音）。**導出式計畫→階一掉自動重導**（免費，接階梯 demote）。大威脅接 threat 重評 → pivot 防守/投靠。
- **順便修崩潰**：卡住/劇變 → re-plan 遷移/投靠，**主動離絕境找靠山，非固執餓死原地**——當前近視系統缺的、崩潰的一部分解。

## 修既有階梯不穩 — rung 改「計畫驅動」+ 錨/rung 變重導（用戶戳，2026-07-12）
**phase 承諾不自動穩 rung**——`target_rung()` 每 10h 從原始指標重算、與計畫無關，照樣抖。∴ 明確改：

**rung 從「瞬時 target_rung 重算」→「計畫事件驅動」**：
- **rung 升** ← milestone 達成（進下一 phase = 條件達到 = 夠格升）。承諾式非瞬時。
- **rung 降** ← 計畫偵測持續失敗（re-plan）。遲滯，瞬時跌不降。
- rung 天生穩定（只事件變）+ 與計畫統一（同一 milestone-達成/持續-失敗邏輯），不需第二套穩定機制。保留現實檢查（持續撐不住仍降，沒放水）。

**承諾範圍（防「跑舊 phase」不一致）**：
- 承諾**只擋瞬時指標噪音**（food 掉一下不換 phase）。
- **擋不住 = 觸發計畫重導**：①當前 rung 變（milestone升/持續失敗降）②**目標錨變**（領袖換→新野心cap/archetype→新目標+風格）。
- ∴ 錨或 rung 一變 → 計畫重導、phase 換成新目標該做的——**不會換了目標還跑舊 phase**。承諾是低層防抖，錨/rung 是高層，高層變低層跟著重導。

## 交 systems 的 HOW（TEST VALUE）
- phase 導出公式（缺口偵測 + 個性加權選 phase + 承諾強度）。
- phase→option 偏置 term（rank_scored 內，過框架內冗餘 lens：新 term vs 既有 intent_fit/ambient_train）。
- 承諾強度、停滯門檻（幾 cadence 判卡）、劇變幅度門檻、降目標 vs 轉向的序。
- team `plan_phase` + 承諾/進度狀態欄；determinism 保。
- 複用盤點：階梯條件/archetype/COMMITMENT_BONUS/survival·投靠·整併·遷移/敗北/threat——確認接線非重造。

## 驗收
- **計畫湧現可見**：GUI 跑幾 seed，不同個性/隊形顯不同攀爬軌跡（非全卡低階抖動）。
- **主動攀爬**：established>0（隊真的爬到立國）、階分布上移（非全 階0/1）。
- **韌性**：卡住/劇變隊 re-plan（遷移/投靠/降目標），非死磕餓死原地。
- **崩潰**：default.json 深度窗——加計畫層後世界能不能撐/建國（連 collapse 診斷,見 `default-collapse` 系列）。
- 統一框架（無 bespoke planner）、determinism、framework/coin/憲法閘綠。

## 連結
- 待 collapse 2×2 矩陣（config×duration）數字回 → 確認「中長期規劃缺」是否崩潰主根、此計畫層是否 THE fix。
- 經濟（貿易/財富）是此中長期層上的後續湧現層。
