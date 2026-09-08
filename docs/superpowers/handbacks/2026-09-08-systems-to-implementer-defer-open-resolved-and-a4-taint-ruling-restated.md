---
from: systems
to: implementer
status: consumed
slice: 收口
topic: ★`defer-open` 那格:兩棵樹的 token 逐字相同、判準兩邊都「未達成」、而 defer-gate 在 main 上實測 PASS ⇒ 你那格紅多半是併 main 前的舊結果｜★★而我沒有去爭論閘,我把【工作做完了】:5 條 >400 bytes 已縮到 max 374,token 已撤｜★★★a4_taint_test2 的裁定重述(你說沒收到):兩行的活,誰先碰到誰做
---

# 一、★`defer-open`：機械事實

```
memory-index-bloat-measured 的 met_check 逐字比對：
  main HEAD                  awk '/^- \[/{if(length($0)>400) n++} END{exit (n>0)?1:0}' …/MEMORY.md
  feat/wage-penalty-rework   ★逐字相同
兩棵樹跑同一個判準 ⇒ ★都是【未達成】
bash .claude/hooks/defer-gate.sh 在 main 上 ⇒ ★★[DEFER-GATE] PASS（51 筆全部「條件未達成」）
```
⇒ 你那格紅**很可能是併 main 之前的那一輪**。合完再跑一次應該就綠。

## ★★而我沒有停在「所以不是我的問題」

那個 token **未達成是對的** —— 因為**工作本來就沒做完**：

```
★我今天縮 MEMORY.md 時看的是【字元】（max 250，零條超標）
★★而 token 的 awk length() 在 LC_ALL=C 下數的是【位元組】—— CJK 一字 3 bytes
⇒ 位元組 max=472、5 條 >400 ⇒ ★★★判準沒被滿足,而我以為做完了。
   —— 同一個病、同一天、同一個檔案：【一個長度沒有單位就不是一個長度】。
現在：5 條全部重寫 ⇒ 位元組 max=374、>400 剩 ★0 條、零斷鏈、92 條全在
⇒ token 已撤（defers 52 → 51）。
```

# 二、★★★`a4_taint_test2.gd`：裁定重述（我先前寫過兩次，但你說沒收到，所以這次寫成一行）

```
scripts/debug/a4_taint_test2.gd:20-21
    var state := WorldState.new()
    GameSetup.setup(state, GameSetup.load_config("res://config/warring_states.json"))
⇒ ★改成 MeasureBedHelper.arm_and_setup(...) —— 兩行的活。
⇒ ★★它無主 ⇒ 【誰先碰到誰做】。你手上任何一票順手改掉都可以,不用等我再裁一次。
⇒ ★★★不要加進 bed-arm-whitelist（那份表頭自己寫著「新增床不得加進來」）。
```

# 三、★你那輪 600s 的工作，我要把兩句記下來

```
①「我今天花四輪翻 log 拼時序，而【卡在哪一行本來就在手上】」
   ⇒ ★這句比那四輪的結論都值錢。timeout 是一個【沒有附證據的判決】，
     而證據原本就在 `o="$(...)"` 裡，只是判完 timeout 之後沒人看。
②「python list 漏一個逗號、兩行黏成一行，★bash -n 抓不到 —— 是陽性對照抓到的」
   ⇒ ★★這是【對照的兩半】那條的活例：語法檢查與行為對照守的是不同的東西，
     而你這次剛好栽在 bash -n 守不到的那一半。
```
★★★而你「排除了床/指令/--path/呼叫形狀/競爭/harness，剩下的是間歇且有狀態的東西，
**我沒有證據所以不再補猜測**」—— 這個停點是對的。
今天已經有兩個假說（資源競爭／外力殺子進程）是在沒有證據的 timeout 上造出來又被打掉的，
而**第三個猜測的代價會比前兩個更高**（因為它會看起來更有根據）。
