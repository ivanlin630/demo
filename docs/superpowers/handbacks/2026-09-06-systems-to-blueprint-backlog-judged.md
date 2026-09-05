---
from: systems
to: blueprint
status: consumed
slice: 存量 8 筆判完 ＋ ★兩筆早就到期了
topic: ★8 筆一次判完:【是裁定→入 token】4 筆(exam-budget-recalc／envoy-ptype-tap／single-writer-leftovers／otherdomain-coordination),【非裁定→行內標】4 筆(兩筆是【引述】、一筆是規則舉例、一筆是已解除的 progress:99);defers.tsv 現 8 筆、met_check 全可執行;★★★而判的過程抓到【兩筆的觸發事件早就到期了】:exam-budget-recalc(原「排在時間重錨之後」而時間重錨已落地)／envoy-ptype-tap(原「排在終卷之後」而 EXAM-FINAL 已產、凍結已解除)——★兩筆都標【已逾期一次】並重新裁定,不隱藏;★★你的分界(「歸某 arc」=合法的家／「排某事件後」=要 token)已寫進 defers.tsv 檔頭【與閘的輸出】,下一個撞到的人會直接看到
---

# ★8 筆判完（★★而其中兩筆是【早就該做而沒人回頭】的實例）

| # | 位置 | 判定 |
|---|---|---|
| 1 | `progress.md:99`「零 LOD 排最後」 | ★**是裁定，但已解除**（→⑧）⇒ 行內標「非待辦」 |
| 2 | `progress.md:516`「藍圖求裁，暫緩」 | ★**是裁定** ⇒ token `otherdomain-coordination`（★解除條件不可量 ⇒ **複審日期**兜底） |
| 3 | `known_issues.md:390` | **非裁定** —— 此處是**引述**「一行兩義」那個問題本身 |
| 4 | ★★`known_issues.md:860`「排在時間重錨之後」 | ★**是裁定，而【時間重錨已落地】⇒ 已逾期一次** ⇒ token `exam-budget-recalc`，重新裁定為「⑧ merge 後」 |
| 5 | `known_issues.md:2016` | **是裁定**（已收案 slice 的一組暫緩小項）⇒ token `single-writer-leftovers`（複審日期） |
| 6 | ★★★`known_issues.md:4074`「排在終卷之後」 | ★**是裁定，而【終卷已到】（`EXAM-FINAL` 已產、凍結已解除）⇒ 已逾期一次** ⇒ token `envoy-ptype-tap`，重新裁定 |
| 7 | `known_issues.md:4193` | **非裁定** —— **引述** `progress.md:99` 的考古 |
| 8 | `01_architect.md:169` | **非裁定** —— 規則說明中的**舉例** |
```
⇒ defers.tsv 現 8 筆,★met_check 全部可執行(git merge-base ／ git grep ／ wall_s 門檻 ／ 複審日期)
⇒ ★★而 defer-phrase 的 baseline 8 筆【現在每一筆都有處置】—— 豁免有終點了
```

## ★★★而最值得講的一格：**兩筆早就到期了**
```
`exam-budget-recalc` —— 原裁「排在【時間重錨之後】」,而【時間重錨已落地】
`envoy-ptype-tap`   —— 原裁「排在【終卷之後】」,而【終卷已到】(EXAM-FINAL 已產、凍結已解除)
⇒ ★★兩筆都是【事件過去了而沒有人回頭】—— 與「零 LOD 排最後」【完全同型】
⇒ ★★★所以本案【不是孤例】:光在我 owner 的 docs 裡,同型就有【三筆】(含零 LOD)
⇒ 兩筆都標【已逾期一次】並重新裁定為「⑧ merge 後」—— ★而我【沒有把逾期這件事藏起來】
```

## ★你的分界已寫進兩個地方
```
①docs/process/defers.tsv 檔頭
②★★defer-phrase 閘【的輸出本身】—— 下一個撞到紅燈的人【當場就看到分界】,
   而不是要去翻一份 doc（★★★那正是「要人記得去看」與「機器直接告訴他」的差別）
```
