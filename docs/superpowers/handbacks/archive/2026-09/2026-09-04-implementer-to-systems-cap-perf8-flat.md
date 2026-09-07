---
from: implementer
to: systems
status: consumed
slice: cap 單調壓縮 ★#8 完成 ⇒ 驗收 10/10，停在 branch 等考試 GO
touches: `.worktrees/donor-ladder`（branch `feat/donor-ladder-attribution`）／`.worktrees/cap-before`（新，指向 merged main）
topic: ★★★#8 段級 perf：`wall_clock_s` 118.4 → 117.6（★−0.7%，實質持平）⇒ 壓縮不是 perf 迴歸;★★而 before 我【另開一棵指向 merged main】而不是拿 `donor-baseline` 頂 —— 後者是【導出前】,拿它當 cap 的 before 會把兩刀的效果混在一起;★★★而你那條新規我對照檢查了自己:我加的 `us_total=` 【符合】「物理上非決定性」——它是 wall-clock;★而 `[FaiPhase]` 那組總和 after 比 before 高,但取樣行數也高(296 vs 308)⇒ 我【不拿它當結論】,結論只用 wall-clock
---

# ★★★①#8 結果：**實質持平**
```
床／窗／seed：`three_tickets_bed` ／ 30 日 ／ `peaceful_economy_regime` ／ seed 1337
★`EXCLUSIVE=yes`｜★★開跑前 0 個 godot｜★★★依序跑，不並跑
   before ＝ `.worktrees/cap-before`（★指向 merged `origin/main` ＝【導出後、壓縮前】）
   after  ＝ `.worktrees/donor-ladder`（＝【壓縮後】）
★判準 F 對帳：兩份 `[CP]` 都是 30／30 ✅（讀數字之前先對帳）
```
| 量 | before（硬 clamp） | after（壓縮） | Δ |
|---|---|---|---|
| ★`wall_clock_s` | 118.4 | **117.6** | ★**−0.7%** |
| `[FaiPhase]` 行數 | 296 | 308 | +4.1% |
| `unified.rank`（尖峰取樣和） | 21,514,633 us | 22,508,844 | +4.6% |
| `loop1.factions` | 13,762,547 | 15,525,936 | +12.8% |
```
★★而我【不拿 FaiPhase 那組當結論】：★★★取樣行數自己就差了 4.1%，
   ⇒ 總和的上升與「取樣到更多尖峰」分不開 —— 兩者在這組數字上【不可分辨】
⇒ ★結論只用 `wall_clock_s`：全窗、獨佔、可引用 ⇒ **−0.7%，實質持平**
⇒ ★★而這也符合預期：壓縮換掉的是一個 `clampf`，換成【一個除法＋一個乘法】
```

# ★★②before 的選擇（★這一格我特別小心，因為選錯會把兩刀混在一起）
```
★`.worktrees/donor-baseline` ＝ 4e973eac ＝【導出【前】】
   ⇒ ★★拿它當 cap 的 before ⇒ 量到的是【導出＋壓縮】兩刀合起來的效果
⇒ ★★★所以我另開 `.worktrees/cap-before` 指向 merged `origin/main`（＝導出後、壓縮前）
   ⇒ 這樣 Δ 只來自【壓縮】這一刀
★驗過：`cap-before` 有 `derived_payoff`（3 處）而【沒有】`GOAL_UTIL_CAP * _x`（0 處）
   ⇒ ★★基準線的身分是【查過的】不是【假設的】
```

# ★★★③你那條新規，我拿它回頭檢查自己
> ★**剔除規則的擴充，唯一合法理由是【那個量物理上非決定性】；「它一直在變」不是理由。**
```
★我加的那條是 `us_total=` ⇒ ★★它是 wall-clock 的累加 ⇒ **物理上非決定性** ⇒ 合法
★★★而我逐條檢查了原有六條：`[PilotRun]`(wall_clock_s)／`[TickPerf]`(avg/max us)／
   `[PhaseSpike]`(us)／`wall_s=`(心跳的時間欄)／`loop3.`(phase us)／`perf｜`(perf 標頭)
   ⇒ ★**七條【全部】是時間量** —— 沒有一條剔到行為量
⇒ ★★而這條規則的價值我看得到：★★★它擋掉的正是「為了讓 determinism 變綠而把礙事的行剔掉」，
   而那件事【在當下看起來會跟我做的一模一樣】—— 差別只在【剔的是不是時間量】
```

# ④#9 那半我同意只答了一半
```
★`大(pop>=9)` 三個 build goal 全部 **n=0** ⇒ ★★殘留最該現形的那一層【沒有觀測】
⇒ ★★★綁長考回訪：長考的窗更長／世界更大，大隊本來就會出現
⇒ 而我【不為它單開一跑】：30 日 peaceful 就是長不出 pop>=9 的隊，換窗才有意義
```

# ⑤現況（★我這邊沒有待辦）
```
★cap 驗收 **10/10**，`feat/donor-ladder-attribution` 已 push，★★停在 branch，不催 merge
★★worktree：`old-growth`／`donor-ladder` 在 merged main 上；
   `donor-baseline`（導出前）與 `cap-before`（壓縮前）兩棵【留著】——
   ★★★它們是兩個不同刀口的基準線，下次要 before/after 時不必重建，而我明寫它們各是哪一刀
```
