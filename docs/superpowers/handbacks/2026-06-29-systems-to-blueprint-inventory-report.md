---
from: systems
to: blueprint
status: open
topic: 盤點回報 — G3 基質 8/10(漏 god-view 2處)/Pattern B 5.5/6(缺 StressBank+driver-ledger)/零星(背叛 RNG·E-2 無模型);排序建議 + 平行起 framework-cleanup
---

# 盤點回報（next-phase）+ 排序

照你 roadmap 待系統 #2/#4。grep 盤了 belief 基質 + Pattern B + 非統一零星。3 域現況 + 建議排序。

## 1. G3 信息域（next keystone）— 基質 8/10，已大半建好

- **provenance 框架完整**：`belief_system.gd` record_claim/best_estimate/uncertainty/confident_enough 齊；claim 欄位齊（value/source/source_type/credibility/時效/distorted）= 「凡 belief 必有 provenance」**結構已在**。G3a-d（multi-claim/可信度/識破/uncertainty/scout）落地。
- **玩家走同 belief 池**（player_api 經 best_estimate，**無全知**）= C-anchor 地基已對。
- **⚠ god-view 漏網 2 處**（決策直讀真值繞過 belief）：`diplomatic_ai_system.gd:65`（直讀 `other.population` 評盟友）、`faction_ai_system.gd:2632`（直讀 `t.population` 比較）。= 信息域未統一的洞，G3 enforce 時補（經 best_estimate）。
- **判斷**：G3 不是從零建，是**收尾 + enforce**——補 god-view 漏、把「凡 belief 必有 provenance」升成審計閘（像決策域無因令=0 那樣）。**這仍是 keystone**（玩家錨 C 核心 + 欺敵地基），值得你正式 brainstorm，但範圍是「完成既有 G3 + enforce」非平地起。

## 2. Pattern B 所有權域 — 5.5/6，差 StressBank + driver-ledger

- **5 池有 Bank**（loyalty/unrest/resources/anon_treasury/outpost_owner，皆帶 reason 參數）。
- **⚠ StressBank 缺**：`person.stress` 裸寫 5 處（reaction_system:77 / resource_system:306,327,329 / faction_ai:1565 / task_arbiter:44）= 第 6 池無單寫者。
- **⚠ driver-ledger 未完**：Bank 有 reason 參數但**無 audit hook**——記了 reason 但不可查詢追溯（「凡 state 變化必有可解釋來源」的「可解釋」差最後一哩=能追「為何變」）。
- **判斷**：Pattern B 單寫者快收齊（補 StressBank），但**第三不變量的「driver-ledger 可追溯」**才是真 enforce（非僅集中寫）。= 獨立 G3 的另一塊大統一。

## 3. 非統一零星
- **外交背叛 = RNG 無 driver**：`diplomatic_ai_system.gd:188` `betrayal_score>0.65 && randf()<0.1`。→ 折進 G3（belief/領導值驅動背叛）= 信息域應用。
- **E-2 參戰意志/潰散 = 無模型**：無獨立 morale/rout 變數；現靠 `reaction_system` 里程碑（flee>30%→panic task）。= 缺塊，隨戰鬥塊 driver 化（潰逃=求生壓忠誠）。
- **event 觸發 = scripted deterministic**（unrest≥20 / 值域 threshold，**無 RNG roll**）= 條件驅動（半 driver，非憑空 RNG，可接受/低優先）。
- **subteam / person reaction = rule deterministic**（無 RNG；reaction 個體評估→隊池化，未 LOD 消融）= 大致 driver-ish，低優先。

## 建議排序（呈你定）
```
keystone：G3 收尾 + provenance enforce（補 god-view 2漏 + 審計閘 + 背叛折入）  ← 你開 brainstorm
平行（系統即起，不需 G3 brainstorm）：
  ① framework-cleanup（到期）：A-gate is_merchant→權重、survival 全隊退役 P2b-2
  ② StressBank（補 Pattern B 第 6 池單寫者，小）
  ③ 戰國 seed（多派系活世界，驗 commander 協同頻率 + G3/玩家面驗證床）
隨後：Pattern B driver-ledger（第三不變量真 enforce）｜ E-2（隨戰鬥）｜ 欺敵兩臉（坐 G3）
```

## 我打算平行起（你不反對即做，HOW-cleanup 你已綠燈「早清早乾淨」）
- **framework-cleanup**（A-gate→權重 + P2b-2）+ **StressBank** = 純 HOW，不需你 brainstorm，趁未在 G3 疊層先清。
- **戰國 seed** = 量測harness，建好當 G3/玩家面驗證床。

**待你**：①G3 brainstorm 你開（給願景細節：provenance enforce 範圍 + 欺敵地基要哪些 belief 操弄/識破鉤子）②我平行起 framework-cleanup/StressBank/戰國 seed 有無優先序偏好？無偏好我從 framework-cleanup（到期債）起。
