---
from: systems
to: implementer
status: consumed
slice: A#14 SpecimenTracer combat-death 盲點
tier: probe→infra
topic: ★A 級首張真修票(blueprint 定序);★★★而第一步是【先驗它還在不在】——今天已經三條(#19/#30/#36)是「問題早就沒了或被誇大」,而每次都是查完才知道;★病:Team14 真死於 combat(tick9599)而 decision_count=0、trace 空 ⇒ tracer 只接決策路徑,combat 死接不到
---

# ★①已 grep `known_issues` ＋ `archive/resolved_issues`（雙目標）
```
★known_issues:806「SpecimenTracer combat-death 盲點（2026-07-15，★條目自標【違全量暫態觀測不變量】）」
★archive：未查到已結案同名條（★而「沒查到」是我 grep 的結果，不是保證）
```

# ★★★②第一步：**先驗它還在不在**（★不是先修）
```
★今天的血證，三條【全部】是查完才知道的：
   #19 條目活了七週，而它【隔天就被修了】
   #30 `_calc_reserve` 連同註解【早已整支刪除】
   #36 閘印「272」而真盲【0 張】
⇒ ★★所以：**先確認 combat 死【現在】還是接不到 tracer**
   ★★★而判準是【跑】不是【讀】：造一個 combat 死，看 tracer 有沒有記到
★若已經好了 ⇒ 報我，我銷案（★那也是產出）
```

# ★★③若還在：**修法方向（★而我不指定實作）**
```
★病：`SpecimenTracer` 只接【決策路徑】⇒ ★★而 combat 死【不經決策】⇒ 那條路上沒有 tracer
⇒ ★★★而它違的是【全量暫態可觀測性】（用戶立的不變量：code 改不准製造量測盲點）
★★而修法的形狀我要你先報再做：★★★「把 tracer 掛到 combat 死那條路」有幾種掛法，
   而【掛在哪】決定它會不會變成第二個「觀測改變被觀測物」（★今天 specimen tracer 才剛因為那個被修過）
⇒ ★先報掛點候選 ＋ 各自的寫入風險，我裁
```

# ★④驗收（★而第③條是今天學來的）
```
①★造一個 combat 死 ⇒ tracer 記得到（★★而 `decision_count=0` 不再等於「trace 空」）
②★陽性對照：把掛點拿掉 ⇒ 必須回到記不到
③★★★而【觀測不得改變被觀測物】：開/關 tracer，★含 ephemeral／cadence 欄的特製全 hash 三跑同一
   —— ★而【不要用 state_fingerprint】：它排除 ephemeral 與 cadence 欄，對這類污染【structurally 瞎眼】
④★fp：若①是純新增 tap 且無 RNG 消耗 ⇒ fp 應【不變】；變了就停下來報我
```
