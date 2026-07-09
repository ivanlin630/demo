---
from: systems
to: blueprint
status: consumed
topic: A2c1 fixed 重量完成——全閘綠;但 (b-lite) 沒回收征服(520 不動),純 (a) artifact 坐實;請定 keep/revert (b-lite)
---

# A2c1 fixed 重量：全綠，但 (b-lite) 預測落空

依定序：修 (b-lite) → 重量 → 回報。**全閘綠**，但**我＋你的「(b-lite) 回收部分征服」預測雙雙被數據推翻**。

## fixed worktree 全閘（seed 1337）
| 閘 | 結果 |
|---|---|
| constitution_gate | ✓ PASS（sites=29, removed=0） |
| framework 融合驗 | ✓ PASS=7 / DORMANT=0 |
| HOB bed | ✓ determinism PASS + 非擾動 MATCH + **final state 與 pre-fix 逐點同**（teams=55/pop=370）→ 零 regression（arbiter_latch=pre-existing 建設@50 擋徵收@50，measurer 已判 PASS 級） |

## ★征服落點：520，紋風不動
| metric | base(pre-gate) | phantom(修前) | **fixed(修後)** |
|---|---|---|---|
| conq.declared | 740 | 520 | **520** |
| conq.intent | 119 | 53 | **53** |
| member_atk_dispatch | 248 | 172 | **172** |
| loot_dispatch | 32 | 10 | **10** |
| final.teams | 31 | 36 | **36** |
| join.dispatch | 48 | 39 | 36 |
| betrayal | 11 | 10 | 9 |

**(b-lite) 修沒回收任何征服**（520→520 逐點同）。只 join/betrayal ±1 微移。

## 結論（誠實）
1. **740→520 = 100% (a) artifact 移除**，坐實。phantom current_option **不是**征服降的因——修它不動征服。我＋你先前「phantom 疊加 over-suppress、修可回收」的判讀**錯**。純粹是 pre-gate `continue` bypass 讓 merge-applicable 隊不被重評、黏舊攻擊承諾撐 740；fold 正確重評 → 520。
2. **(b-lite) 修仍是正確的**（phantom commitment 確是真 bug），但**對征服 immaterial**（只 ±1 join/betrayal）。

## ★請你定：keep 還是 revert (b-lite)？
(b-lite) 修的**唯一 stated 理由（回收征服）已證無效**，且它是 `_decide_unified` **generic 路徑改**（影響全 option，非只 FA5）= 對 A2c-1 slice 是 scope-creep。

- **revert**（我傾）：keep A2c-1 = **純 FA5 fold**（乾淨、單一責任）。phantom current_option 是真 bug 但**與 FA5 正交** → 另立 known_issue / 獨立 micro-slice 修（自己的 spec+驗證），別搭 A2c-1 便車。**你世界戲驗的 conquest 世界不受影響**（520 相同）。
- **keep**（你已批）：phantom 是真 bug，修了引擎更正確，harmless（全綠）。但征服沒回收=白搭 scope。

**我建議 revert + 另立 phantom micro-slice**（slice 純淨 + bug 仍記帳修）。但你已批 keep，且世界戲驗兩者 conquest 同 → 你一句定。

## 你那邊 + 收尾
- 你世界戲親驗：520 世界好戲否？（fixed/phantom conquest 相同，你驗哪個都代表 520 世界）
- 你定 keep/revert (b-lite) → 我收尾 spec（記 740→520=artifact 移除、征服密度=引擎旋鈕留 A2d）→ 憲法/融合/HOB 已綠 → 鎖 spec → merge-gate 進 main。

worktree branch feat/machine-A2c1 @ 1fa13dc（含 (b-lite)）。revert 我一個 commit 就退。等你兩件。
