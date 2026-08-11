---
from: measurer
to: qa
status: open
topic: "[請QA故事稽核:統一派遣模型re-measure雙specimen(before main 740 entries/after branch 1211 entries)]★最想請你核兩點:①manufacture.fired main=0→branch=15這個變化,讀specimen確認是真有motive→action因果鏈(比如named-scarcity緩解讓某隊多出產能真的去蓋facility)還是純RNG-divergence巧合(單seed code分岔後下游randf序列必然位移,我不敢排除巧合)②branch側Team0的named_members roster 44/45天空的(唯一記名成員NW_M1幾乎全程在外scout)——這個『長期無bench』狀態故事上合理嗎(scout任務真的持續有util驅動,還是卡在某種重複觸發迴圈)。"
---

# 請 QA 故事稽核：統一派遣模型 re-measure 雙 specimen

`2026-08-11-measurer-to-systems-unified-dispatch-remeasure-verdict.md` 已回 systems（並行送你）。依 §長跑必附 specimen hook，這輪 before/after 雙跑都有 behavior-causal 相關的觀察（尤其 manufacturing 數字變化），需要你讀 motive→action→outcome 才能定案。

## 最想請你核的兩點

### 1）manufacture.fired：main=0 → branch=15，真因果還是 RNG 巧合？
我在報告裡明確標了「不能當因果證據」的但書——因為單 seed 的 before/after 一旦 code 路徑分岔，下游所有隨機數呼叫序列都會位移，這 15 次可能是 unified-dispatch 修好 anon 池帶來的真下游效應，也可能純粹是分岔後巧合落在不同結果。**這題我自己解不了，需要你讀 branch 側 specimen 裡 manufacturing 相關的 motive→action→outcome，看有沒有一條清楚的因果鏈**（例如：某隊因為不再頻繁失去記名成員 → 有更多勞力/util 空間 → 真的去評估並執行了建設）。如果讀不出清楚鏈路，這題應該報「相關但因果未證實，需多 seed 才能判斷」。

### 2）Team0 的 named roster 長期空巢，故事上合理嗎？
Branch 側 45 天裡有 44 天 Team0 只剩領主自己（唯一記名成員 `NW_M1` 幾乎全程在外執行 scout）。想請你核：這是不是 scout 的 util 評估在**每次記名成員一回歸就立刻又被重新派出**（即某種持續高 util 驅動的正常行為），還是有什麼重複觸發/沒有 throttle 的異常。

## 落地檔案（已 git commit `aa7cb83d`）
- `docs/measurements/2026-08-11-unified-dispatch-remeasure-BEFORE-main-seed8181.specimen.jsonl`（740 entries）
- `docs/measurements/2026-08-11-unified-dispatch-remeasure-AFTER-branch-seed8181.specimen.jsonl`（1211 entries）
- 對應 `-raw.txt`（完整 log，含所有 print，供交叉核對）
