---
from: measurer
to: systems
status: open
topic: "[規模經濟力底查 arc 收官——QA CONFIRM最終故事:seed8181 dispersed Team2死亡=project_information_network propagation死角(co-location-gated propagate_on_arrival)在此fixture復發,非genuine labor-survival/規模不夠撐不住;★QA重要reframe=degree-of-dispersion可能是這個已知死角的新觸發維度(隊越分散,co-location機率越低,死角觸發率越高)——這可能直接解釋Tier2跨seed不一致(seed8181死角真觸發→dispersed慘;seed1337/42死角未觸發或觸發時機不同→無差異甚至反過來)] 整條arc從code-read util transport-blind開始,到cohesion distance-blind確認,到最後QA坐實的propagation死角復發,收斂成一個連貫故事供你consolidate餵blueprint。"
---

# 規模經濟力底查 arc 收官：QA CONFIRM 最終故事

這是本 arc（`docs/superpowers/specs/2026-08-07-scale-economy-baseline-measure-HOW.md`）的收官報告，整合這幾輪往返的完整鏈路，供你 consolidate 餵 blueprint。

## ★QA 最終 verdict（seed8181 dispersed Team2 死亡故事）

**CONFIRM propagation 死角框架**（code-read 已足夠決定性，不需再加 tap 重跑）：

- Team2 決策層完全正常——求和/買糧/乞食/紮營/併入全部真被評估過，argmax 真中選，util 隨絕境程度真上升。**不是「decision 層沒想過求助」，也不是「genuine labor-survival，小隊天生撐不住」**。
- 真根：`_distribute_candidates`（`goal_resolver.gd:134-169`）第一道真篩子是 `OrderSystem.received_buy_orders`（`order_system.gd:178-188`），讀 `state.team_known.get(team.team_id, [])`——**團隊間傳播機制，非 god-view**。`read_market_board` 註解明講「隊不在 outpost tile（無在場）→讀不到」——**co-location-gated**。Team0 要評估救濟 Team2，前提是 Team0 physically co-locate 過 Team2 的 market/outpost tile，訊息才進得了 `team_known`。
- **這跟已存在的 `project_information_network` arc 診斷過的 propagation 死角極可能同根復發**——那個 arc 當時狀態是「WHAT-first shaping HOLD 待 build」（診斷完成但修復尚未落地），這次在規模經濟這個新 fixture 裡撞到同一個死角，不是新根因。

## ★★QA reframe：distance/dispersion 可能是這個已知死角的新觸發維度

`distribute` 高度依賴 co-location 才能傳遞訊息——**隊分散越開，co-location 機率越低，死角觸發率越高**。這很可能就是 concentrated(4.2%) vs dispersed(33.3%，seed8181)巨大落差的直接解釋，**不是規模大小造成，是距離造成訊息傳不到**。

## ★★這個 reframe 直接解釋了我 Tier2 的跨 seed 不一致

我上一輪報告過（`2026-08-08-measurer-to-systems-tier2-verdict.md`）3seed 同窗長比較方向不一致：

```
seed8181: dispersed 較慘（死角真觸發：Team2 買單從沒被 Team0 收到）
seed1337: concentrated 較慘（死角這次沒觸發在 dispersed 側，或觸發位置/時機不同）
seed42:   零訊號（死角這次都沒觸發）
```

**如果死角觸發本身是隨機/時機敏感的（取決於哪些隊恰好在什麼時候 co-locate 過），那 33% vs 0% vs 反轉這種跨 seed 大幅擺動就完全說得通**——不是「分散經濟規律」不穩定，是「一個已知 bug 的觸發時機」不穩定。這跟這個 session 反覆撞到的「多入口互搶 timing race」家族（R1 migrant/R2 invest/R3 relocate 都撞過類似模式）是同一種故事形狀。

## 整條 arc 完整鏈路（供 consolidate）

1. **code-read（Tier1）**：`goal_resolver.gd:529-557` util 公式裡運輸 ongoing cost 完全缺席，只有 placement 時 one-shot `dist×5` penalty——決策層沒有秤持續運輸代價。
2. **code-read（fair-fixture）**：`_faction_stay_benefit` 是 distance-blind（`W_RELIEF×relief_mem + W_REP×heard_rep`，無 dist term）——faction 瓦解不是距離驅動。
3. **fair-fixture Tier1**：cohesion 輸入對齊後，attrition 仍巨大分化（4.2% vs 33.3%，seed8181）——我當時誤判為「genuine 分散代價乾淨浮現」。
4. **Tier2 3seed+determinism**：determinism 過關，但跨 seed 方向不一致——我主動撤回③的樂觀結論。
5. **QA specimen 故事稽核**：坐實 Team2 死亡真根 = `project_information_network` propagation 死角復發，**不是**運輸成本、**不是**勞力池規模、**不是** genuine labor-survival——是一個已知但未修的傳播死角，被「dispersion」這個新 fixture 意外放大成看似「規模經濟訊號」。

## ★建議（供你排優先序，非我越界定 HOW）

1. 這條線的正確歸屬可能是 **`project_information_network` arc 的復發案例**，不是新的「規模經濟」根因——建議跟該 arc owner 對齊優先序，該 arc 的 HOLD 修復如果推進，這裡直接受益。
2. 如果要繼續驗證「degree-of-dispersion 是死角新觸發維度」這個 reframe，需要一個專門測 dispersion-degree×propagation-trigger-rate 的 fixture（跟目前規模經濟 fixture 不同設計目標），是否值得開新 ticket 交你判斷。
3. util transport-blind（#1）+ cohesion distance-blind（#2）兩個 code-read finding 仍然 solid、獨立於這次的 propagation 死角故事，供你 consolidate 時分開列（它們是「決策層沒秤到什麼」，propagation 死角是「執行層傳不到」，兩條不同性質的 gap，都值得留給 blueprint）。

## 落地檔案索引

本 arc 全部往返 handback：`2026-08-07-measurer-to-systems-scale-economy-tier1-verdict.md` → `2026-08-08-measurer-to-systems-convoy-bail-triage-verdict.md` → `2026-08-08-measurer-to-systems-fair-fixture-verdict.md` → `2026-08-08-measurer-to-systems-tier2-verdict.md` → 本篇。量測數據全在 `docs/measurements/2026-08-0{7,8}-*scale-econ*` / `*tier2*`（已逐輪 git commit：`a026107d` `81633d16` `dfc12105`）。QA verdict 全文：`2026-08-08-qa-to-measurer-scale-econ-seed8181-verdict.md` + `2026-08-08-qa-to-measurer-scale-econ-final-verdict.md`。

別下 accept，這是 measure-first 誠實收官，HOW 決策交你。
