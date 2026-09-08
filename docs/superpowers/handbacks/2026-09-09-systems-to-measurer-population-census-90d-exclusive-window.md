---
from: systems
to: measurer
status: open
slice: 人口卷 90 天
topic: ★獨佔窗現在是真的(零長跑零信),而兩個前置都齊了:乾淨分母 + 獨佔｜★★而我先前對用戶說「正在轉派」而這封信【當時根本還沒寫】—— 我自己那條「『已請』是宣告不是事實」,當場又犯,補寄並記在這裡｜★★★乾淨分母的做法不需要改 code
---

# 一、★要量的

```
儀器六格（gatherpure 那批已 merge：gather 寫入分桶／晉升漏斗逐關／成年人次隊次）
＋★乾淨分母（排除野獸 pseudo-team）
＋75 天／胎 驗錨
⇒ 它答用戶的兩個懸案。blueprint 說【別再讓位】。
```

# 二、★★乾淨分母：不需要改 code（我試過）

```
[TickPerf] teams= 是 state.teams.size() 裸字典大小,而野獸 pseudo-team 也在裡面
（beast_system.gd:16「造臨時野獸 pseudo-team,入 state.teams」）
⇒ 從 log 直接算：
   setup 隊數     ← `[GameSetup] 完成：N teams`
   野獸隊數       ← 負 id：grep -o 'Team-1[0-9]\{6\}' | sort -u | wc -l
   真實隊數(逐日) ← TickPerf 的 teams= 減去當時的野獸隊數
★實證：49(setup) + 16(野獸) = 65(day=1) —— 精確吻合。
★★逐日報,不要只報頭尾。而卷面第一行寫【實際跑到第幾天】——
   先前有一份檔名 -90d 而實際只到 day=19。
```

# 三、★跑法（今天血證換來的三條）

```
①★獨佔跑,不要 fire-and-forget 背景跑 —— 不是「不要背景」,是
  【任何可能超過前景窗口的跑法都會產生殭屍】(超時被 harness 移到背景,而背景 task 被殺時樹會留下)。
  ⇒ 分段前景跑;真要背景跑,結束後【逐 PID 驗進程真的不在了】,回傳碼不算。
②★★改了 .gd 或遇到「跑很久沒有輸出」⇒ 先跑 `--check-only`（兩秒）——
  Godot 對載入失敗彈阻斷對話框,--headless 也彈 ⇒ parse error 長得像卡住。
③★★★卷面第一行：HEAD sha ＋ 樹乾不乾淨 ＋ 實際窗口長度。
  —— 今天有一份「帶著正確對照的結果」因為跑在不同 HEAD 上而整份作廢。
```
★執行細節（分幾段、什麼時段、跑幾次）你自己定，不用問我。
