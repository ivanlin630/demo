---
from: systems
to: reviewer
status: consumed
slice: power_ratio 技能維對稱化（B 級 critical path）
tier: R2
topic: ★藍圖批獨立刀＋升 B 級 critical path(它擋著三票);★★修法＝技能維走人口維同款 fallback(以自己為先驗)⇒ ratio 中性;★★★禁改數值(0.3→0.1 同罪,用戶手抄物理法);★要你重點打兩件:(a)`_team_power` 的組成是不是真的能當「對方的先驗」(b)改完之後 threat_threshold 的意義變了——舊門檻是在【膨脹 3 倍】的尺上校準的
---

# ★①背景（藍圖已裁，不用審）
```
`threat_assessment.gd::_power_ratio`：
   other_power = pop_est * 0.3          ←★手抄常數（實測 self combat < 0.3 的比例 ＝ 100.0%）
   self_power  = _team_power(self_team) ←★★真值
⇒ ★★★ratio 恆 ≈ 3（peaceful 釘死：pop_est 5.99 vs self_pop 6.00、ratio 平均 2.997 ≈ 0.3/0.1）
★而同一支函式裡 pop_est 的 fallback ＝ `self_team.population`（註解「鏡射 diplomatic fallback=self_pop 模式」）
⇒ ★★人口維【用自己當先驗】、技能維【用手抄常數】—— 同函式兩維不一致
★★★修法＝讓技能維說到做到（那行註解自己宣稱「視對方等強」）；★禁改數值（0.3→0.1 同罪）
```

# ★★②要你重點打的兩件
```
(a)★`_team_power(self_team)` 的組成是什麼？—— ★★若它含【只有自己才知道的東西】（裝備、士氣、細部技能），
   那「以自己為先驗」會把【自我認知】投射成【對方的估計】
   ⇒ ★★★那未必錯（人本來就用自己當基準），★但它是一個【WHAT 級】的感知假設，我要你判它有沒有越線
   ⇒ 若越線，替代方案是【世界平均】—— ★★而那又是 god-view（要讀全世界）⇒ 兩難，請你判

(b)★★★改完之後 `threat_threshold` 的【意義變了】：
   舊門檻是在【ratio 恆 ≈3】的尺上校準的 ⇒ 改成中性後，同一個門檻會【變得更難過】
   ⇒ ★藍圖已要求「修後 warring／peaceful 門檻率 re-baseline」
   ⇒ ★★而我要你判：re-baseline 是【量完記下來】就好，還是【門檻本身也要跟著改】
      （★★★後者是調數值 —— 而我們才剛禁了調數值；但「尺變了、刻度沒變」也不對）
```

# ★③驗收（★藍圖指定 ＋ 我加的）
```
①★`fp` 會變（行為修正）⇒ 差在哪要說得出來
②★★門檻率 re-baseline：warring／peaceful 各自的【過門檻比例】修前修後都要印
   —— ★舊值：warring 82.5%／peaceful 20.0%（★★這兩個數是【在膨脹尺上量的】，記著）
③★★★備戰的贏率修前修後：warring 566/1503、peaceful 7/120 ⇒ 修後【應下降】
   ⇒ ★而【下降多少】不預設 —— 若幾乎沒降，代表 power 項不是備戰贏的主因（那會推翻我們的歸因）
④★我加的：`_power_ratio` 的分佈要印（不只平均）——★★平均 2.997 很乾淨，
   ★★★而【乾淨得可疑】：若修後分佈仍集中在單一值，代表還有別的常數在主導
```
