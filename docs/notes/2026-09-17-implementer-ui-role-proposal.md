# 提案：加一個 `implementer-ui` 角色（不是第二個 implementer）

status: NOTE（影子藍圖提案；用戶傾向加，待正藍圖／systems 討論後核可——工作流改動走「先討論後核可」）
from: 影子 blueprint session（不發信、不寫 memory）
to: 正藍圖（WHAT：要不要）→ systems（HOW：角色格／doc／seam）
date: 2026-09-17
承接: `2026-09-08-player-surface-and-agent-selfcheck.md`（玩家端總案）、`2026-09-17-systems-to-blueprint-facts-yes-etas-not-mine.md`（systems：戰爭線收尾後 implementer 轉 UI）

---

## §1 問題
- 用戶今天全線停工去玩遊戲——**玩不到**是專案最大的洞：UI 最後實質更新 2026-07-13、agent REPL 2026-06-02；三個月的機制（市場板／寄賣／薪資／貨幣／belief 四源、以及本週裁的票／恩怨／立國）沒一樣進玩家面。
- 引擎線永遠有下一張票，UI 永遠「收尾後再說」。systems 剛回的序也是「戰爭線收尾後 implementer 主力轉 UI」——這是**串行**，UI 等引擎。

## §2 為什麼不是「第二個 implementer」
1. 同角色雙 session ＝ 非法（用戶立）：信箱按角色定址，兩個收件人＝歧義；watcher 互搶。
2. 瓶頸不在實作手數：今天卡的是配額，平時卡的是 reviewer／量測／QA 吞吐。多一個同型實作＝下游排更長；配額共用，session 多 ≠ quota 多。
3. 現況 7 個 worktree 在飛（arbtap／bedkind／gatherpure／minors／payroll／turnover／wagepen），不缺產出，缺收口。

## §3 為什麼是 `implementer-ui`
- **不同角色名** ⇒ 信箱不歧義、自己的 doc 格、自己的 worktree。
- **幾乎不撞檔**：owner 範圍 `scripts/ui/*`、`scripts/debug/agent_repl.gd`、`scripts/simulation/player_command_api.gd`／`player_query_api.gd`／`player_api_mapper.gd`。與引擎 slice 唯一的縫＝api 層（mapper 讀引擎狀態）——用既有 seam gate 管，引擎改了資料形狀要寄 seam 信給 ui。
- **可平行**：引擎線照跑，UI 線同時追上三個月落差。
- 對齊 9/08 總案的順序：①復活 agent 入口＋市場四件套 → ②`player_reachable` 義務 → ③記憶框五分頁 → ④附身選擇 → ⑤時間控制。

## §4 角色定義（草案，systems 定稿）
| 欄 | 內容 |
|---|---|
| 名 | `implementer-ui`（`SESSION_ROLE='implementer-ui'`） |
| 管 | 玩家面（GUI＋agent REPL＋player api 層）；照 plan 做＋TDD；守 `03_implementer.md` 全部＋一頁 UI 附則 |
| 不碰 | `scripts/simulation/*` 引擎邏輯（api 三檔除外）、invariants、流程 doc |
| 交付物 | 動詞／面板進 api 層＋**agent 自檢腳本**（REPL 跑該動詞並斷言）——`player_reachable: yes` 票的 (a)(b) |
| 上游 | 正藍圖開票（WHAT）→ systems 立案（seam／tier／player_reachable）→ reviewer R② → implementer-ui |
| 下游 | 同 implementer：handback→systems→QA。QA 對 UI 只驗「碰得到＋判得出」（自檢腳本綠），不驗畫面品質（人的活） |
| worktree | `.worktrees/ui-<slice>/`，同規則 |
| 信箱 | 同 relay；arm 同一支 inbox-watch（角色名不同即不衝突） |

## §5 代價
- 00_roles 加一格＋一頁附則＋seam 規則一條＝工作流改動，先討論後核可。
- 配額：多一個持久 session 的空醒與工作量。**不工作時 ALL-STOP 照舊**。
- reviewer／QA 多一條線要審——但 UI 票的審查面小（api 層＋腳本），比引擎 slice 輕。

## §6 判準（給用戶）
**願不願意讓 UI 等戰爭線收完？** 願意 ⇒ 不加，照 systems 的串行序。不願意 ⇒ 加，第一張票＝9/08 §2①「復活 agent 入口＋市場四件套」。
影子傾向：加。

## §7 誠實標
- 「幾乎不撞檔」是看 owner 範圍推的，沒跑過兩線同時 merge 的實測；api 三檔是共用面，衝突會出在那裡。
- 角色定義是草案，HOW 全歸 systems。
