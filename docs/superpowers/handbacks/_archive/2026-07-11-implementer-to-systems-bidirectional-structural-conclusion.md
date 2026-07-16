---
from: implementer
to: systems
status: consumed
topic: [雙向都試完=真結構結論→升 user a/b/c] 弱不能併(survival鎖)+強不願吸(寧征服)→consolidation 非此世界 emergent
---

# §HOW-7 done + 雙向結論：team consolidation 非此世界的 emergent 行為 → 升 user 願景 fork

§HOW-7 強方 pull「吸納」實作完整（@41e882c）+ 全驗綠（parse/bed fail=0/sanity inv=0/constitution/determinism IDENTICAL）。**功能正確**。但 absorb.dispatch=0。加 finder 診斷 → **雙向結構結論齊**。

## §HOW-7 做了什麼
- 新「吸納」option（擴張-class @PRIO_DISPATCH，繞開 survival 鎖）+ capacity-bound finder（`_find_absorb_target`，reviewer 點的容量檢查真加）+ absorb_drive（野心×base）+ 抽共用 `_resolve_mergein`（弱push/強pull 皆呼=真統一分流）+ TASK_MERGE resolver 移出 same_faction（跨勢力吸）。

## 鐵證：吸納 finder 有效但恆輸 rank（非 bug，是 emergent）
| 探針 | 數 | 判讀 |
|---|---|---|
| `absorb.target_found` | **9383** | finder 有效——capacity-bound 弱鄰**大量存在**（強隊到處有可吸弱鄰） |
| `absorb.dispatch` | **0** | 吸納**恆輸 rank** |
| `conq.intent` | 597 | 強隊選征服/攻擊 |

- 吸納 applicable 頻繁（9383）但 **completion=0**：absorb_drive(≈1.2×野心×weight≈0.4) 恆輸 攻擊(faction_duty 1.5+…)/佔村(1.2)/征服。
- **per 工單守則「公平競秤不硬保，軍閥寧可征服也合理」=legitimate emergent**：強隊有更好選擇（征服掠奪奪產），寧可打也不和平吸納。**這是正確行為，非 bug**。

## ★雙向結構結論（決策樹終點）
7 層修 + 統一併入 + 雙向（弱 push / 強 pull）全試遍，consolidation completion 恆 ~0：
| 方向 | 機制 | 為何 ~0 | 性質 |
|---|---|---|---|
| 弱方 push | 併入(survival-class) | 絕境隊 survival-locked、罕勝 survival rank、到達 churn | 弱**不能**併 |
| 強方 pull | 吸納(擴張-class) | 公平競秤輸 conquest（軍閥寧征服） | 強**不願**吸 |

**兩端各自 sound emergent**：弱隊活不下去只能逃/散（survival 主導），強隊要擴張寧可武力征服（收益高）。**和平 team consolidation 不是這世界的 emergent 行為**——結構（絕境小隊 + 征服收益 > 和平吸納）天生排斥它。

## → 升 user 願景 fork（我不能單方裁，systems 決策樹定的終點）
systems C2/HOW-7 決策樹：「absorb 也 marginal → 雙向都試過=真結構結論 → 升 user a/b/c」。**現在到了**。核心 user 問題：**和平 consolidation 非此世界 emergent，接受哪條？**
- **(a) 接受 ~0 = 罕見 flavor**：機制全備（併入/吸納/分流/loyalty），volume 隨世界湧現（現況幾乎不發生）。不強求。**最小改動、誠實**。
- **(b) 改世界動力**：讓 consolidation 有利可圖（降征服收益 or 給和平吸納 rank 優勢）——但這是 flat 病（工單禁）、且傷 combat/征服平衡。**大改高風險**。
- **(c) 退役 consolidation 野望**：承認小-絕境隊 + 征服世界結構下，consolidation 非 emergent。移除 S-A 機制（併入/吸納），保留既有 join-flavor（個人絕境投靠 dissolve，已在）。**承認結構事實**。

## 現況
- worktree @41e882c：§HOW-1~7 全 + 三 movement 修 + 統一併入 + 吸納 + 分流 + loyalty + guard + 完整雙向漏斗探針。**gates/determinism 全綠、實作零 bug**。
- consolidation completion ~0 = **世界結構**非 code。
- 建議：**先 measurer big-window 確認**（03b detach+resume，非 3mo 單 seed）雙向仍 ~0 → **升 user 裁 (a)/(b)/(c)**。

框外總終結（8 站扒到底 + 雙向）：order_target→combat早退→movement A/居民鎖→priority C1/C2→統一併入(weight 變體)→吸納(強pull)。每站真修真 bug，實作全對，但頂層是**世界結構事實**：這世界弱隊不能併、強隊不願吸。**這是 user 願景裁決，非工程問題。**
