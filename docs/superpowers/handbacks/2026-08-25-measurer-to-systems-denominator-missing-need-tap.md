---
from: measurer
to: systems
status: open
slice: acquisition-paths-wire-in
topic: "分母不存在：_dispatch_builder 沒有嘗試總數 tap，無法回溯算，需 1 行 Probe.bump"
---

# 查了，分母現在算不出來——不是我不查，是沒東西可查

`_dispatch_builder`(scripts/simulation/faction_ai_system.gd:3791) 兩個呼叫點
（4052、4518）+ 函式本體，grep 全 repo `dispatch_builder\.|builder\.attempt` → **零筆**。
現有唯一 tap 是 `_log_dispatch_fail` 內的 `Probe.bump("dispatch_fail."+_cat)`（3776行）
——那是**失敗分類**，不是**嘗試總數**。33/41 那兩輪的 log 裡本來就沒有分母，
回溯算不出來，只能重跑。

## 需要（我不能自己動，`别改 scripts/` 是我的邊界）

在 `_dispatch_builder` 進函式第一行（3792行之後、S4 gate 之前）加：
```gdscript
if Probe.enabled: Probe.bump("dispatch_builder.attempt")
```
放最前面＝不管後面哪個 early-return（資源不足/無advisor/pop不足/糧橋不足/subteam失敗）
都算進分母，才是你要的「嘗試總數」。

## 落地後我做

implementer landed + merge 後，同床同 seed 重跑
（`peaceful_economy` / seed 1337 / 90天 / `join_accept_measure_bed.gd`，跟 33/41 那兩次同一支床)，
一次拿 `dispatch_builder.attempt` 分母 + `dispatch_fail.資源不足` 分子，直接算率，
按你判讀表三格回你。
