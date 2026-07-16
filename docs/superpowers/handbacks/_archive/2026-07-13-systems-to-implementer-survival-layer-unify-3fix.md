---
from: systems
to: implementer
status: consumed
topic: [dispatch] 求生層統一3-fix(spec鎖+reviewer R② CLEAN)——worktree feat/survival-layer-unify,三項一次實作
---

# Dispatch：求生層統一 3-fix

spec（讀全文，鎖定）：`docs/superpowers/specs/2026-07-13-survival-layer-unify-3fix.md`。reviewer R② CLEAN（option A）。base=origin/main `0b1efc9`（已 push，spec/instrumentation/bed 都在）。

## worktree
`.worktrees/survival-layer-unify` / branch `feat/survival-layer-unify`（off origin/main 0b1efc9）。code 寫 worktree、handback 寫此 main mailbox 絕對路徑。

## 三項一次做（用戶定：不分批、不分項驗）

### Fix1：退役非-unified 非子隊 `_evaluate_survival` override（Team10 thrash）
`faction_ai_system.gd:3046` gate 改：
```
if uses_unified(team) or team.parent_team_id == -1:
    return   # 有引擎求生路徑(unified任隊/非子隊)→求生走引擎
# 剩：非-unified 子隊 → 保留下方 legacy override body（勿動）
```
- ★只退「非子隊非-unified」；**子隊(parent_team_id!=-1)保留現狀 legacy body**（含 :3095 一般觸發+礦山豁免）——reviewer 抓的 regression（子隊建造中無引擎路徑，全退會餓死 zombie）。
- `:3035-3045` TASK_CAMP 立營在 gate **之前**，勿動。
- 非子隊求生改由 `_evaluate_solo→rank_scored`（survival option 已在 repertoire）承載。

### Fix2：crisis level→edge-trigger（reeval.crisis 13087 根）
- TeamData 加 `crisis_latched: bool = false`。
- `_should_reeval`(:1781) crisis 分支改 edge：進 crisis fire 一次(latch)，持續 crisis 落 cadence 閘(:1802 已 /4)，離開 crisis 解 latch。spec §Fix2 有 pseudocode。
- **保留我已加的 4 個 gated `Probe.bump("reeval.*")`**（reeval.idle/stuck/crisis/directive/cadence，base 已含）——measurer 驗收②要。edge 改法把 crisis bump 放在 edge-fire 那條。

### Fix3：esteem 乘法門檻雞生蛋（低pop隊卡生存底層）
`need_hierarchy.gd:53` food_ready 映射鬆綁——桿 A（主）：參考線從 SATED(5) 改「脫困(DESPERATION=3)即 ramp」，如 `clampf((food_days-DESPERATION)/(SATED-DESPERATION),0,1)`。★TEST VALUE，你實作後 measurer 量校；safe_ready×ambition_gap 兩桿不動。spec §Fix3 有桿A/B。

## TDD + sanity
- 先寫 failing test（Team10 型絕境隊不 thrash / crisis edge 計數降 / 低pop隊能升階），再實作。
- headless ≥1000 tick 無崩潰；determinism（新欄確定性，byte-identical Probe off）；憲法閘 `constitution_gate.gd` 綠。
- reeval_attribution_bed（base 已含）跑得動。

## 完成判定
task 完成由 **systems + reviewer 判**，非你自判（measurer 會全維度驗）。做完寫 handback `to:systems status:open`，附觸及檔 + sanity 結果 + 你發現的意外。**★別自寫 consumed。**

## 註
- 三項互相咬合（Fix1 依賴 Fix2 當餓隊安全網），一起做一起 handback。
- 觸及檔：`faction_ai_system.gd`(Fix1+2)、`team_data.gd`(crisis_latched 欄)、`need_hierarchy.gd`(Fix3)。
