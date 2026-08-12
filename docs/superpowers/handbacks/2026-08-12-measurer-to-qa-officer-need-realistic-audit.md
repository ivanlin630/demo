---
from: measurer
to: qa
status: consumed
topic: "[請QA故事稽核:officer_need realistic驗證雙specimen]核心claim=T4/T8在officer_need真達1.0(真dispatch drain非公式產物)的日子裡,task始終是貿易/覓食,一次都沒切到訓練——這是逐日task欄位(Chinese string)+specimen candidates交叉讀出來的,需要故事稽核鎖定。★最想請你核:①T4day8-15/T8day5-15這些『need=1.0但task非訓練』的日子,能否在specimen candidates裡直接看到訓練選項出現過但輸掉、還是連候選都沒生成(跟tier-up-chain-e2e那次T2『archetype gate導致候選消失』同型態,但這次T4/T8已經applicable=true理論上該進候選)②T12全程anon/named/officer_need零變化,15天13個左右真決策點(非只day-boundary)是否confirm從未真dispatch過③4隊床T0訓練候選只在tick10出現一次(util=0.076)之後45天再也沒出現過,這個『出現一次就消失』的模式(同上輪tier-up-chain-e2e一樣)是否有共通機制解釋(比如某個eval-cadence gate)。"
---

# 請 QA 故事稽核：officer_need realistic 驗證雙 specimen

`2026-08-12-measurer-to-systems-officer-need-realistic-verdict.md` 已回 systems（並行送你）。核心 claim（T4/T8 在 `officer_need` 真達 1.0 的日子裡，task 始終是貿易/覓食，一次都沒切到訓練）是逐日 task 欄位 + specimen candidates 交叉讀出來的 behavior-causal claim，需要故事稽核鎖定。

## 最想請你核的三點

1. **T4/T8「need=1.0 但 task 非訓練」的日子，訓練選項到底有沒有進候選清單**：能否在 specimen candidates 裡直接看到訓練選項出現過但輸掉，還是連候選都沒生成（跟 tier-up-chain-e2e 那次 T2「archetype gate 導致候選消失」同型態——但這次 T4/T8 理論上 `applicable=true`，應該要進候選才對，如果連候選都沒生成，代表還有另一層我沒發現的 gate）。

2. **T12 全程零變化，是否真的從未 dispatch 過**：15 天內約 13 個真決策點（非只 day-boundary），能否確認 T12 從未真的嘗試過 scout/care/rescue dispatch。

3. **T0 訓練候選「只出現一次就消失」的模式**：4 隊床 T0 的訓練候選只在 tick10 出現一次（util=0.076），之後 45 天再也沒出現過——這個模式跟上輪 tier-up-chain-e2e 一樣，是否有共通機制解釋（比如某個 eval-cadence gate 讓某些 ambient option 只在特定時機評估一次）。

## 落地檔案（已 git commit `26a67c06`）
- `docs/measurements/2026-08-12-officer-need-4team-seed8181.specimen.jsonl`
- `docs/measurements/2026-08-12-officer-need-diverse-seed8181.specimen.jsonl`
