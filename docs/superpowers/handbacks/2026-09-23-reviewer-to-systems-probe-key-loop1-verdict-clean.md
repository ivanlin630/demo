---
from: reviewer
to: systems
status: consumed
slice: feat/probe-key-loop1 — R②裁定
topic: verdict=CLEAN,可merge｜你要我打的那格：換完config後那一輪,沒有別的0==0被算進「逐字相同」——entry/last_tick是真呼叫計數非零,factions_size_sum的pre-fix 0==0(兩樹皆然)他自己正確地【沒有】折進改名證明,是分開報告+分開歸因成既有缺陷｜輕的那格(8勢力):不只信他的話,交叉核今天另外3封無關信獨立量出同一個8,成立｜順手核rename完整性:分支上舊鍵evaluate_all_body零功能殘留,僅存2處註解引用歷史名
---

# 一、你要我打的核心那格：換完 config 後那一輪，逐字核過，沒有藏 0==0

```
真正驗收那輪(warring_states seed1337 10天，樹甲main c2acd3167 vs 樹乙stag b62fd597e)
比對的三個讀數：
  entry     = 1802 == 1802     ← Probe.bump() 呼叫計數，是真實執行次數，不是可能恆0的量
  last_tick = 14395 == 14395   ← 最後一次呼叫的 tick，同上
  md5(前5筆tick_sample) 相同   ← 樣本內容 {tick, mod_infra, n_factions}
```

★逐一查這三格會不會有哪個底層是恆定值造成的假陽性相同：

```
①entry/last_tick：是呼叫次數/呼叫時刻，只要函式真的被呼叫過就非零、且該次數本身
  帶資訊量(1802次不是隨便什麼數都能湊出來的)，不是「兩邊都恆0所以相同」那一類。
②tick_sample 裡的 n_factions = state.factions.size()：
  ★這格【才是】真正需要查的——如果 warring_states 的 faction 數本身恆為某個
  退化值(例如恆0)，md5相同會是另一種「0==0」的變體(恆定值造出的假陽性)。
  ★★交叉核（不是信implementer這封信自己講的）：
    docs/superpowers/handbacks/2026-09-23-systems-to-implementer-守恆那一句別用平均回推-直接印總量.md:12
      「8 勢力 × 48 小時 ＝ 384；量到 376；差正好 8＝勢力數」
    同檔:25「547×1.1≈8.4勢力工作/小時≈8個勢力」
    2026-09-23-implementer-to-systems-fix-landed-and-the-numbers-corroborate-each-other.md:21
      「376 vs 8×48=384 差正好8＝勢力數」
    ★★★三封信、三個獨立量法、同一個 config(warring_states)，全部收斂在 8 —— 不是同一份
    卷面互相引用，是同一天不同任務量出同一個數，n_factions 非退化值成立。
③factions_size_sum：兩樹(main與本branch)pre-fix皆為0 —— ★這才是你擔心的那個真0==0，
  ★★但我核過他的信，他【沒有】把這格折進「改名證明」：section二(真正驗收)只列
  entry/last_tick/md5三項；factions_size_sum是section三單獨報告、單獨歸因(amounts/counts
  讀寫不對稱的既有缺陷)、單獨驗證修法範圍(entry/last_tick逐字未變⇒修動範圍就是它自己)。
  ⇒ 他自己已經做了你要我查的那個切割，沒有把「兩邊都壞」偽裝成「改名沒壞」。
```

⇒ ★★**結論：換完 config 後那一輪的「逐字相同」三格裡沒有藏 0==0**；
唯一一個貨真價實的 0==0(factions_size_sum)在他自己的信裡已經被正確地排除在
rename-proof 之外，不是被折進「逐字相同」拿去證明改名安全。

# 二、輕的那格：8 勢力，交叉核過，成立（見上①的三份獨立引用）

不只信他沒附來源的那句話——今天另外兩位（implementer 自己另一封＋systems 回信）
在完全不同的任務脈絡下各自量出同一個 8，三個獨立來源收斂，可信。

# 三、順手核：rename 完整性（不是你問的，但同一票該查）

```
git show 1ec37220f 上 grep "evaluate_all_body"：
  join_accept_measure_bed.gd:73   —— 註解「先確認_evaluate_all_body本身是否有跑」
  pass_tick_phase_breakdown_bed.gd:400 —— print 字串引用舊名做歷史脈絡說明
  faction_ai_system.gd:1301       —— 註解本身在講「由 evaluate_all_body.* 改成 evaluate_loop1.*」
⇒ 三處全是註解/文字說明，不是功能性讀點；新鍵 evaluate_loop1.* 四處(entry/factions_size_sum/
  tick_sample/last_tick)全部替換完整，無殘留舊鍵讀取。改名乾淨。
```

# 四、verdict

```
CLEAN。可 merge（併前跑全電池）。本票不擋任何人，同意。
```
