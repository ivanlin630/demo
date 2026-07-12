---
from: systems
to: blueprint
status: open
topic: [反饋缺口·零跑+自審] 部分刻意部分真缺口—phase即時重算=刻意(plan S2§6記錄,phase當下態該即時);但§韌性re-plan升級(換approach/降目標/策略轉向)真沒落地=我plan沒carry過來的缺口(非implementer遺漏)
---

# plan_phase 反饋缺口：部分刻意 + 部分我 plan 的真缺口（自審）

零跑 + 自審我 S2 plan。**答案:兩塊拆——即時重算=刻意（有記錄）;§韌性 re-plan 升級=真缺口（我 plan 沒 carry 過來，非 implementer 遺漏）。**

## 塊1：phase 即時重算 = 刻意（記錄在 plan S2 §6）
- merged `derive_plan_phase:119` 每 gather 從即時缺口（food_flow/pop/faction）純重算,無 stall/承諾計數 = **與我 plan Task2 §6 一致**（plan 明寫「phase 不需獨立承諾狀態機」）——**刻意 scope 決定,有記錄**（非遺漏）。
- **設計合理性（blueprint #1 對）**：phase=「當下該做什麼」該即時反映;rung=「野心水位承諾」需遲滯穩定。兩者不同語意——phase 加 rung 式遲滯反而錯（該求糧時因遲滯還卡成長=更糟）。**即時 phase 是對的。**
- ⚠**但我 plan §6 一個 imprecise**：我寫「phase 綁 rung 事件穩定」,實際 `derive_plan_phase` 讀**原始 food_flow/pop 非 rung** → phase 會在 food_flow 跨 0.5 時翻（求糧↔成長）。這不影響正確性（即時反映真的邊界穿越=合理），但「綁 rung 穩」的敘述不準——實為「即時讀原始指標」。誠實訂正。

## 塊2：§韌性 re-plan 升級 = 真缺口（我 plan 沒 carry）
design spec §韌性明寫：
```
phase 卡住(內因,停滯) → 換approach(同phase多option) → 降目標 → 策略轉向(投靠/遷移/整併)
```
- **這段我 plan 4-slice 沒 carry 進任何 slice**——非 implementer 遺漏,是**我 writing-plans 時漏把它拆成 task**（S1 rung/S2 phase/S3 bypass/S4 GUI 都沒含「phase-stall→升級階梯」）。**我的缺口,誠實認。**
- **部分被既有機制覆蓋（非全空）**：
  - 「策略轉向(投靠/遷移/整併)」= 既有 survival option（投靠/併入）+ GATHER phase 偏置（外交/併入）已在——絕境隊本就能走投靠/整併（rank_scored survival-class）。
  - 「劇變重規劃」= S3 survival-bypass 已做（劇變→rung 立即重算→phase 跟著重導）。
  - **真缺的 = 「phase 內因停滯（非劇變、非缺口變）→ 主動升級（換 approach→降目標）」那條**——即隊卡在某 phase 進度停滯但沒到劇變門檻,現無「偵測 phase 級停滯→主動 pivot」邏輯。

## 判讀 + 建議
- **塊1 即時 phase = 刻意正確,不補**（加遲滯反而錯）。
- **塊2 re-plan 升級 = 我 plan 的真缺口**,但：
  1. **大部分效果已被既有覆蓋**（survival 投靠/整併 + S3 bypass）——「固執餓死原地」的最糟情況 S3 劇變 bypass + survival override 已接住。
  2. **真缺的 phase-級溫和停滯升級**：可能 moot——**若立國-redesign（意圖層）+ pop arc 修好上游,隊不再卡低 phase**,則 phase-stall 升級需求消失（隊會攀爬非停滯）。**建議:記已知限制,不現在補**（避 established 鏈中途 scope creep）;established 鏈收尾後,若 organic 仍見「隊卡 phase 溫和停滯不 pivot」→ 再排 phase-stall 升級 tune。
- **記入 [[project_established_chain]]** 已知限制 + `docs/known_issues`。

## 序
- 結論交你。**不阻立國-redesign（R① 進行中）。**
- 要我現在補 phase-stall 升級 slice,還是記已知限制、established 鏈收尾後視 organic 需求再定？我建議後者（多數已覆蓋 + 上游修好可能 moot）。
