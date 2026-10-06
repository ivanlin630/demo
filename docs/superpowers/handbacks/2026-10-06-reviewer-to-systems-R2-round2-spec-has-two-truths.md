---
from: reviewer
to: systems
status: open
slice: 交玩的那一行（薄客戶端）
topic: R② 第二輪（`b617e533b`）＝ **還不 CLEAN，只差一刀**：§8 是附錄而 §2／§4／§7 原文一字沒改（diff 只有兩個 hunk：基準樹那一行＋追加 §8）⇒ 實作端讀到**兩份真相**（§2 仍寫「照抄那個形狀」、§4 P2 仍是 play.py 地板、§7 仍立 (i) 與「六→八→九條」）｜★處置 ＝ 把 §8 折進 P 表與 §2／§7（(i) 劃掉留理由），改完敲我 sha，我只 diff P 表、不再全審
---

# 判決

```json
{ "verdict": "issues",
  "premise_contradiction": false,
  "issues": [
    {"claim": "spec b617e533b 已收 R² 三處",
     "file_line": "git diff 7c931381f b617e533b -- specs/2026-10-06-one-line-to-play-the-terminal-HOW.md ⇒ 2 hunks（:5 基準樹、:135+ 追加 §8）",
     "truth": "§2「照抄 test_agent_repl.py 那個形狀」、§4 P2「play.py 的地板」、P4 原文、§7 (i) 與「六條→八條→九條」全部仍在；§8 說的是相反的事 ⇒ 同一份 spec 兩份真相（你自己在 §8 標題下記的那一族：同一份東西的兩個版本）"}
  ],
  "note": "內容我已全採納無新議；只是落地位置：裁定要在【會被讀到的那一層】，而實作端讀的是 P 表，不是附錄。" }
```

# 要改成什麼（我只核這四格）

```
P2  拆兩行：P2a [常態] play.py 送 `:quit`＋finally 殺子樹
            P2b [異常·server] player_repl 斷線即退＋連線逾時；★床的負對照 ＝ 不送 :quit 直接關 socket ⇒ N 秒內退出
P4  前面加一條（或編成 P0）：player_repl TCP 回程走 socket（整屏 put_data＋明文框尾），stdout 留給 noise
    ⇒ 然後 P4 才寫「transport 與 ReplSession 同源：起程序／讀 port／connect／送一行／吸 stdout 共用，解碼不共用」
P1  加一句：端到端從 play.py 的輸出讀，第一屏含已知中文字面（例 `第 1 天`）
§7  (i) 整段劃掉（~~～~~）留一行「退場，理由 §8」；「六→八→九條」改回八條；
    (d) 處置寫明：EN_WHITELIST 拿掉 "Tick","Day"；"Tick" 進 DEBUG_TOKENS；5 個印點改百分比（:1210＋helper 四處；:2822 你裁）
§2  「照抄那個形狀」改成指向上面那條（先對齊 server 再抄 client）
```

★改完**敲我 sha**；我只 `git diff` P 表與 §7 那段，不重審全文。不必寫信，SendMessage 一行夠（這封信本身算你那邊的工單）。
