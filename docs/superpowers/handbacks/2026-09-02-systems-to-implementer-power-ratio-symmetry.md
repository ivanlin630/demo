---
from: systems
to: implementer
status: open
slice: power_ratio 技能維對稱化（B 級 critical path）
topic: ★R② 過,兩條 issues 都有答案且都比我問得好:(a)【不越線】——「視對方等強」是已核可的通則非人口專屬,技能維用同一原則＝【同一 invariant 的第二次應用】不是新 WHAT;(b)門檻要跟著改,★★★但改法必須是【除以已測出的膨脹係數】這種同源推導——否則就是把手抄物理從 0.3【搬去 threshold 換位置藏起來】;★另:你報的 bed_arm_gate 自相矛盾我修了,而修的時候把 print 弄壞又修回
---

# ★①修法（★形狀，禁改數值）
```
`threat_assessment.gd::_power_ratio`：
   ★現況：other_power = pop_est * 0.3（手抄常數）／self_power = _team_power(self_team)（真值）
   ★★改成：技能維走【與人口維同款】的 fallback —— 以【自己】為先驗
      （人口維已經這樣做：`pop_est` 的 fallback ＝ `self_team.population`）
   ⇒ ★★★ratio → 中性（≈1），而那正是那行註解自己宣稱的「視對方等強」
★禁：把 0.3 改成 0.1（藍圖明令：同罪 —— 改數值三個月後又爛）
```

# ★★②R② 的兩條答案（★都比我問得好，照這個做）
```
(a)★【不越線】：reviewer 查到「視對方等強」是【已核可的通則】，不是人口專屬
   ⇒ ★★技能維用同一原則 ＝【同一 invariant 的第二次應用】，不是新的 WHAT 判斷
   ⇒ ★★★而 world-average 那個替代方案【本來就被這條 invariant 排除】（它需要 god-view）
   ★順帶：他查到 `threat_assessment.gd:68` 引用的「invariants.md:171-173」★【行號已腐朽】
      （現在那幾行是別的內容）；真身在 `process/detail/invariants-cases.md:83`
      ⇒ ★★修的時候【順手把那個引用改成 檔::節名】，不要留行號（今天立過的規矩）
(b)★★★門檻 re-baseline：【量完 ＋ 門檻也跟著改】，
   ★而改法必須是【除以已測出的膨脹係數】這種【同源推導】
   ⇒ ★★不是重新手感選一個數字 —— ★★★否則等於把手抄物理【從 0.3 搬去 threshold】換位置藏起來
```

# ★③驗收（★藍圖＋R²＋我加的那條）
```
①`fp` 會變 ⇒ 差在哪要說得出來
②★門檻率 re-baseline：warring／peaceful 過門檻比例修前修後都印
   （★舊值 82.5%／20.0% —— ★★記著那是【在膨脹尺上量的】）
③★★備戰贏率：warring 566/1503、peaceful 7/120 ⇒ 修後應下降；
   ★★★而【下降多少不預設】—— 幾乎沒降就推翻我們的歸因，那要回報不是調參
④★我加的：`_power_ratio` 要印【分佈】不只平均 —— ★★平均 2.997 乾淨得可疑，
   ★★★若修後仍集中在單一值，代表還有別的常數在主導
```

# ④你報的那件我修了，而修的時候自己犯了一次
```
★`bed_arm_gate.gd` 檔頭說「白名單 ≠ 盲區規模」而 print 說「這就是盲區規模」——★★你抓對了：人讀到的是 print
⇒ ★★★而我改的時候【把 print 整行覆蓋掉】，閘一度變成 parse error ⇒ 已修回並跑過，PASS
⇒ ★教訓給我自己：改一行輸出要【跑一次那支工具】再說話 —— 而我今天已經說過同一句話
```
