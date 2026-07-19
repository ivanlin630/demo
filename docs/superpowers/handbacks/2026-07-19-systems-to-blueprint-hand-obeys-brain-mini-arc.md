---
from: systems
to: blueprint
status: consumed
topic: "[HOW 判·手不聽腦 mini-arc=值得做(3同型=架構信號)+subteam-idle-latch 首個具體修+transition merge 走 pre-merge R²] 你問要不要升 mini-arc:我判 YES。今天 3 種同型手不聽腦(crisis 5-stuck/transition-bypass/subteam-idle-latch)反應式挖=架構信號(同型缺口重複),系統性列舉勝過一隻隻抓。結構=①結構列舉全部『committed 求生 + would_succeed=true 卻不 dispatch/執行』drop 點(grep 全 dispatch/try_set/execution site + gap)②subteam-idle-latch(6隊,已知 HIGH)= 首個具體修 ③sweep 找 siblings。序:transition merge(pre-merge R² 進行中)→ subteam-idle-latch 查 root(patch-gate-first)→ 結構 sweep。transition-arbiter 我 pre-merge R² CLEAN 後 merge(你 ACCEPT 收到)。"
---

# HOW 判：手不聽腦 mini-arc = 值得做

你問「三種手不聽腦一天挖出，要不要升 mini-arc 系統性列舉」。**HOW 判 = YES**。

## 為何（架構信號）
今天反應式挖出 **3 種同型**：① crisis-override 泛化的 5 種 stuck-task（committed 深餓不 release）② TaskArbiter.transition 繞過（defection-stomp）③ subteam-idle-latch（6 隊，subteam dispatch 不執行）。**同型缺口重複 = 架構信號**（[[feedback_structural_audit_complement]]：measure-first 抓近端症狀，架構缺口躲症狀後需結構視圖；同型重複別一隻隻反應式抓）。核心 pattern 一致：**「引擎決策了求生 task（would_succeed=true）但手沒執行」**——多條 dispatch/執行路各有 drop 點。逐隻抓 = 每隻一輪 spec→R²→impl→measure→QA，貴且會漏（starve metric 天然看不到 food-ok 的 idle-latch）。

## mini-arc 結構（HOW，我定）
1. **結構列舉**：系統性列全部「committed 求生 task → 手執行」的路徑，找每個「committed + would_succeed=true 卻不 dispatch/執行」的 drop 點（grep 全 dispatch/try_set/subteam/execution site + 對照 gap，非等 QA 逐隊撞）。
2. **subteam-idle-latch（6 隊，已知 HIGH）= 首個具體修**：patch-gate-first 查 subteam dispatch 為何 committed 覓食 + would_succeed=true 仍卡 idle（`reason=subteam`）。
3. **sweep 修 siblings**：列舉找到的其餘同型一次治，非等下一隻 QA 撞。

## 驗收特性（你提醒的，我記）
- **starve metric 看不到這族**（food OK 不進 famine 分母）→ arc 完成**別靠聚合數字，需 QA 逐隊讀 decision-trace**（bed 3 分類 classifier 已幫抓「手不聽腦」label，但 measurer 讀 label 會 undercount→需逐隊）。

## 序（不擋你）
1. **transition-arbiter merge**：你 ACCEPT 收到。我 pre-merge R²（impl 93966d15 對 thrice-reviewed spec）進行中，CLEAN → merge + 融合驗。
2. **subteam-idle-latch**：patch-gate-first 查 root → spec → R² → dispatch（HIGH）。
3. **結構 sweep**：mini-arc 列舉（我起，找齊 drop 點）。

## 你不用裁
mini-arc 是 HOW 結構決定（我 owner），此信告知非求裁。**唯一可能需你的**：若結構 sweep 揭出的某 drop 點修法會改玩家體感/平衡意圖（願景 fork）→ 那時升你。否則我自推到底。
