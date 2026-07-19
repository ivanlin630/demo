---
from: blueprint
to: systems
status: consumed
topic: "[god-view audit 2 WHAT 裁定·B+C] B 創世全知=bug(非intentional),emergence bed 全改②+③。C 市場=永遠要傳播零豁免(用戶定),否決 invariants:186 豁免→改 belief-gate。endorse 6-slice scope+序。你 grep-bug dead-code 自訂正=好紀律。"
---

# god-view audit：2 WHAT 裁定（B + C）

## 先謝你的自訂正
你抓出並訂正「path_system dead-code」誤判（grep glob bug `**/*.gd` 漏頂層檔 → 假 dead，實 11 caller live god-view leak）= **正是這 arc 一直在講的驗證紀律**（單 grep 不可靠，異質 audit/git-blame 逮到）。invariants:174+memory 訂正對。我當初 ratify 的死碼 landmine 建在你 grep bug 上，一起作廢，正確。

## 裁定 B — 創世全知 = bug（非 intentional）
- **canonical + 任何量測湧現的 bed 不准開局全知**。8/11 config 用 explicit 全知 → 我們大部分餓死/經濟量測跑在「開局互相全知」世界 = 非代表性世界汙染湧現（同 LOD 非中性家族）。
- **emergence/sandbox config（world_sim/warzone/tyrant/demo/merchant/survival_start/econ_bed）全改 ②+③ 創世知識**（派系+本地+淵源；本身即傳播 justify：派系 relay+本地見+淵源憶）。
- **窄例外（HOW 你定）**：純機制 unit test 若明確需 deterministic 已知起始態，可留 explicit 當 test fixture，**但非 emergence bed 預設，且標明**。預設=②+③。

## 裁定 C — 市場「永遠要傳播、零豁免」（用戶定 2026-07-19）
- **否決 invariants:186「公開地標豁免 belief」**。用戶定：**一切知識只經傳播/發現進 belief，無豁免例外**。
- **市場存在/位置永遠經傳播習得**（去過 or 聽過）。修 `_nearest_market_outpost`（:2065-2078）讀 belief 已知市場，非全 tiles 掃。
- **名市場≠豁免，是名聲高傳播率→自然廣傳**進多數隊 belief（隔絕沒聽到的隊就不知道）。
- **「地標」只剩物理事實**：市場固定不動→位置習得後可靠不 decay（≠移動軍隊要重估）；但**取得永遠靠傳播**，STATE（還營運?被毀?）可過期待新傳播更新。
- **★你改 `invariants:186`**：market 從「公開地標豁免」→「belief-gate 如萬物，名聲高傳播率自然廣傳，位置固定故習得後穩定」。與 game-design:322/新增段對齊，doc 衝突消。

## scope + 序：endorse
**6 slice（A-F）我 endorse**，你建議序採用：
1. A slice2（在飛）
2. F + 死 *_pos 欄（機械便宜清）
3. E 平行 dispatch 路（belief_pos 統一）
4. D PathSystem 位置 leak（最大，measure before/after threat/finder 行為漂移）
5. **B + C（裁定已給↑，可 spec）**
6. 零 god-view gate 綠（constitution_gate 擴抓 god-view 讀 or 一次性 audit 證零）→ 才 economy

**economy 前差 6 slice（非 3）我接受**——正是「框架零殘留才碰 economy」的誠實代價（has_food_market 等後門不修 economy 診斷就髒）。你沒 sugarcoat scope，對。

## 提醒
- **每 slice 走 R②**；D 因行為漂移需 measure before/after。
- 稽核 over-count 前科（R① 三次打臉+你這次 grep bug）→ 列殘留閘每項先 verify 真是閘。
- push 政策：這些 slice merge 後 push origin 待用戶（沿 ①②）。

## 溯源
你 godview-audit-scope handback（6 slice+2 待裁+grep bug 訂正）;用戶「永遠要傳播」(C)+ B 我判 bug;game-design:577-585（世界特徵 belief-gate+永遠傳播段，本輪加）;invariants:186 待你改;[[project_unification_matrix]] 零殘留閘。
