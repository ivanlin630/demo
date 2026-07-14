---
from: measurer
to: blueprint
status: consumed
topic: "[量測完] execlock@200d7e49——Team20可解釋jsonl重跑done(缺口①②有料);團滅specimen未如願:4隊試探皆非乾淨案例,Team18意外揭bed死亡誤判+疑似真bug(卡限迴圈不死不活)"
---

# execlock 可解釋 specimen 重跑報告

`measured_at_head: 200d7e49`（branch，交易+威脅 tap 已含）。全數字 raw log 見 `docs/measurements/2026-07-14-execlock-fullhd-*-200d7e49.log` 系列。

## 一次量完（鐵律6）

## 1. ★Team20 可解釋 jsonl：完成
`docs/measurements/2026-07-14-execlock-seed1337-Team20-explainable.jsonl`（331 entries，與先前一致，重跑確認 deterministic）。現含 QA 要的兩缺口料：
- **缺口①**（交易執行）：`active_buy_food_qty`/`orders`/`at_market` 每 entry 皆有。
- **缺口②**（威脅來源）：「想什麼」block 含 `threat_id`/`threat_pos`/`threat_react`。
QA 可直接複判。

## 2. 團滅 specimen：★未達成乾淨案例——試 4 隊，意外發現 bed 死亡判定 false positive
方法：seed1337 full-HD，逐隊試探死活 + decision_count（非侵入化後可安全逐隊試，換 id 不換世界）：

| team_id | 結果 |
|---|---|
| 14 | 存活至尾=false 死tick=9599，但 **decision_count=0**（trace 全空，無料可看，非本刀路徑） |
| 17 | 存活至尾=true（不死），decision_count=3（太薄） |
| 20 | 存活至尾=true（不死）——已用（掙扎-恢復故事） |
| 18 | bed 判「存活至尾=false 死tick=7239」，**但 jsonl 逐筆核對後發現這是 false positive** |

**Team18 詳查**（`docs/measurements/2026-07-14-execlock-seed1337-Team18-annihilated.jsonl`，34 entries）：tick 逐筆列出後，team18 在 tick=7239（bed 誤判死亡點）**前後皆持續出現**、pop 全程=1，一路到 trace 最後一筆 **tick=15130（day63）仍 pop=1 存活**——bed 的死亡偵測（`elif spec_death_tick==-1 and not spec_last.is_empty(): spec_death_tick=tick`，只認「這 tick state.teams 查無此 id」）在 tick7239 附近可能因某次瞬間移除-重加入（trace 首兩筆正是「併入/投靠」嘗試，猜測與此有關）誤判為永久死亡，**實際上隊伍沒死透**。

**但這隊本身的故事仍值得报給 QA/blueprint**（非空手而歸）：
- tick7110/7120：連兩次「併入→投靠」嘗試（真掙扎，想找人收留）。
- tick7690 起：轉「買糧」(貿易 task)，**此後連續至少 31 天(27+筆,每日一次)coin=0 food=0 卡在同一迴圈**，intent 卻標「致富/貪婪驅動」——**★疑似不連貫**：明明零錢零糧的孤隊，AI 記錄的「想什麼」寫著追逐財富(致富/貪婪)而非求生恐慌，且**該隊該死不死**（一個月+零食物理論上該餓死，卻卡在 limbo 不死不活到trace結束）。這可能是（a）本刀外的另一個 bug（lone-survivor 子隊的死亡/求生判定被此買糧-貿易path繞過，沒接回 survival controller）或（b）intent 標記邏輯的既有缺陷（非本輪範圍，僅報現象）。

## 下游判給 QA/blueprint
1. **QA**：Team20 explainable jsonl 可直接複判缺口①②。
2. **blueprint**：團滅 specimen 本輪未達成乾淨案例——Team18 的「假死+卡限迴圈不死不活+intent誤標」是意外發現，值得列入 known_issues 或另立 follow-up 查（非本次thrash-fix範圍，是lone-survivor子隊/貿易path/死亡判定的另一個潛在缺口）。若仍需乾淨的「死透」specimen，需要另一輪嘗試（本輪已試4隊，用盡快速候選；下一輪建議先用 `single_team_trace_bed.gd` 式 pop_history 掃描找真正 pop→0 移除的隊，而非逐隊猜）。
3. `reeval_attribution_bed.gd` 死亡偵測邏輯（`elif` 單次查無即判死）有 false-positive 風險——**觀察回報，非本刀修復範圍**，供 systems 判斷是否值得小修（L3 surgical：改成連續 N tick 查無才判死，或直接讀 population==0 事件而非 dict-membership 瞬態）。

## 不回歸
沿用先前全-HD acceptance 閘（determinism/憲法/sanity），本輪未動核心 code，僅重跑觀測，無需重驗。

---
measured_at_head: 200d7e49
