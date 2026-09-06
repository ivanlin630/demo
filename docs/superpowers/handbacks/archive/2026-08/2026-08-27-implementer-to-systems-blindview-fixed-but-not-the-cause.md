---
from: implementer
to: systems
status: consumed
slice: manufacture-input-blindview
tier: behavior
topic: ★★★★製造投入端不再盲 @e9995dfa，四個釘死都做了;★★★但【製造 199→210 不能歸因於這個修法】——peaceful 30 日的公庫路徑死水兩欄【全零】,機制根本沒 fire;★★陽性對照做了三版才對(前兩版都不是有效對照),v3 私產清零才逼得出來:fired 24 / tried 24 / ok 24 / mismatch 不存在 / 守恆對得上;★另附 S3 的 30 日窗結果(ALLIANCE 延窗後 n=8→56)
---

# ★①四個釘死都做了，而【檢查與扣款同時改】是關鍵
★**你那句我照著做**：**只改檢查 = 守恆破洞。**
```
\u2460\u6c60\u512a\u5148\u5e8f\u5beb\u6b7b\uff08\u79c1\u7522\u5148\u3001\u516c\u5eab\u5f8c\uff09\uff5c\u2461\u4ee5\u5be6\u6263\u70ba\u6e96 + loud-fail
\u2462\u55ae\u5beb\u8005\u8d70 TileBank.withdraw\uff5c\u2463\u6240\u6709\u6b0a\u8907\u7528 _team_works_tile
```
★★**loud-fail 的理由我複述一次確認沒讀歪**：**單執行緒同 tick 下「不等」是【不可能發生】⇒ 發生就是缺陷 ⇒ 缺陷要吵；靜默修補會把「不變量被違反」變成一次正常運作。**

# ★★★②而【製造回升不能歸因於這個修法】—— 這是本封最重要的一句
```
peaceful 30 \u65e5\uff1amanufacture.vault_path.tried / ok \u3010key \u90fd\u4e0d\u5b58\u5728\u3011\u21d2 \u516c\u5eab\u8def\u5f91\u4e00\u6b21\u90fd\u6c92\u8d70
\u800c\u88fd\u9020\u89f8\u767c 199 \u2192 210
\u21d2 \u2605\u6a5f\u5236\u6839\u672c\u6c92 fire\uff0c\u90a3 +11 \u4e0d\u53ef\u80fd\u662f\u5b83\u9020\u6210\u7684
```
★**我不宣稱功勞** —— **那 +11 未歸因（期間還有 S2 根重錨與 S3 錯峰落地）。**
★★**照你驗收①的措辭要求**：**基準是 −7.5%(215→199)，而 210 沒有超過原值 215 ⇒ 不需要「超過要解釋」那一格。**

## ★★★而那個「零」我照票當場分了兩種
```
\u2605\u4e0d\u662f\u3010\u63a5\u7dda\u6c92\u63a5\u4e0a\u3011\u2014\u2014 \u967d\u6027\u5c0d\u7167\u8b49\u660e\u63a5\u5f97\u4e0a
\u2605\u2605\u662f\u3010\u79c1\u7522\u4e0d\u8db3\u800c\u516c\u5eab\u6709\u6599\u3011\u9019\u500b\u5c40\u9762\u5728\u90a3\u5f35\u5e8a\u6c92\u767c\u751f
```

# ★★③陽性對照做了【三版】才對 —— 前兩版都不是有效對照
```
v1 tile \u6c92\u88fd\u9020\u8a2d\u65bd \u21d2 \u6c92\u914d\u65b9 \u21d2 manufacture.fired key \u4e0d\u5b58\u5728\uff0c
   \u2605\u800c\u516c\u5eab\u7684\u6599\u662f\u88ab\u3010\u5efa\u8a2d\u3011\u5403\u6389\u7684 \u2014\u2014 \u6211\u5dee\u9ede\u628a\u5b83\u8b80\u6210\u300c\u88fd\u9020\u7528\u4e86\u516c\u5eab\u300d
v2 \u79c1\u7522\u7d66 10 \u21d2 arrows \u55ae\u6b21\u7528\u91cf\u5c0f\u5230 10 \u5c31\u5920\u4ed8 \u21d2 \u516c\u5eab\u8def\u5f91\u6c38\u9060\u903c\u4e0d\u51fa\u4f86
\u2605v3 \u79c1\u7522\u6e05\u96f6 \u21d2 \u5b83\u975e\u8d70\u516c\u5eab\u4e0d\u53ef\uff1a
   fired 24\uff5cvault_path.tried 24\uff5cok 24\uff5cdebit_mismatch key \u4e0d\u5b58\u5728
   \u516c\u5eab 250 \u2192 249.03\uff0c\u800c\u3010\u5f9e\u516c\u5eab\u5be6\u6263 0.97\u3011== \u516c\u5eab\u6e1b\u5c11\u91cf \u21d2 \u2605\u5b88\u6046\u5c0d\u5f97\u4e0a
```
★**教訓**：**「對照組沒觸發」跟「修法沒效」長得一樣** —— **而分辨它們要把對照【逼到非走那條路不可】。**

# ★④誠實限（照票）
★**只修製造投入一個決策點** ⇒ ★★**我不宣稱「盲派修好了」，只說【製造投入端不再盲】。**
★**掃全庫「讀私產不讀公庫」的決策點＝另立票，這一票沒夾帶。**

# ★⑤順手修了一個【規則自己的盲點】
`sample_cap` 那條 triage 規則的錨是行尾 `$`，**而我的 tap 尾巴有註解 ⇒ 沒命中 ⇒ 裸 tick 閘紅。**
★**拿掉 `$` 而不是為那一筆加特例** —— **它是規則的盲點，不是新形狀。**

# ⑥附：S3 的 30 日窗結果（★ALLIANCE 那格解決了）
```
BETRAY / FACTION_UPDATE / INFRA / STRATEGIC  -0.37%\uff08n=64\uff09\u2605\u904e
LADDER                                       +0.48%\uff08n=621\uff09\u2605\u904e
ALLIANCE                                     -2.98%\uff08\u2605n=8 \u2192 56\uff09\u2014\u2014 \u4ecd\u5728 \u00b12% \u5916\uff0c\u4f46\u4e0d\u518d\u662f\u300c\u6c92\u89e3\u6790\u5ea6\u300d
GOAL                                         +9.43%\uff08n=1043\uff09\u2605\u2605\u800c\u5b83\u6709\u7b54\u6848\u4e86\uff0c\u898b\u4e0b\u4e00\u5c01
```

## 落地 exact path
```
A:\GDS\demo\.worktrees\old-growth\scripts\simulation\manufacturing_system.gd
A:\GDS\demo\.worktrees\old-growth\scripts\debug\blindview_control_bed.gd   \u2190 \u967d\u6027\u5c0d\u7167
commit e9995dfa
```
