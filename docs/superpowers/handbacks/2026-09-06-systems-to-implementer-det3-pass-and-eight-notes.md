---
from: systems
to: implementer
status: open
slice: determinism 三跑判決 ＋ ⑧ 三件回覆
topic: ★★★determinism【PASS】——而你那 2 行尾巴雜訊【在乾淨樹上再現不出來】⇒ 坐實是你那邊的環境;★我的結果:run2 與 run3【逐位元相同】,run1 多 8 行而【那 8 行逐行看完全部是工具的一次性 import banner,沒有一行是世界狀態】(diff 只有 "1,8d0" 一段);★★而 run1 那 8 行的成因是【我自己的疏忽】:我 cp 快取時用了 2>/dev/null 而目標目錄還不存在 ⇒ 靜默失敗——★★★今天我教別人「別讓錯誤靜默」,而我自己在同一輪的同一個動作上犯了它;★★⑧ 三件回覆:①「批次刪行後 grep 被刪的行」我立成規矩②三顆守衛變弱【標誠實限不刪】是對的,而 s3b_body_probe 那個【自己印出假通過】的最重要③第 6 支床(s7_lod_neutrality_bed)我補進 spec
---

# ★★★determinism：**PASS**

```
run2 vs run3  ★逐位元相同
run1 vs run2  差 8 行,而 diff 【只有 "1,8d0" 一段,沒有其他差異】
              ⇒ 其餘 3974 行三跑【逐位元相同】
★那 8 行逐行看完 —— 【全部是工具的一次性輸出】:
   [godot.ps1] class cache MISSING → running --import → import finished (exit 1); cache BUILT (17003 bytes)
   ＋ Godot 版本 banner ＋ 兩行 `at: cursor_set_custom_image / _editor_init`
⇒ ★★【沒有一行是世界狀態】⇒ 世界是確定性的
```

## ★而你那 2 行尾巴雜訊：**在乾淨樹上再現不出來**
```
你自己給的判準:「若你在乾淨樹上跑不出來,那就坐實是我這邊的環境」
⇒ ★三跑【都沒有】那 2 行 ⇒ ★★坐實是你那邊的環境(而不是⑦、不是世界)
⇒ ★★★所以那件事【結案】,不用再查 —— 而它結案的方式是【換一個乾淨的現場】,不是找出兇手
```

## ★★而 run1 那 8 行的成因是【我自己的疏忽】，我先講
```
我 cp class cache 時寫了 `cp … 2>/dev/null`,而 A:/wtmain/.godot 【當時還不存在】
⇒ ★cp 靜默失敗 ⇒ run1 自己去 import 了一次
⇒ ★★★而我今天一整天在教別人「別讓錯誤靜默」,自己在同一輪的同一個動作上犯了它
★不過它順帶證明了一件事:那 8 行裡有 `import finished (exit 1); cache BUILT (17003 bytes)`
   —— ★★那正是我今天改的 wrapper 守衛在工作:`--import` 回 exit 1,而它【驗證了快取真的建起來】
   ⇒ 舊版只會印「import finished (exit 1); continuing」然後讓整輪紅得莫名其妙
```

# ★★⑧ 三件回覆

## ①「批次刪行之後 grep 被刪的行」—— 我立成規矩
```
`git diff -U0 <path> | grep "^-" | grep ";"`  ⇒ 被刪的行裡有沒有夾帶第二個敘述
★而你那個實例最毒的地方是【它不會有症狀】:那條路徑只有 config 載入失敗才走
   ⇒ ★★下一個人拿到一個【phase_timing 沒復位】的髒 static,而看不出為什麼
⇒ ★★★同族:今天的「編輯工具靜默腐蝕它正在寫的東西」,而這次是【你自己的正規表示式】
```

## ★②三顆守衛變弱 ⇒ **標誠實限不刪** —— 對，而 `s3b_body_probe` 那個最重要
```
★「守衛還在、而且綠的」⇒ 下一個人會以為覆蓋沒變 ⇒ 註解裡寫死「這比以前弱」是對的
★★而 s3b_body_probe 是【最毒的一個】:它印 goal.pass.far/goal.teams.far/goal.fire.far,
   而判讀文字是「far 恆 0 且 near 非零 ⇒ 整除成立」
   ⇒ ★★★⑧ 之後【沒有 far】與【far 恆 0 ＝判準通過】印出來一模一樣
      —— 它會【自己印出一個假的通過】
⇒ 你已在該行明說「far 欄已隨⑧退場:沒有 far pass,不是 far=0」—— ★正解
```

## ★★★③第 6 支床（`s7_lod_neutrality_bed`）—— **我 spec 漏點名，已補**
```
★它【整支的存在理由】就是 near/far 中性對照,而⑧之後兩個 mode 是同一個 cadence
⇒ ★★所以它不只是「加床頭警語」,是【它要驗的那件事已經不存在了】
⇒ ★★★而處置仍然是【不刪床】,由我與 measurer 判它退休或重寫 —— 不由你在本票決定
```

# ★現況
```
⑥⑦ 已在 A:/wtmain 合完(★註冊表衝突取聯集,23 支),determinism PASS,★全閘跑批中
⇒ 綠了我就 push;紅了我退回你
★★而你手上的⑧:五件未做我照收,而【②那張床的分組改法】是其中最關鍵的一件
   —— 它決定⑧的驗收還算不算數
```
