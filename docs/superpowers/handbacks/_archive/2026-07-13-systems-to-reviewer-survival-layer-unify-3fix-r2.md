---
from: systems
to: reviewer
status: consumed
topic: [R②審spec·建議升異質框外審] 求生層統一3-fix(Team10 override退役+crisis edge-trigger+esteem漸進);decision-core結構改,三對齊
---

# R② 審 spec：求生層統一 3-fix

spec：`docs/superpowers/specs/2026-07-13-survival-layer-unify-3fix.md`（讀全文）。用戶裁定三項打包一次修一次驗（`2026-07-13-blueprint-to-systems-bundle-all-fixes.md`）。dispatch/merge 前必過你這關 CLEAN。

## ★建議升異質框外審（三對齊，00_roles §框外挑框）
本 slice 命中三對齊 → 建議你**用不同模型/代 + refute prompt（非 confirm）**審，非同-Opus 框內審：
1. **強結論+redirect 大工**：退役 legacy 子系統(`_evaluate_survival` override) + 重設計核心公式(esteem food_ready 映射)。
2. **相關跳因果**：三根皆 measure/code 坐實，但「三者同源、一次統一」是我下的框——可能過度耦合，或漏交互。
3. **decision-core 難逆**：merge 進主決策路徑，用戶正親判 main fidelity。

## 請 refute 的重點（別 confirm，主動找破綻）
1. **Fix1 退 override 後求生真的接得住？** 非-unified 餓隊改靠 `_evaluate_solo→rank_scored` + crisis 重評。**攻擊點**：有沒有非-unified 隊路徑根本不常跑 `_evaluate_solo`（如某 tick gate/subteam 路徑），退 override 後求生斷觸發→餓死更多？我假設 rank_scored 求生 coeff 夠高會贏，但**未驗「每個非-unified 隊型每 tick 都有機會 re-pick 求生」**。
2. **Fix1 依賴 Fix2＝單點風險**：退 override 後 crisis 重評成餓隊唯一求生觸發。若 Fix2 edge-trigger 有 bug（crisis_latched 卡住不解），餓隊靜默斷求生。**攻擊點**：crisis_latched 狀態機在「crisis 抖動(邊界反覆進出)」下會不會漏 fire 或狂 fire？
3. **Fix3 放寬 esteem 會不會讓脆弱隊過早追生產復餓**（我列了風險+驗收③守，但公式桿 A 的具體映射未定死）——攻擊點：漸進 food_ready 會不會反而讓某些隊 esteem/survival 兩層都中等→coeff 都平庸→決策更糊。
4. **礦村 famine grace（Fix1 §2.2）退役安全性**未定——unified 礦村子隊現況我沒查，交 implementer 驗；你判這是否該 spec 階段就查清（premise gap）。
5. **三項是否真該綁一份**：我論證「同源咬合」。refute：有沒有哪項可獨立、綁一起反而放大 blast radius / 難 localize regression？

## 前提坐實狀態（供你 factcheck 抽驗）
- Fix1 根：`faction_ai_system.gd:680/737`(dual call)、`:3046-3047`(unified skip)、`:3029`起 override body。血證 `docs/measurements/2026-07-13-roach-scan-team10-thrash-1337.log`。
- Fix2 根：`:1781-1786`(_should_reeval)、`:1802`(/4 死碼)、reeval.crisis=13087 `docs/measurements/2026-07-13-reeval-attr-seed1337-2d30fef-dirty.log:6455`。
- Fix3 根：`need_hierarchy.gd:53,57`(esteem 乘法/food_ready)、`options.gd:136`+`terms.gd:6`(買糧 DESPERATION=3 vs SATED=5)、affinity `:95`(生產 esteem 0.5)。

## 回報
- **CLEAN** → 我 dispatch implementer（信箱）。
- **問題/premise_contradiction** → 標具體點，我改 spec 或 halt 重估，不在錯框上 dispatch。
（寄件永遠 open，我讀後改 consumed。）
