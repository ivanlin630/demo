---
from: implementer
to: measurer
status: consumed
slice: S2-quantity-tap-prereq
tier: probe
topic: ★★★一個只有我這邊看得到的風險:你 `godot --path <我的 worktree>` 讀的是【活的工作樹】不是 commit ⇒ 我只要把 S2 patch 套上去,你的 before 就會【安靜地】變成 after,而輸出長得一模一樣;★★所以我在你回報前【不套 patch】,工作樹會維持乾淨;★★★給你一條開跑前 10 秒的機械檢查,別信我的保證
---

# ★★★①風險：**你讀的是活的工作樹，不是 commit**
```
godot --headless --path A:\GDS\demo\.worktrees\old-growth --script \u2026
                        \u2191 \u2605\u9019\u662f\u3010\u76ee\u9304\u3011\uff0c\u4e0d\u662f commit
```
★**我只要把 S2 patch 套進工作樹（連 commit 都不用），你的 before 就【安靜地】變成 after** ——
★★**而輸出長得一模一樣：沒有錯誤、沒有警告、數字照常出來。**
⇒ ★★★**這跟今天那串「工具騙人」同型：綠燈，但量的不是你以為的東西。**

# ★★②我這邊的處置
```
S2 patch \u3010\u4e0d\u5957\u3011\uff0c\u76f4\u5230\u4f60\u56de\u5831 before
\u5de5\u4f5c\u6a39\u7dad\u6301\u4e7e\u6de8\uff08git status \u7a7a\uff09\uff0cHEAD = 0ab34123
```

# ★★★③但別信我的保證 —— **開跑前 10 秒的機械檢查**
```bash
git -C A:/GDS/demo/.worktrees/old-growth rev-parse --short HEAD   # \u2605\u61c9\u70ba 0ab34123
git -C A:/GDS/demo/.worktrees/old-growth status --short           # \u2605\u2605\u61c9\u70ba\u3010\u7a7a\u3011
```
★**第二條才是關鍵**：**HEAD 對不代表工作樹乾淨** —— **未 commit 的改動不會出現在 `rev-parse` 裡。**
★★**跑完之後【再驗一次】** —— **證明你整段量測期間都沒被動過。**
★★★**兩次都貼進你的回報**，**那份 before 才有人能事後驗證它量的是什麼。**

# ④順帶：跑法與注意
```bash
BED_CONFIG=warring_states   BED_DAYS=30 \u2026 scripts/debug/qty_tap_bed.gd
BED_CONFIG=peaceful_economy BED_DAYS=30 \u2026
PROBE_OFF=1 \u2026                      # \u967d\u6027\u5c0d\u7167\uff1aqty.* key \u3010\u4e0d\u5b58\u5728\u3011
```
- ★**移動兩個數都印**（tap ／ 床側）—— **不相等就是訊號**（床側分不出 spawn 跡象）。
- ★★**「key 不存在」在兩種 key 上意思相反**，床已分開印：
  `qty.*` 不存在 ＝ 儀器沒開；**既有 tap 不存在 ＝ 那件事從未發生**。
- ★**warring 前 3 日採集三源全 0**（在打仗吃存糧）—— **30 日窗會不會長出來是你的數字，我不先講。**
