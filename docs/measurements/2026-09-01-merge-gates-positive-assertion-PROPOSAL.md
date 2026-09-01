# 提案：merge-gate runner 加【正向斷言】—— ★提案不改（runner 與註冊表都是 systems own）

## ★病（★我做了實證，不是讀 code 推的）
```
註冊表有一欄【判準】（例：「印出 [CONSTITUTION-GATE] PASS」）
★而 runner 從來沒有執行過它 —— 它只看 exit code 與「有沒有出現 FAIL/Parse Error」
⇒ ★★一支【跑了、exit 0、但不下結論】的閘會拿到 ✓，總結印 PASS
```
★**實證**（在 scratchpad 複製 runner 與註冊表跑，★沒有碰任何 owner 檔）：
```
註冊表列：silent	echo ""	示範：跑了但不下結論	印出 [SILENT-GATE] PASS
舊版輸出：[MERGE-GATES] ✓ silent （0s）
          [MERGE-GATES] PASS：全部通過
```
⇒ ★★★**判準寫在表裡而沒有人執行它** —— 而這正是 systems 今天記的那句
  「工具崩潰的長相 ＝ 陰性結果的長相」的第四個實例，**且它就長在防漏跑的那個 runner 裡**。

## ★★補丁（三端已驗）
```
①註冊表加【第五欄 expect】＝該閘必須印出的字面標記
②runner 讀第五欄；有填 ⇒ 輸出必須含它，否則 FAIL（訊息直說「跑了但沒下結論」）
③沒填第五欄的列 ⇒ ★不 FAIL（舊格式合法），但【支數必印】：
   「N 支沒填判準欄 ⇒ 它們的綠【只代表 exit 0】」★★形狀同白名單：應單向下降
```
### 三端對照（patched runner 實跑）
```
loud   （印出標記）      ⇒ ✓
silent （不印標記）      ⇒ ★✗（舊版是 ✓）＋「跑了但沒下結論」
legacy （沒填第五欄）    ⇒ ✓ ＋ 計入註記
```

## ★★★建議的第五欄值（★systems 自己審，我只給草案）
```
constitution     [CONSTITUTION-GATE] PASS
bare-tick        [BARE-TICK-GATE] PASS
build-duration   ★PASS：每個設定工期的寫入點都來自唯一入口
bed-parse        [BED-PARSE-GATE] PASS
bed-arm          [BED-ARM-GATE] PASS
ki-anchor        [KI-ANCHOR-GATE] PASS
```
★**而我建議【由各閘的 owner 確認自己那一行】** —— ★★因為填錯字面值會讓那支閘【恆紅】，
   ★★★那是把「靜默通過」換成「恆紅」，兩個都不是我們要的。

## ★誠實限
```
①★本提案只擋【該印而沒印】；★★擋不了【印了但內容是假的】（例如閘自己算錯還印 PASS）
   ⇒ 那一層要靠閘自己的兩端對照，而不是 runner
②★★我沒有改 .claude/hooks/merge-gates.sh 也沒有改 docs/process/merge-gates.tsv
   ⇒ 兩者都是 systems own；★★★而今天已經有兩次「改別人 own 的檔」被記帳，我不加第三次
③patch 檔：docs/measurements/2026-09-01-merge-gates-positive-assertion-PROPOSAL.diff（38 行）
```
