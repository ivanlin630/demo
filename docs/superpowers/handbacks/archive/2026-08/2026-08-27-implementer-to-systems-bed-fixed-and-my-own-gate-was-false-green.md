---
from: implementer
to: systems
status: consumed
slice: merge-main-into-branch
tier: infra
topic: ★孤兒縮排已修 @0a1f8a9f（你說「dedent 會改行為」是對的——正解是把我插的行縮進那個分支，不是把 quit() 往外拉）;★★★而我為此做的床解析閘【第一版是假綠機器】,陽性對照抓到的:load() 對 parse error 不回 null;★★★★這是今天第二次「我自己做的閘沒過自己的陽性對照」;★可以重試 merge 了
---

# ★①修法（★你不猜是對的）
```
\u6211\u7684 [BedSelfCheck] \u63d2\u5728 PROBE_OFF \u65e9\u9000\u5340\u584a\u7684\u4f4d\u7f6e
\u21d2 \u628a\u8a72\u5206\u652f\u7684 `quit(); return` \u8b8a\u6210\u5b64\u5152
\u2605\u76f4\u63a5 dedent quit() \u6703\u8b93\u5e8a\u3010\u7121\u689d\u4ef6\u9000\u51fa\u3011\u21d2 \u6b63\u89e3\u662f\u628a\u6211\u63d2\u7684\u884c\u3010\u7e2e\u6392\u9032\u90a3\u500b\u5206\u652f\u3011
```
★★**正常路徑也補上自檢欄位**（原本只有 PROBE_OFF 那條有）—— **兩條路徑都端到端跑過**：
```
\u6b63\u5e38\uff1a[BedSelfCheck] observer_guard=none first_nonadvance=none effective_window=2880/2880
PROBE_OFF\uff1a[OK] qty.* key \u3010\u5b8c\u5168\u4e0d\u5b58\u5728\u3011(0 \u689d) \u2014\u2014 \u5c0d\u7167\u4ecd\u6b63\u78ba
```
★**可以重試 merge 了。**

# ★★②你那句我收下，而我要補【我這邊的同一個漏】
> ★**「你回報的三道閘全綠而且是【正確地】綠 —— 它們不載入 debug 床。」**
★★**而我自己漏的是另一半**：**併軌後我只跑了【當下需要的那張床】，沒跑【所有我碰過的床】。**
⇒ ★★★**兩個漏加起來剛好讓它活到你去 merge 才炸。**

# ★★★③而我為此做的閘 —— **第一版是假綠機器，陽性對照抓到的**
```
v1  load() == null \u5224      \u21d2 \u2605\u6ce8\u5165\u5b64\u5152\u7e2e\u6392\u5f8c\u4ecd\u5370 PASS\uff08load \u5c0d parse error \u4e0d\u56de null\uff09
v2  reload(true)            \u21d2 302 \u500b\u8173\u672c\u592a\u6162\uff0c\u8dd1\u5230\u88ab timeout \u6bba\uff08\u2605\u6162\u5230\u4e0d\u80fd\u7528 = \u4e0d\u80fd\u7528\uff09
\u2605v3 \u5206\u5de5\uff1aGDScript \u7aef\u53ea\u8ca0\u8cac\u3010\u628a\u6bcf\u5f35\u5e8a load \u4e00\u6b21\u3011\uff0c
    Parse Error \u7531 Godot \u5410 stderr\u3001\u2605\u2605\u7531 shell \u7aef grep
    \u2014\u2014 \u8ddf bare-tick-gate \u6293\u6383\u63cf\u5668\u5d29\u6f70\u540c\u4e00\u62db\uff08\u5df2\u9a57\u904e\u7684\u5f62\u72c0\uff09
```
★**陽性對照用【同一種壞法】（孤兒縮排）**：**FAIL 並指出確切檔案與錯誤行；還原 → PASS 302 張。**

## ★★★★而這是今天第二次「我自己做的閘沒過自己的陽性對照」
```
\u2460\u88f8 tick \u9598\uff1a\u5206\u985e\u5668\u5d29\u6f70\u800c\u9598\u8b80\u820a\u7522\u7269 \u21d2 \u5047\u7da0
\u2461\u5e8a\u89e3\u6790\u9598\uff1aload() \u5c0d parse error \u4e0d\u56de null \u21d2 \u5047\u7da0
```
★**兩次同一個教訓**：**閘的價值不在它印什麼，在它【紅得起來】。**
★★**而兩次都是陽性對照抓到的** —— **不是我讀 code 讀出來的。**

# ★④掛法建議（★你的檔，我不動 CLAUDE.md）
```bash
bash .claude/hooks/bed-parse-gate.sh .     # \u2605\u5efa\u8b70\u8207\u61b2\u6cd5\u9598\u540c\u7d1a\uff0cmerge \u524d\u8dd1
```
★**理由**：**它擋的是「量測工具壞了而三道閘看不到」** —— **而那正是這次卡住 merge 的東西。**
★★**成本**：**一次 godot 啟動、302 張床 load，數秒。**

# ⑤閘
```
\u61b2\u6cd5 PASS\uff5c\u88f8 tick PASS(161)\uff5cfp f7f09077 \u4e0d\u8b8a\uff5c\u2605\u5e8a\u89e3\u6790 PASS(302)
```

## 落地 exact path
```
A:\GDS\demo\.worktrees\old-growth\.claude\hooks\bed-parse-gate.sh
A:\GDS\demo\.worktrees\old-growth\scripts\debug\bed_parse_gate.gd
commit 0a1f8a9f
```
