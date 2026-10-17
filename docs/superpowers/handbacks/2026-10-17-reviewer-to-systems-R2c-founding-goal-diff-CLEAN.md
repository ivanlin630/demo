---
from: reviewer
to: systems
status: consumed
slice: 開點登進既有長程目標表
topic: R²c VERDICT＝CLEAN（附 4 條派發前請併進 spec 的文字修補，不需再審）。靜態讀 code，沒跑測試。
---

# 一、N1–N3、S1–S4 收沒收（spec 4b1445069 diff 全讀）
| 條 | 結果 | 依據 |
|---|---|---|
| N1 (a) | ✓ | §四 `_delegate_variant` 範圍：謂詞 `is_founding_task`（`settle_site` 或 `build_type`）只放行紮根；「建設」「自救建田」（`options.gd:70-100`）維持原檢查，範圍外與交件信各列一條。兩個 option 沒 type／level，不呼 plan 是對的 |
| N2 (a) | ✓ | 快取進場條件改為「有自家據點 ∧ 屬掛的母體」，`idle_labor` 前置拿掉，代價（掃圖的隊變多）寫明，F8 加 perf 那一拍與母體比例（對照修前③④嘗試隊），F2 先推一個 INFRA_INTERVAL |
| N3 | ✓ | `no_crew` 成為步驟 0（n 迴圈之前），空範圍明文不得落進 `site_barren`／`food_bridge`；混合情形用「拿掉糧橋還有沒有可行 n」分流，判得出來 |
| S1 | ✓ | F8 印開點列 `x` 分布、與維持／設施列並排、`gu2.payoff_val`；貼頂照實寫不自己調。這一格是量測不是守衛，我接受 |
| S2 | ✓ | 鍵名對照表在 `:` 派遣端段；見下 C3 的一處殘留 |
| S3 | ✓ | F5 反例格改用真實派遣／開工／落成／解散流程，印落成當 tick 謂詞輸入（工地與據點 owner id、`subteam_ids`、子隊在不在）。正是抓「子隊先解散、owner 仍是子隊 id」那個窗口 |
| S4 | ✓ 方向；見 C1 | 兩處升人都移到 plan.ok 之後；F7 兩處各驗 |

# 二、派發前請併進 spec 的文字修補（C1–C4）
- **C1 generic 分支沒有 plan 呼叫 — 兩端一致在這條路上沒有被構造**
  - §四「只有四個地方呼它」＝值、候選、`_dispatch_builder`、`_delegate_variant`。紮根委派變體走的是 `_dispatch_goal_delegate` **generic 分支**（`faction_ai_system.gd:5902-5914`），不經 `_dispatch_builder`；那裡派出人數讀 `td.settler`（`:5909`），沒有 plan 呼叫。於是 S4 寫的「升人移到 `plan.ok` 之後」在這一支沒有 `plan.ok` 可指。
  - 修補：generic 分支對 `is_founding_task(td)` 的情形，在升人前**重呼 plan**（與 `_dispatch_builder` 開頭同形，`ok=false` ⇒ `funnel.build_gate.<reason>` ＋ return false），並把這一處列為第五個 plan 呼叫點；非開點（建設、自救建田）不呼，維持「升人在最後一道檢查之後」。F9 單隊床加一格：構造一支紮根委派變體，注射「generic 分支不呼 plan」要紅在 `crew.*`／同隊同格連續失敗串。
- **C2 兩句殘留的舊斷言現在不成立**
  - §二 `:48`「全圖掃描次數 ≤ 今天」與 `:75`「④ 那份退場 ⇒ 讀的次數不增加」，都是 N2 放寬之前寫的；N2 之後掃圖與 `_site_resource_bonus` 的遠端現存量讀會**增加**（母體從「有閒勞力的隊＋每勢力一支」變成「有據點的自主隊」）。把兩句改成與 N2 一致（增加，量在 F8 perf）。藍圖遠端存量那張票的範圍估計也要用這個新母體。
- **C3 F9 的 reason 名與鍵名不一致**
  - F9 電池段寫 `in_flight`／`tile_occupied` 列出不設 0；S2 的對照表說 `in_flight` 沿用鍵 `busy_subteam`。請 F9 同時寫 reason 名與鍵名，避免實作端查 `funnel.build_gate.in_flight` 得到恆 0（空洞）。
- **C4 `tile_occupied` 對紮根續建的自家工地**
  - plan 步驟 2 寫「目標格有工地……或是別人的」。紮根的 `settle_resume_site`（回頭續建自己已開工的地，`options.gd:354-355`）目標格有的是**自己的**工地（`construction_team_id == 自己`）。照字面，`is_founding_task` 為真的續建委派變體會被判 `tile_occupied`。續建本來不該委派（母隊自己回去蓋），所以結果大概是對的，但請在步驟 2 寫明「有工地且不是自己的」，並在 §五寫一句「`settle_resume_site` 不產委派變體／或產了也不會被 plan 擋錯」，免得實作端兩邊各猜一次。

# 三、結論
- **CLEAN**。C1–C4 是 spec 文字補寫，系統端併入後可直接派實作，不需再回 R²。C1 是其中唯一動到驗收格（F9）的一條，請不要漏。
- 實作端交件時請照 spec 末的清單，特別附：負對照 m1–m9 紅燈原文、F5 落成窗口的謂詞輸入、`MIN_PARENT_POP_AFTER_DISPATCH` 剩餘讀者分類、payoff `x` 分布。
