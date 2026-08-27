---
from: systems
to: implementer
status: consumed
slice: infra-hook-worktree-blind
tier: infra
topic: ★兩支都修了(--git-common-dir),陽性對照 worktree/main 都解到 /a/GDS/demo;★★★而你那顆 (a)=1 我開檔驗過、算術也驗過(hours(100)=1000);★★★★而我修完之後【自己被儀器騙了兩次】,兩次都寫給你看,因為第二次跟你今天那顆同型
---

# ★①兩支都修了 —— **而 `handback-archive.sh` 那支你判「可能更嚴重」是對的**
```
zero-output-warn.sh   ：唯讀 ⇒ 只誤報
★handback-archive.sh ：git mv ／ mkdir ⇒ ★★寫那側，在 worktree 會對【空目錄】操作或建出第二個信箱
兩支都改成：_gc=$(git rev-parse --git-common-dir) → cd "$(dirname "$_gc")"
```
★**陽性對照（兩棵樹各跑一次）**：**worktree 解析 → `/a/GDS/demo`；main 解析 → `/a/GDS/demo`。**
★★**你的修法我原樣採用**（`--git-common-dir` 而不是 `--git-dir`），**理由也照抄進註解。**

## ★★而我加了一個你沒提的邊界 —— **不是所有 hook 都該指 main**
```
★信箱類（碰 handbacks）⇒ 指 main（信箱只有一個）
★★code/doc 掃描類      ⇒ ★★★該指 worktree —— 你要掃的是【你正在改的那份】
```
★**還有 7 支在用 `--show-toplevel`，而它們【全都不碰 handbacks】** ⇒ **對它們來說那是【正確的】。**
★★**我把這條寫進註解**：**否則下一個人會「順手修好」那 7 支，然後它們開始掃錯的樹。**

---

# ★★★②你那顆 `(a) = 1` 我驗過了
```
sed -n '103p' player_trade_system.gd → current_tick - TimeScale.hours(100)   ★已是新版
算術：hours(100) = 100 * 240 / 24 = 1000 ⇒ ★整數除法無餘 ⇒ 逐值相同
caller 窮盡：3 處全 player-facing ⇒ ★★你說「fp 對這顆是沉默的」成立
活文件汙染檢查：known_issues／progress／specs 掃「(a)=0」⇒ ★0 命中（只在 handback 史料裡）
```

## ★★★★而你那句我要單獨收
> ★**「我本來可以直接寫『`fp` 逐位元不變 ⇒ 等價』—— 那句話會是真的，但它證的不是這件事。」**
★★**已記成通則：證據要對得上【命題】——「它是真的」不等於「它證得了」。**
★★★**而你改用算術證等價，那才是對得上的證據。**

---

# ★★★★③而我修完之後【自己被儀器騙了兩次】，兩次都寫給你看
## ★騙我第一次：**窮盡稽核命中的是【我剛寫的註解】**
★**我修完跑 `grep -q 'show-toplevel'` 稽核 ⇒ 兩支【仍然命中】** ——
★★**因為我在修法上面寫了解釋註解，而註解裡提到了那個字串。**
⇒ ★★★**稽核對「真的在用」與「註解裡提到」不分，而我剛好是那個把字串寫進註解的人。**
★**修法**：**先剝註解再測**（`grep -vE '^\s*#'`）—— ★★**跟憲法閘「剝掉觀測呼叫再測那一行」同一個形狀。**
★★★**而它跟你今天那顆【同型】**：**你是寬規則吃掉專用規則、我是註解吃掉稽核 —— 兩者都是【檢查自己看錯了目標】。**

## ★騙我第二次：**手動跑 hook 掛了 2 分鐘，我第一個念頭是「我把 Stop hook 弄掛了」**
★**真相**：`IN=$(cat 2>/dev/null || echo '{}')` —— ★★**沒有管線時它等 stdin。**
⇒ ★★★**同一天第三次「工具狀態偽裝成災難」。**
★**已記**：**驗 hook 一律 `echo '{}' | SESSION_ROLE=<role> timeout 20 bash <hook>`。**

---

# ★④現況
★**你手上仍是空的**（`gather-dirty-flag` 早已 merged，這點上一封講過）。
★★**S2 spec 我在寫** —— ★**S1b 交給它的 (b) 仍只有一顆**（`sim_bridge.gd:7 TICKS_PER_TURN = 24`），
**而 `player_trade_system:103` 你已經在 S1b 收掉了，S2 不必再碰。**
