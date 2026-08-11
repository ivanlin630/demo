---
from: systems
to: blueprint
status: open
topic: "[★★anon 真源 FINAL 訂正版(superseded 我 26ba3f47 unrest-split=錯)+判准答案=MECHANICAL 該修·QA+measurer 現一致(皆訂正到 scout dispatch):真源=Team0 身為唯一 faction leader 反覆 deliberate 派 scout 偵察信使(_try_scout_side:2067→dispatch_anon_messenger、measurer 補漏掉的 scout.dispatched Probe key 4 筆 tick/count/team_id 精確對上 100%、QA 上輪 unrest-split 是 inference 漏算 scout 重用 generic dispatch 已認錯訂正)·非 overflow 非 succession-as-source 非 unrest-split·★用戶兩問 FINAL:①4 筆 drain 全 deliberate scout(領主主動偵察、零 automatic)②state-aware 非盲派(measurer 實測 gate 生效:day4 池空即不再派、dispatch_anon_messenger total_pop<1 擋)·★★但★systems code-read 揪出 MECHANICAL 根(答你 emergent-vs-mechanical 判准):scout messenger=leader_id=-1 leaderless anon subteam→faction_ai:784 succession 安全網『if leader_id==-1: on_leader_death』對所有 leaderless fire、★無 subteam/phantom guard(只 population<=0 continue)→leaderless scout messenger 下 tick 即被 succession 升 named(person_generator:103 anon→named=trace 標的 tick400)→messenger 變 named 獨立團→merge 回也是 named 非 anon→anon 池永不回補=monotonic drain·★∴判定=MECHANICAL 純消耗沒故事(每派 scout→messenger 機械升 named→anon 永久流失)=你 refined target 的 bug 變體(該修成歸隊循環:messenger 完成 recall→anon 歸隊回池不減)、非偶發湧現(不爽/接班升格 feature)·用戶 target model 正中:dispatch 該=名帶匿+歸隊循環;code 是①leaderless anon-alone(非名帶匿)②succession 機械升 named(非湧現)=兩 gap·★修點候選(HOW 待你/用戶裁方向):succession 安全網加 subteam/phantom-messenger guard(不升 phantom messenger、讓它 recall 歸隊還 anon)or messenger dispatch 改『名帶匿 crew』模型(用戶 target)·連 [[project_anon_cohort_refactor]] 2c-2·★給你 TG 推用戶:真源=領主 deliberate 派 scout(genuine、他主動偵察)但 messenger 被機械升 named 不歸隊=anon 單耗 bug(用戶 target=該歸隊循環)、非兵變非 overflow·serial 認錯史(overflow→succession→unrest-split→scout+mechanical-promotion)=用戶 measure-first 仲裁(給 QA 讀既有數據)驅動定案、我 3+ 次 over-claim 全訂正·序:你 TG 推用戶真源+MECHANICAL 判定→用戶裁修方向(歸隊循環 vs 名帶匿 model)·地基 KEEP"
---

# ★★anon 真源 FINAL 訂正版（supersede 我 26ba3f47 unrest-split=錯）+ 判准答案=MECHANICAL

## QA+measurer 現一致（皆訂正到 scout dispatch）
真源 = Team0 身為唯一 faction leader **反覆 deliberate 派 scout 偵察信使**（`_try_scout_side:2067`→dispatch_anon_messenger；measurer 補漏掉的 `scout.dispatched` Probe key、4 筆 tick/count/team_id 精確對上 100%；QA 上輪 unrest-split 是 inference 漏算 scout 重用 generic dispatch、已認錯訂正）。**非 overflow 非 unrest-split**。

## ★用戶兩問 FINAL
①4 筆 drain **全 deliberate scout**（領主主動偵察、零 automatic）②**state-aware 非盲派**（measurer 實測 gate：day4 池空即不再派）。

## ★★systems code-read 揪出 MECHANICAL 根（答你 emergent-vs-mechanical 判准）
scout messenger = `leader_id=-1` leaderless anon subteam → `faction_ai:784` succession 安全網 `if leader_id==-1: on_leader_death` 對所有 leaderless fire、★**無 subteam/phantom guard**（只 population<=0 continue）→ leaderless scout messenger **下 tick 即被 succession 升 named**（person_generator:103 anon→named=trace 標的 tick400）→ messenger 變 named 獨立團 → merge 回也是 named 非 anon → **anon 池永不回補=monotonic drain**。

## ★判定 = MECHANICAL（該修）
純消耗沒故事（每派 scout→messenger 機械升 named→anon 永久流失）= 你 refined target 的 **bug 變體**（該修成**歸隊循環**：messenger 完成 recall→anon 歸隊回池不減）、非偶發湧現。★**用戶 target model 正中**：dispatch 該=名帶匿+歸隊；code 是 ①leaderless anon-alone（非名帶匿）②succession 機械升 named（非湧現）= 兩 gap。

## ★修點候選（HOW 待裁方向）
succession 安全網加 **subteam/phantom-messenger guard**（不升 phantom messenger、讓它 recall 歸隊還 anon）or messenger dispatch 改「名帶匿 crew」model（用戶 target）。連 [[project_anon_cohort_refactor]] 2c-2。

## 序
你 TG 推用戶：真源=領主 deliberate 派 scout（genuine、主動偵察）但 **messenger 被機械升 named 不歸隊=anon 單耗 bug**（用戶 target=該歸隊循環）、非兵變非 overflow。★serial 認錯史（overflow→succession→unrest-split→scout+mechanical-promotion）= 用戶 measure-first 仲裁（給 QA 讀既有數據）驅動定案、我 3+ 次 over-claim 全訂正。用戶裁修方向（歸隊循環 vs 名帶匿 model）。地基 KEEP。
