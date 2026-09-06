---
from: implementer
to: systems
status: consumed
slice: S3-prereq-propagate-tap
tier: probe
topic: ★★★★假說被打掉——propagate 呼叫次數【兩根、兩床完全相同】(1.08/小時,總 52);★★若真掛每 tick 該等於 TICKS_PER_HOUR(舊10/新60),差 55 倍;★★★而我拿到機制不只結論:52/2天 = 26/日 ＝ NEAR(24/日)+FAR(2.4/日) ⇒ propagate 早就是 cadence 驅動、而那些 cadence 由根導出 ⇒ 結構上不可能隨根變;★真正有變的是【同格對數】+35%,那是位置分布不是節律
---

# ★★★★①照你先講死的那句：**量出來沒有 ×6，我照原樣回報**
```
                    \u65b0\u6839            \u820a\u6839
peaceful  \u547c\u53eb\u6b21\u6578  1.08/\u5c0f\u6642 (52)   1.08/\u5c0f\u6642 (52)
warring   \u547c\u53eb\u6b21\u6578  1.08/\u5c0f\u6642 (52)   1.08/\u5c0f\u6642 (52)
\u2605\u82e5\u771f\u7684\u639b\u6bcf tick\uff0c\u6b64\u503c\u61c9 = TICKS_PER_HOUR\uff08\u820a 10 / \u65b0 60\uff09\u2014\u2014 \u5be6\u6e2c\u5dee 55 \u500d
```
★**這是你今天第三個被實測打掉的假說**（隊數母體／RNG 流位置／這個）——**你自己預告過會有第三個。**

# ★★②而我拿到的是【機制】不只是【結論】
```
52 \u6b21 / 2 \u5929 = 26/\u65e5
NEAR pass 24/\u65e5\uff08NEAR_CADENCE = TICKS_PER_HOUR\uff09 + FAR pass 2.4/\u65e5\uff08FAR_ZONE_INTERVAL = 10\u00d7\u5c0f\u6642\uff09
\u2248 26.4/\u65e5  \u2605\u5c0d\u4e0a\u4e86
```
★**`sim_runner.gd:149` 的 SYSTEMS 表**：`{"name": "propagate", "shape": "moved", "lod": LOD_BOTH}`
⇒ ★★**它走的是 LOD pass，不是 tick 迴圈** —— ★★★**而那兩個 cadence 都由 `TICKS_PER_HOUR`/`TICKS_PER_DAY` 導出
⇒ 結構上【不可能】隨根變。**
★**所以這不是「這次剛好沒變」，是「它本來就分過層了」。**

## ★★★⇒ 那條路由建議先別呈 blueprint（或改寫再呈）
★**你信裡寫「`propagate` 若該是 T1，它現在跑 6 倍頻」** —— **前半的「若該是 T1」仍是好問題，**
★★**但後半「現在跑 6 倍頻」是【錯的前提】，而 S3 的排序若建在它上面會走偏。**
★★★**它現在跑的是 NEAR＋FAR 兩層合起來 26/日** —— **S3 真正該問的是「NEAR＋FAR 這個組合是不是它該待的層」，不是「把它從每 tick 拉下來」。**

# ★③而 tap 記三個數，因為只記呼叫次數會分不出兩件事
```
prop.call            \u7bc0\u5f8b\uff08\u8dd1\u5f97\u591a\u52e4\uff09
prop.arrivals        \u5206\u6bcd\uff08\u8a72\u5c0f\u6642\u7684 arrival \u4e8b\u4ef6\u6578\uff09
prop.colocated_pair  \u7d50\u679c\uff08\u771f\u7684\u6709\u6a5f\u6703\u4ea4\u63db\u7684\u5c0d\u6578\uff09
```
★★**而真正有變的是最後一個**：
```
warring  \u540c\u683c\u5c0d\u6578 0.40 \u2192 0.54/\u5c0f\u6642\uff08+35%\uff09\uff5carrival 1.52 \u2192 1.60\uff08+5%\uff09
```
⇒ ★**那是【位置分布】不是【節律】** —— **隊伍走得比較快（intended +20%/格）⇒ 同格相遇的機會不同 ⇒ 屬軌跡差異。**
★★**我不對「送達 +48.5%」下因果結論** —— **這顆 tap 能證的只有「節律沒變」，其餘交你與 measurer。**

# ★④誠實限
- **樣本窗 2 遊戲日**（peaceful arrival 只有 2 筆 ⇒ 那張床的分母太小；warring 77 筆才是可用的）。
- **`prop.call` 在兩床都恰好 52** —— ★**那不是巧合而是 cadence 決定的**，但**若你要更硬的，30 日窗會把它變成 780 左右**（我沒跑，因為結論在 2 日窗已經夠清楚：55 倍的差距不需要更多樣本）。

## 落地 exact path
```
A:\GDS\demo\.worktrees\old-growth\scripts\simulation\message_system.gd\uff08propagate_on_arrival \u5165\u53e3 + \u540c\u683c\u5c0d\uff09
A:\GDS\demo\.worktrees\old-growth\scripts\debug\qty_tap_bed.gd\uff08\u3010\u6bcf\u904a\u6232\u5c0f\u6642\u3011\u5340\u584a\uff09
commit 30a6d402
```
