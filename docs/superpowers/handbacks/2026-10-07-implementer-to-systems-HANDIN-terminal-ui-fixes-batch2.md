---
from: implementer
to: systems
status: consumed
slice: 終端介面修正 第二批：U2＋U3-K4（只查根因）＋U5＋S1
topic: ★**交件｜已知紅 4**（P10／攻擊、P3／打聽情報、P3／確認打聽、STUCK／攻擊）｜BATTERY_RC=0｜107 綠／0 紅（run-id `2693-20261007-052811`，HEAD `ea0e869d3`）｜branch `feat/terminal-ui-fixes-2` 遠端 tip **`935707983`**（接在已 merge 的 c57f186f6 之後，沒 rebase）｜★fp **變了（量的、已歸因到 S1）**：8c9b2d72… → b64512c8…，基準同 branch 換
---

# 一、改了什麼

```
U2 招募子選單：開選單那一刻結果行換成「招募 TeamN：選記名成員或 [A] 匿名，[Esc] 取消」（舊：留著上一道令的「已排入：…」）
   MODE_KEYMAP 補 "recruit" 一列「[1-9]記名 [A]匿名 [Esc]取消」（舊：沒有這一列 ⇒ 鍵列印主畫面那一份）
U5 E4 那個字元查到了：forced_label 自己加的 ✓／✗（diplomacy 的接受／拒絕、join_request 的婉拒、aid_request 的拒絕，共 4 處）
   ⇒ 拿掉；ui_flow_test P20 那一格原本比「[1] ✓ 接受」，跟著改成「[1] 接受」（否則它恆真）
S1 TeamData.same_faction(a, b)（team_data.gd，要求 faction_id != −1）取代 12 處裸比較（表 §三）
U3-K4 只查根因、沒修（理由 §四）
E2E：KNOWN 刪 P2|招募、E2|提議同盟、E4|記號；E2 格加反向（兩邊設成同一個 faction ⇒ 提議同盟仍不可）＋把 S1 母體印在卷面
已知問題清單：招募結果行、無勢力被判同勢力 兩列標已修
```

# 二、E2E（seed 1337）

```
已知紅 7 → 4：P10／攻擊、P3／打聽情報、P3／確認打聽、STUCK／攻擊（剩下的兩組都不在本票：交戰畫面票／打聽寫入 0 筆待量）
step 08 招募：結果行 ＝ 招募 Team7320：選記名成員或 [A] 匿名，[Esc] 取消
E2：雙方 −1 ⇒ 提議同盟可做｜【反向】雙方都設成勢力 0 ⇒ 不可（對方已經和你同一個勢力）
S1 卷面：裸比較剩 39 行（非註解；git grep 含註解是 40）｜TeamData.same_faction( 呼叫 12 處
負對照（獨立 worktree）：拿掉 U2 那一行 ⇒ P2 紅（step 8 按「招募」結果句是上一道令）｜forced_label 加回 ✓ ⇒ E4 紅｜pcs:104 改回裸比較 ⇒ E2 紅
```

# 三、S1 母體表（掃描：`git grep -n "faction_id == [a-z_]*\.faction_id\|faction_id != [a-z_]*\.faction_id" -- scripts/simulation scripts/ui`，修前 52 行）

```
★換成 same_faction 的 12 處（兩邊都可能是 −1，而那一處的語意是「同一個勢力」⇒ 兩支無勢力隊被當成自己人）
  player_command_system.gd:104  提議同盟「不可：同一個勢力」（E2 本體）
  player_command_system.gd:1408 清除成員指令「目標不是同勢力成員」
  decision/decision_context.gd:411  掃候選時跳過「自己人」⇒ 無勢力隊跳過所有無勢力隊
  decision/decision_context.gd:1091 掃「同勢力隊」的家糧 ⇒ 無勢力隊把所有無勢力隊當同伴
  faction_ai_system.gd:3015／3030  遷移抵達「同勢力據點就地成居民」⇒ 無勢力隊併進別的無勢力隊的據點
  faction_ai_system.gd:3342        寄存只寄「同勢力」據點 ⇒ 寄到別的無勢力隊的據點
  faction_ai_system.gd:3356        掃同勢力成員
  inquiry_system.gd:66 ＋ message_system.gd:286（後者註解寫「判準抄 inquiry 那一行」）：「敵人動向」排除同勢力 ⇒ 無勢力玩家問不到其他無勢力隊
  outpost_system.gd:872            _has_control「主人那一方在場」：主人無勢力時任何無勢力隊（含想奪控的那一支自己）都算 ⇒ 改成「主人自己或同勢力」
  sim_runner.gd:910                同格同勢力 ⇒ snapshot_faction_member（無勢力隊互記成勢力成員）
★刻意不換的 5 處（兩邊 −1 時那一處**要**包含「無勢力主人自己的」子隊／居民；換掉會把自家人也排除，要的判準是「屬於誰」不是「同勢力」）
  decision/goal_resolver.gd:414-415  領主只收「本勢力自有居民」的買糧單 —— 無勢力領主的居民也是 −1
  faction_ai_system.gd:852           _has_inflight_settler：主人的子隊正在去安頓（無勢力主人的子隊是 −1）
  faction_ai_system.gd:4112          子隊抵達「自家」據點就地安頓
  interaction_system.gd:413／419     安頓中的隊遇到同勢力據點 ⇒ 轉居民
  ⇒ 但它們同時也會把**別的**無勢力隊的子隊／居民算進來（同一個病的另一半）⇒ 需要「屬於誰」的欄位，不在本票，回報
★其餘：本來就守了 != −1（25 行）／一邊已先排除 −1（faction_ai 6227、7518、strategic 221／267 等）／純觀測標籤（faction_ai 3770／3773 shelter 的 Probe 標籤）／註解（faction_ai 2497）
```

# 四、U3-K4（攻擊那一鍵畫面慢 1 tick）—— 查到根因，沒修

```
探針（佈置同格 NPC，按 t tab 1 6）：按 6 之後 1 幀內 world 1 → 3，畫面頂列 00:02
根因：_process 的 tick_step（world 2）→ _refresh（畫面 00:02）→ 進交戰 _enter_encounter → encounter_view.show_encounter()
      → _advance_until_player_or_end() → sim_bridge.advance_encounter_tick() → runner.advance_tick（world 3）
⇒ 多出來的那一格是**交戰畫面自己的時間迴圈**推的，而終端沒有交戰畫面 ⇒ 跟 K5 同一個根 ⇒ 歸終端交戰畫面票；KNOWN 留著
```

# 五、fp（量的）

```
前一輪（run-id 57076-20261007-044901，HEAD 5d57f219a）world-fp 唯一一紅：final_fp ＝ b64512c884a05ded862584f2228f5d68
歸因：同一棵樹只把 S1 那 12 處改回（其餘 U2／U5 不動）⇒ final_fp ＝ 8c9b2d72e28aef7116edef1283ab9974（舊基準）⇒ 變的全是 S1
⇒ 基準換成 b64512c8…（ea0e869d3，同 branch）；本信那一輪 world-fp ✓、world-fp-ctrl ✓（同 process 兩趟相同）
★S1 是世界規則的改動（12 處決策／行為判斷）⇒ 世界行為會變；我沒做行為因果的判讀，要不要請量測員／QA 看一輪由你定
```
