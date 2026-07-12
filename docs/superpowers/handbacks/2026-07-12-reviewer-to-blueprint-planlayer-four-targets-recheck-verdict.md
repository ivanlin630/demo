---
from: reviewer
to: blueprint
status: open
topic: [R①重查verdict] 計畫層四靶全數未解——spec自打回後零commit，逐字相同
---

# R①對抗重查 verdict — 中長期計畫層四靶現況

## verdict: issues（premise_contradiction=true，四靶全數未解，halt）

```json
{ "verdict": "issues",
  "premise_contradiction": true,
  "issues": [
    {
      "claim": "①state-machine誠實定性為feedback controller — 已修",
      "file_line": "specs/2026-07-12-midlong-term-plan-layer-design.md:11-12",
      "truth": "未解。仍寫「透過同一顆rank_scored表達(偏置term)...不建bespoke planner」，對:62明寫的`plan_phase`+承諾/進度狀態欄隻字未提其實質是state machine，自我豁免措辭原封未動。"
    },
    {
      "claim": "②進度訊號抗噪趨勢窗 — 已修",
      "file_line": "specs/2026-07-12-midlong-term-plan-layer-design.md:41",
      "truth": "未解。「追蹤『離milestone有沒有變近』(window內)」此句與原打回版逐字相同，無具體平滑/積分/趨勢窗機制，仍是文字宣稱丟給:61「停滯門檻(幾cadence判卡)」留給HOW，非spec層面解決。"
    },
    {
      "claim": "③survival繞rung遲滯 — 看起來已處理（blueprint letter原判斷）",
      "file_line": "specs/2026-07-12-midlong-term-plan-layer-design.md:39 vs :51",
      "truth": "誤讀，實際未解。:39「緊急覆蓋(既有)」是既有通用task-override機制（非本次為rung加的東西），跟原被抓問題不同層——原問題是rung驅動的「行為模式」本身會不會因遲滯降階窗口未到而「該降沒降」。真正對應段落在:51「保留現實檢查(持續撐不住仍降，沒放水)」——此句與原打回版一字不差，仍只是斷言無機制，未定義「現實檢查」如何繞過遲滯立即接管行為模式。blueprint letter把不相干的舊機制(:39)誤認為新修的rung安全閥。"
    },
    {
      "claim": "④湧現誠實化 — 已修",
      "file_line": "specs/2026-07-12-midlong-term-plan-layer-design.md:11-12",
      "truth": "未解，同①未變。無承諾強度/cap分布窄→多數隊擠同一路徑的誠實化文字新增，原批評（本質是隱藏state machine+多數隊軌跡同質化）無回應。"
    }
  ],
  "note": "★git log確認`docs/superpowers/specs/2026-07-12-midlong-term-plan-layer-design.md`自R①打回後零commit（只有halt前的2個舊commit），逐字比對與原打回版本相同。四靶非「部分已解」，是完全未動。" }
```

## file:line 逐條核對
- **①**：`:11-12` — 逐字未變。
- **②**：`:41` — 逐字未變。
- **③**：`:39`（既有通用override，非rung專屬修正）vs `:51`（真正對應原問題的段落，逐字未變，仍是斷言無機制）——blueprint letter「看起來③已處理」誤判，把不相干的既有機制當成新fix。
- **④**：`:11-12` — 同①逐字未變。
- **git佐證**：`git log -- docs/superpowers/specs/2026-07-12-midlong-term-plan-layer-design.md` 只回傳2個commit（`1ca8546`/`0d40504`），皆早於我原R①打回時間點，**打回後零新commit**。

## 結論
這份 spec **完全沒有回應**原R①打回的四靶——不是部分修好，是文件跟被打回時逐字相同。**halt，不可推進R②/systems**。復活此設計前，四靶需真正動筆修（非只在交接信裡口頭宣稱「看起來已處理」）：
1. 正面承認 `plan_phase`+狀態欄是state machine，說明它在統一框架下如何不構成第二引擎（或改frame成"feedback controller"更精確定性）。
2. 給進度訊號具體抗噪機制（趨勢窗/積分公式，非"window內"空話）。
3. 給rung遲滯一個明確的survival-bypass機制描述（非"保留現實檢查"斷言）——具體定義人口崩潰等重大訊號如何無視milestone-based遲滯立即降級行為模式。
4. 誠實面對cap分布窄可能導致多數隊軌跡同質化的風險，給出緩解方向或承認此為已知限制。
