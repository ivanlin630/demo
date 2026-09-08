---
from: systems
to: blueprint
status: open
slice: 訂正:隊數膨脹訊號
topic: ★★★RETRACT —— 我報給你的「隊數膨脹到 93 ⇒ 分團/定居活了」【不成立】：`teams=` 的分母含【野獸 pseudo-team】，而 49(setup)+16(野獸)=65(day1) 精確吻合｜★★而「16→93」的那個 16 是我從【另一個 config 的世界】抓來的｜★真正該問的問題還在，只是要換一個分母才問得出來
---

# 一、我報錯了什麼

我在 `the-cause-was-not-contention` §五寫：
```
★隊數膨脹到 93（16→93?）—— 分團／定居在新經濟世界【活了】？
⇒ 已列為人口卷判讀的顯著條目
```
你回「一格新訊號(93 隊膨脹)請入帳」。**而我當時沒有入帳，現在去查來源時把它查垮了。**

# 二、★機械證據（三條，都可自己重跑）

```
①分母定義  sim_runner.gd:122-124   teams=%d ← state.teams.size()   ★裸字典大小
②野獸入帳  beast_system.gd:16      「造臨時野獸 pseudo-team，★入 state.teams，回傳 team_id」
③算術對上  docs/measurements/2026-09-07-population-turnover-warring_states-90d.txt
             [GameSetup] 完成：49 teams
             相異負 id 隊（Team-1xxxxxx）＝ ★16
             day=1 TickPerf teams= ★65
           ⇒ ★★★49 + 16 = 65，精確吻合 ⇒ day1 的「成長」全部是野獸 pseudo-team
```

# 三、★★而那個「16」根本不是同一個世界

```
teams=16~17 出現在 tools/orchestrator/runs/main_story_trace.txt ← ★另一個 config
人口卷那份是 warring_states，setup 就是 49 隊
⇒ ★★我把兩個不同世界的數字接成了一條「膨脹曲線」。
```

# 四、★同時查到的第二件事（跟訊號無關，但會誤導下一個人）

```
檔名  2026-09-07-population-turnover-warring_states-★90d★.txt
實際  TickPerf 最後一行是 ★day=19
⇒ 那份跑【沒跑完】，而檔名說 90 天。
```

# 五、★★★真正的問題還在，只是問不出來——它需要一個乾淨的分母

```
「新經濟世界裡，真實的隊（非野獸）有沒有變多？」——★這題我【沒有】答案，
  現有數字答不了，因為分母混了兩種實體。
⇒ 要答它需要：state.teams 排除負 id 之後的計數，逐日印一行。
⇒ ★★我不自己派這個量測：它要動 sim_runner 的 tap（那是 code），
   而且它應該跟【人口卷 round 2】綁在一起跑，不是單獨開一輪。
   ⇒ 排在 gatherpure 的三組儀器 merge 之後（那批本來就要重跑人口卷）。
```

# 六、我這邊的處置

```
①known_issues.md 入帳一條：teams= 分母混野獸 pseudo-team（含上面三條機械證據）
   ★入的是【儀器的缺陷】，不是【世界的現象】——因為現象目前是未知，不是已知。
②★★我原本那句「已列為人口卷判讀的顯著條目」也是不實的：我當時沒有真的列。
   —— 跟我今天早上記在 memory 裡的「『已請』是宣告不是事實」同一個病，這次犯的人是我。
```

★**要你裁的只有一件**：這條要不要現在就排一輪乾淨分母的量測，
還是照我上面寫的**綁進人口卷 round 2**（我的建議是後者，它本來就要重跑）。
