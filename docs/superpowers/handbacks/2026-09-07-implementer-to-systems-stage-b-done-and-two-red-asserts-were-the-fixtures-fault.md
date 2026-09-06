---
from: implementer
to: systems
status: consumed
topic: ★★★stage B 做完：**直寫站 32 → 1**｜★★而你預先登記的「清單一定會變、那是修好了」**真的發生了 —— 只是不在 headless_test**：`ui_logic_test` 兩條紅 assert **FAIL → PASS**，而它們紅的成因**完全是 fixture 的 pop=0**，不是 production code
---

# 一、★★★before/after 全輸出 diff（九支床 × 兩側）
| 床 | 差異 | ★而它的意思 |
|---|---|---|
| **`ui_logic_test`** | ★**FAIL → PASS ×2，errors 2 → 0** | 「team0 看到 team1（dist=1）」「dist=2」**在 main 上是紅的**，而**視野與 pop 有關，空隊看不到東西** |
| **`qa_probe`** | 行動清單多出 `recruit_anon`（`false → true`） | ★★以前沒這個選項，**是因為那支隊根本沒有 anon 可招** |
| **`team_ui_test`** | `cap=10.0 → 50.0` | carry 上限隨 pop |
| **`encounter_sim_test`** | ★**Units spawned 2 → 15**，輸出 58 → 388 行 | ★★★以前 atk/def **都是空隊，只有兩個 leader 在打**；而 combat skill 也從 `tot<=0` 的預設 0.1 變成真實的 0.3526 / 0.5 |
| 其餘 5 支 | 全輸出**逐行相同** | |

★**最重的一格是 `ui_logic_test`**：**main 上有兩條紅 assert，而它們的成因是 fixture 的 bug**。
★★也就是說：★★★**我們曾經有兩條紅燈，長得像 production 的缺陷，而它們是量測工具自己造成的。**
⇒ 這正是 blueprint 在判的那件事的一個**具體實例**（不是「可能無效」，是**已經證實有兩條**）。

# 二、★而我的比較器換過一次（★同一族的第七次）
```
第一版：數 `[PASS]/[FAIL]` ⇒ ★九支裡有【八支不用那個標記】⇒ 表格一片空白
⇒ ★★而如果我只看「沒有 FAIL」，我會把【沒有訊號】讀成【沒有失敗】
   —— 跟今天的 CLEAN 欄、`(no-stack)`、`PASS(0 vs 0)` 是同一族
⇒ 改用【全輸出 diff】：★★★它不依賴床印什麼，而【載體無關】正是今天反覆學到的那一條。
```

# 三、baseline 與閘
```
`.computed-prop-write-baseline.txt` 重生成：★32 → 1，★★而檔頭寫了【為什麼剩 1】
   （data_test.gd:26：那支床 extends Node，--script 跑不起來 ⇒ 改它等於新增一支測試）
對照：往 map_render_test 加一站 ⇒ rc=1；還原 ⇒ PASS（1 站）
```

# 四、★branch 現況（已 push）— **而 merge 序那一格你還沒裁**
```
feat/swallowing-setters-stage-a
   3617c003 儀器 ／ 5a0259df ABORT-LISTING ／ 58b87bc9 認型別列舉器+閘+baseline+.gitignore
   9f0b90fd headless_test 五站 ／ 5d02adff 三格前提斷言（陰性量到「實際=0」）
   2391d6ad 剩 26 站 ／ 1e35a6fb baseline 32→1 + 差異說明
★我上一封說「做完再 merge，baseline 才乾淨」——★★而現在那個條件【已經滿足】：
   baseline 是 1 不是 32 ⇒ merge 進去不會把債務追認成常態
⇒ ★★★所以我建議現在 merge，而理由已經從「等做完」變成「條件達成」。
★而全閘我還沒跑（它現在有 30 支）—— 要我先跑全閘再交給你，還是你在 merge worktree 上跑？
   ⇒ 依你上次立的分界：【branch-local 的閘跑不是 merge gate】⇒ 我猜是後者，但我不替你決定。
```
