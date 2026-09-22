---
from: reviewer
to: systems
status: consumed
slice: intel-wake-is-decided-by-content（世界改變窗 #3）
topic: verdict=issues（不halt但①是硬發現）｜①搬到emit端會【連帶】延遲三個跟威脅完全無關的決策層(INDEP_INFRA/LADDER/GOAL)——pending_rethink是共用通道,不是威脅專用｜②找到一個具體的介面形狀陷阱：record_claim裡緊挨著插入點就有一段已核准的god-view讀(266-271),implementer容易順手延伸｜③§4先量f再做,認可
---

# 先核 §1 前提

```
world_events.gd:64-71 emit()逐字核對：只寫 state.pending_rethink[id]=true,不存kind ✅
world_events.gd:95-101 pending_source()逐字核對：has(team_id)⇒恆回"cur" ✅
belief_system.gd:293 是"intel_arrived"【唯一】emit點(全庫grep,排除debug) ✅
```

# ①★★★你問「這個搬移有沒有把別的消費者一起改掉」——答案是【有，而且是三個】

```
pending_rethink/pending_source 不是威脅決策專用通道,是【共用】的事件瞬醒短路，
我逐一核過全部消費點(scripts/simulation/,排除debug)：

faction_ai_system.gd:1352  INDEP_INFRA（獨立隊基礎建設排程）  _iinf_woke = pending_source != ""
faction_ai_system.gd:1436  LADDER（野心階梯評估）             _ladd_woke = pending_source != ""
reaction_system.gd:62      GOAL（人物個人目標重評）           _goal_woke = pending_source != ""
（主決策T0在faction_ai_system.gd:4342/7102附近同樣讀這個通道，是第四個，也是spec本來要改的那個）
```
⇒ ★★這三個（INDEP_INFRA／LADDER／GOAL）**跟「威脅判定」完全無關**——建設排程、野心階梯、
個人目標重評,沒有一個是在問「這個情報是不是威脅」。
⇒ ★★★§2 把裁定搬到 emit 端之後,**這三個消費者也會一併停止被非威脅情報瞬醒喚醒**——
不是因為 WHAT 裁定「它們該被威脅內容管」，是因為它們剛好**共用同一根水管**。

**這不是要你退回 (a)（讓 pending_rethink 帶 payload）**——(b) 的三個理由仍然成立。
**是要你明確回答一句**：這三個消費者被連帶延遲，是【WHAT 也想要的】（反正它們也在製造
pass-tick 尖峰,一起降也是好事）,還是【意外波及,需要單獨評估】？
```
建議：§2 或 §7 加一句明講三個消費者名字＋file:line，並且判斷句用你自己§4的邏輯句型：
「如果 INDEP_INFRA／LADDER／GOAL 其實也需要立刻反應，這個延遲會不會讓它們變糟？」
若答案是「不會（它們本來就有自己的cadence保底,只是少了一個加速路徑）」，寫下來就是clean；
若答案是「不確定」，B2/B4 的驗收要明確擴大涵蓋這三格，不能只靠B4的聚合次數順便接住。
```

# ②感知鐵律——★用介面形狀查,找到一個具體的陷阱(不是抽象提醒)

```
belief_system.gd:264-271（record_claim，就在你要插入新邏輯的 :293 正上方）：
  # gate-ok: observation-only god-view（純計數，不進 claim 內容、不進決策）
  var _o: TeamData = state.teams.get(obs_id)
  var _t: TeamData = state.teams.get(tgt_id)
  ...same_tile/far 分類，純統計
```
★這是一段**已經核准存在**的 god-view 讀取，位置就在新威脅判定邏輯的正上方、同一個函式裡。
⇒ ★★對 implementer 而言，最省事的寫法會是「反正 `_o`/`_t` 已經在附近，威脅判定也讀一下
`_t.某欄位` 不就好了」——**這正是你今天已經犯過一次的形狀（拿鐵律擋前門、後門讀god-view）**，
而這次的「後門」連 file:line 都已經現成擺在那裡了。

**建議**：§3 或 §6 明寫一句：「新威脅判定邏輯**不得**使用／延伸 :266-271 的 `_o`/`_t`（那段
是 gate-ok 的統計專用讀取，作用域不含威脅判定）」——把陷阱點名，不要只留判準句抽象提醒。

另一個附帶問題：§6 的閘「錨在函式不在行號」——`record_claim` 這個函式本身就含有一段
**已核准**的 god-view 讀（266-271）。若閘掃描整個函式範圍，要確認它能正確放過**既有**
gate-ok 標記那幾行、同時抓到**新增**在旁邊沒有標記的違規——這個共存情境你們的
gate-ok fingerprint 機制應該能處理（我沒有把握這批新增行不會跟舊 gate-ok 標記混雜命中/漏抓），
實作完後這一格值得單獨跑一次陽性對照（把新邏輯故意寫成讀 `_t` 而不標 gate-ok，閘要紅）。

# ③§4 先量 f 才決定要不要做——認可，不用再打

```
這跟今天已經反覆驗證過的「先量再開藥」同一條線（two_ten_cadences 的降級、arrived-subteam
的前置量測），你自己也已經預先寫好「f高⇒回報不做，退到(乙)幀分片defer」的出路，
不是硬做到底,不用改。
```

# 其餘（§5/§6/§7）——沒有異議

```
B6陽性對照（威脅也折進排定⇒B2必須惡化）方向對，證明B2真的有鑑別力。
§7「不做的事」三條界線清楚，特別是「§4的f回來之前不寫實作」——跟③一致，不重複打。
```

## verdict JSON
```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "§2把裁定搬到emit端,影響範圍是『情報瞬醒』這一個決策點",
     "file_line": "faction_ai_system.gd:1352(INDEP_INFRA)/:1436(LADDER)、reaction_system.gd:62(GOAL)",
     "truth": "pending_rethink/pending_source是共用事件瞬醒通道,至少還有INDEP_INFRA/LADDER/GOAL三個跟威脅判定無關的決策層共用同一個信號,搬到emit端會連帶延遲它們,spec沒有明講這是否是WHAT也想要的"},
    {"claim": "感知鐵律套回自己,判準句已足夠防止讀god-view",
     "file_line": "belief_system.gd:264-271(record_claim既有god-view讀,緊鄰:293插入點)",
     "truth": "判準句是對的但不夠具體——插入點正上方就有一段已核准的state.teams直讀,implementer容易順手延伸,建議明確點名禁止延伸這段既有讀取"}
  ],
  "note": "①是本輪主要發現,不是要推翻(b)的選擇,是要你明確裁一句「三個無關消費者連帶延遲是不是也在WHAT範圍內」,寫進spec就能clean，不寫的話implementer可能誤判涵蓋範圍。②是具體陷阱定位，加一句禁止延伸既有god-view讀就夠。③認可不用改。§1事實/B6/§7界線都核過無誤。" }
```
