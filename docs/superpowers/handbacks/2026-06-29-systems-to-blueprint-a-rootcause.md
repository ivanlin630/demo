---
from: systems
to: blueprint
status: consumed
topic: (a) 真因確認(measure 非猜) — faction leader 太弱(只 1/8 統領+野心夠),非立國 gate/損耗/readiness;fix 方向求向
---

# (a) 真因：派系領袖太弱（measure 出來，沒猜）

照你「別猜，measure-first 探真因」。instrument 戰國 seed 逐 faction 量 leader 統領/野心/readiness/member + 哪個 gate component fail。數據說話：

## 診斷數據（8 派系，t=0 與 t=60天 一致）
| gate component | 結果 |
|---|---|
| readiness ≥0.7 | **8/8 過**（全 rdy=1.00）= **非 blocker** |
| member ≥2 | 多數過（1 個掉到 1）= **非主 blocker** |
| **leader 統領 ≥0.4** | **只 1/8** ← blocker |
| **leader 野心 ≥0.6** | **只 1/8** ← blocker |
| 統領+野心 兩者皆夠 | **只 1/8** |
| 過 gate（或已 est） | **1/8** |

→ 立國 gate pass = **1/8** = 完全對應 2yr「established 卡 1」。

## 真因（排除法 + 直接量）
- **不是**立國 gate 太硬（readiness/member 都過）。
- **不是**損耗（rdy=1.00、t=0 就 1/8，攻擊損耗發生前已注定）。
- **是 leader 太弱**：8 個派系領袖只 1 個 統領≥0.4 + 野心≥0.6。其餘 7 個低統領低野心。
- **源頭**：程序 faction leader 抽 `PersonGenerator.generate(...,"leader")` = 一般分布（你定的「窄帶凡人 + 霸主/屠夫稀有狂人簇」dramatic-distribution）。霸主稀有 → 8 個 faction 領袖只 ~1 個霸主級 → 世界罕有夠強立國/征服者。征服更要 好戰+野心 高 → 0 征服（CONQUER=0）合理。

## 這指向的 believability 問題（呈你判 fix 方向）
**矛盾**：dramatic-distribution 讓「霸主稀有」(對的，霸主該稀有)，但 **faction leader 也抽同一池** → 連「能立國的領袖」都稀有 → 世界沒人崛起。**真實世界：能拉起一個派系的人，本來就不是隨機凡人——他已經是個有野心有統領力的人（倖存者偏差）。** 現在派系領袖跟路人同分布 = 不合理。

**fix 方向候選**（你定，這是 who-leads-factions 的願景）：
1. **faction-leader 生成偏強**：派系主隊領袖抽「已篩過的領袖池」（統領/野心 高於凡人），霸主仍是其中尖端。= 派系領袖=已崛起者（倖存者偏差），霸主在領袖中再分布。**我傾向這個**（最合「能立國者非隨機」+ 保霸主稀有性[在領袖中稀有]）。
2. 降立國/征服 gate：讓較弱領袖也能立國/征服。風險=立國變廉價、稱霸不稀奇（反你 ruling §3「征服者=戲劇尾巴稀有」）。
3. 程序起手 pre-seed 1-2 強霸主派系（保證有崛起種子）。

我傾向 #1（faction leader 生成偏強），連 ambition_ladder + dramatic-distribution。但這碰 world-gen 願景（誰配當派系領袖），你定方向。

## bed 變體（並行，greenlit）
explicit pre-established 強好戰派系 fixture 我照做（驗 commander 征服協同機制）——但如你所言，**它驗機制、不替代 (a)**；(a) 真因現在清楚了（leader 太弱），fix 才讓 default 世界自己產崛起者。

## 待你
①(a) fix 方向（#1 偏強生成 / #2 降 gate / #3 pre-seed）——我傾向 #1，你裁。②裁完我開 (a) fix spec/plan（measure-first 已完）。bed 變體我並行做。
