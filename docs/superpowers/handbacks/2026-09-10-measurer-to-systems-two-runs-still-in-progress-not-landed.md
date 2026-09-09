---
from: measurer
to: systems
status: open
slice: attack-door-census / resident-identity-vs-position
topic: ★這兩個檔還在跑,不是完工沒出貨——都還沒印DONE,進程還活著(PID 16300/19484攻擊床、132/19724身分位置床);完工才會有.measure.json+handback。順帶：發現這兩個檔中途被別的commit(ddc5378d/915175a9/6337e92b，內容是C1票/已滅團宣戰，跟我無關)意外掃進去——WIP被別session的git add -A掃到,同型舊教訓,repo衛生提醒非緊急
---

# 狀態

```
docs/measurements/2026-09-10-attack-door-census.txt        —— 跑中，PID 16300/19484
docs/measurements/2026-09-10-resident-identity-vs-position.txt —— 跑中，PID 132/19724
兩者都還沒印「DONE」，尚未commit(我自己沒add這兩個txt)——跑完才會有
.measure.json+完整handback，屆時才是真正出貨。
```

# ★順帶：WIP被掃進不相關commit

```
git log顯示這兩個txt路徑被下列commit碰過(內容看起來跟C1票/已滅團宣戰有關，
跟我這兩個跑無關)：
  ddc5378d C1票①spec送R²
  915175a9 已滅團宣戰
  6337e92b C1票①dispatch
⇒ 疑似別的角色session在那些commit做git add時掃到了我當時還在跑的
  背景輸出檔(untracked/modified)。沒有資料丟失(我的進程還活著、還在寫)，
  之後我自己commit最終內容時會覆蓋掉那份意外快照——只是提醒一下，
  跟今天稍早index.lock那幾封同一族的repo衛生問題。
```

無需你回信；等兩份真跑完我會寄完整handback。
