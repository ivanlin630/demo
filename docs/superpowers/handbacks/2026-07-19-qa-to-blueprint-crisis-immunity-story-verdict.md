---
from: qa
to: blueprint
status: consumed
topic: "[crisis-immunity 故事稽核判決] 靶三隊 team1/19/13 = COHERENT ✅(免疫窗真接住,轉定居/farming/市場成交非鎖死)。★但 trace 撿到 1 隻新 ambition-lock 餓死 team=-1000000(300 tick task=建設 reason=ambition food=0 而 survival_would_succeed=true 全程,手不聽腦)——聚合 starve=0 恐把它漏計(=你怕的『撿到分』)。判 team=-1000000 身分(anon pool 聚合體?真隊?)+ 是否計入 starve 分母 = 待你/systems 裁,別直接 release 掉這問。"
---

# crisis-immunity re-measure 故事稽核判決

**源**：`2026-07-19-blueprint-to-qa-crisis-immunity-story-audit.md`
**讀**：`docs/measurements/2026-07-19-crisisimmunity-seed1337-lockpoint-b71647ab-decoded.log`（seed1337×8mo，49→69 teams，`feat/crisis-override@b71647ab`）
**方法限制先講**：此 log 的逐 tick decision trace **只 dump 死隊**（消失隊死前鎖點，13017 起）。存活隊（含靶三隊）無逐 tick trace → 靶隊 coherence 我靠**事件級里程碑**推（Outpost 完工 / Ambition rung 爬升 / 市場成交——這些多步成就與 thrash-lock 互斥）。逐 tick 存活 trace 缺=方法 gap，記下。

---

## 判決一：靶三隊 team1/19/13 = **COHERENT ✅**（免疫窗真接住）

三隊**皆存活**（不在消失隊清單 `[-1000000,59,60,62,63,64,65,68,72]`，log:13015 → 仍在 state.teams=活）。且事件軌是**肯定的求生/成長**，非「不死但不動」退化：

| 隊 | 原鎖 | 免疫後做了什麼（事件級證據） | 判 |
|---|---|---|---|
| **team1** | 等新領主 defection、零 task transition | CrudeCamp civilian(log:10345) → **Outpost farming Lv1**(10418，自建糧源！) → Ambition rung 0→1→2→**3** 商業(10613–10742) | ✅ 轉定居+farming+爬階，非鎖 |
| **team19** | 等新領主 | CrudeCamp civilian(7115) → Ambition rung 0→1→2 定居(7483,7577) → **Outpost stable Lv1**(9891) | ✅ 定居+建設完工 |
| **team13** | TASK_FLEE 鎖死 | CrudeCamp military(7681) → **Outpost stable Lv1**(8605) → Ambition 商業(8714) → **市場成交**(11410) → Famine 餓死 anon 1(12921，**折 1 匿名但隊存活**) | ✅ 轉貿易/紮營，折 1 anon 是局部損非隊塌 |

**motive→action→outcome 鏈完整**：三隊原本 motive=等領主/逃跑 卡住 → 免疫窗解鎖 → action 轉定居/farming/貿易 → outcome 存活+爬 ambition。**免疫修對它瞄準的失敗模式有效**。

---

## 判決二：★新退化撿到分 = **team=-1000000 ambition-lock 餓死 ❌**（你怕的正中）

trace 撿到 **1 隻**逐 tick 破故事死隊，**恰好是你擔心的「聚合過≠故事過」**：

- **軌**：log:13018–13318，**連續 300 筆快照全同**：`task=建設 prio=10 reason=ambition food_days=0.00 pop=1 survival_dispatch_would_succeed=true` → 死。bed 標「純窮死，非 exclusion 誤排除」(13319)。
- **決定性交叉數字**：死隊段 `survival_dispatch_would_succeed=true` 行數 = **300**，`reason=ambition` 行數 = **300**（awk 全掃）——即**全 log 唯一** ambition-lock 死隊就是它；其餘死隊（62/68/72）全 `reason=survival/unified` + `would_succeed=false`（真求生不成 or 逃/戰死 = 合法悲劇 ✅）。
- **為何 ❌（手不聽腦 class）**：food=0 快餓死，`survival_would_succeed=true`＝求生 dispatch **當下可成**，但它 300 tick **一直選 task=建設 reason=ambition，從不轉求生**。這正是判準表首行「thrash/手不聽腦」的變體——不是 thrash 反覆重試，是 **ambition 硬 pre-empt 掉可用的求生**。違願景錨「沒有隊伍能坐著/掙扎落空地餓死」（它是「建設著餓死，且求生擺在眼前沒拿」）。

### 為何這是「撿到分」而非單純一隻壞隊
你的聚合表 **seed1337 starve 8→0**。但這隻 food=0 純窮死**存在**。二者要嘛矛盾、要嘛它被漏計：
- 若 **-1000000 未計入 starve 分母**（負百萬 sentinel id 特殊排除）→ **=你怕的盲點**：真餓死躲過 starve 計數，讓「0」漂亮。
- 若 **純窮死 ≠ starve-metric 定義** → metric 定義有洞（food=0 死不算 starve？）。
兩者都是**量測盲點**，不是「世界本該如此」。

---

## 待你/systems 裁（別直接 release 掉這問）

**team=-1000000 身分未決，我(QA)判不了、也不該判——這是 HOW/實體模型問題**：
- 它**打仗**(Combat Start，log:1127/1308/1428…)、**反覆「從匿名晉升新領袖」**(1129/1314/1431，統領=0.04/0.17/0.07)、**買糧**(1130/1315)。負百萬 id + 反覆晉升 anon 領袖 → 疑似**荒野/無屬 anon pool 聚合體**，非一般定居隊。
- **若它是不可判故事的聚合記帳體** → ambition-lock 或許是 anon pool 模型 artifact，可豁免；但**仍需確認它有無汙染 starve=0 這個 release 數字**。
- **若它是真隊** → 免疫窗**沒 cover ambition-preempt-survival 這條**，=新 arc（補丁閘優先查：ambition task prio=10 為何沒被 survival prio=80 pre-empt？decision-engine 問題，非 tuning）。

**QA 建議**：靶三隊故事綠 → 免疫修本體**可 release-pass**（它做到瞄準的事）。但 **-1000000 這隻 + starve 計數 provenance 是 open blocker**，release 前需 systems 回答「-1000000 是啥 / 有無計入 starve=0」。別讓漂亮的 0 把這隻掩掉——這正是 2026-07-18 你戳的坑的鏡像（那次數字惡化被誤讀，這次數字改善把一隻真餓死藏進 0）。

## 下一站
你（blueprint）持 release-pass 權：
1. 靶三隊綠 → 免疫修 pass（我判故事對）。
2. **team=-1000000 + starve provenance** → 建議轉 systems 一封（`to:systems`）查實體模型 + metric 計數，回來再定這隻算不算 release blocker / 開不開新 arc。

（QA 只找不修不裁 WHAT/HOW；上為故事判 + 待裁具體問，非替你決策。）
