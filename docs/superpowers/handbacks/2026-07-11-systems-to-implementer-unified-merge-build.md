---
from: systems
to: implementer
status: consumed
topic: [統一併入 開工] join+整併合一+分流+忠誠init——reviewer R② CLEAN,疊 @34034bb
---

# 實作工單：S-A 統一「併入」（reviewer R② CLEAN）

spec `specs/2026-07-10-consolidation-s-a-technical.md §HOW-6`（reviewer R② CLEAN，6 項逐一核過）。**疊既有 S-A worktree @34034bb**（前 S-A 修全 carry forward，別動）。

## 改（3 件，§HOW-6）
1. **join+整併 合成一個「併入」option**（`options.gd`）：取代 投靠+整併兩 REGISTRY row。
   - applicable：食壓<DESPERATION_DAYS AND 有可併 host（surplus host，gate#1）。
   - drive = 食壓 scaled（survival-class，同 join，`_trigger_survival` 派 @PRIO_SURVIVAL）；weight = 求生欲 + 好感 + (1-野心)。
   - to_task 回 host target + order_target（movement A re-track 已在）。
2. **resolve 分流軸**（接觸 resolver，疊既有容量軸）：host 願收（統領容量 + accept-util 單 util 比較）後：
   - `人少 + 好感高 + 低凝聚` → **dissolve** `merge_teams(host, joiner)`（現 join，已有）。
   - `人多 or 好感低 or 高凝聚` → **子隊-attach** `set_subteam_parent(joiner, host_id)` + **`set_team_faction(joiner, host.faction_id)`**（繼承 host faction，set_subteam_parent 不動 faction_id）。
   - 分流門檻（人數/好感/凝聚）= TEST VALUE。好感=`known_reputations[host]`±`relation_edges`；凝聚=`loyalty`。
3. **併入 set 起始忠誠**（補 loyalty 漏洞）：併入者對 host 起始 `loyalty` = f(好感, voluntary/coerced, 義氣)。脅迫/低好感→低（TEST VALUE，measurer 量叛離再調）。

## 驗（measurer，分流兩端 + 忠誠 + gate#1）
- **`merge_accept>0` 且 dissolve+子隊兩端都現**（★任一端=0→INCONCLUSIVE 標門檻失衡，回 systems 調）。
- gate#1 非搬餓（併進真 surplus host、含空真守衛）+ 隊數不崩塌（防 mega-blob）+ **忠誠初始化生效**（loyalty≠原隊、脅迫端低）+ 三 gate + churn + determinism。
- **大窗用 `godot-detach.ps1`+`WARRING_RESUME`（03b SOP）；worktree rebase 最新 main 拿新 bed。**

## 輕量 characterize（非 blocker，順手看）
`set_subteam_parent` 對**外來隊**：subteam 骨架 `:185/192/198` 歸建-duty 硬假設（parent==absorber=同源）→ 外來附庸子隊跑得順否（set 通 parent+faction+loyalty 即可，歸建-duty 完整處置歸 S-B）。跑不順標明回 systems。

merge 閘=reviewer 對實際 diff 再過一輪 CLEAN + measurer 全站。
