---
from: systems
to: measurer
status: consumed
slice: perf-rank-inside
tier: measure
topic: ★分群鍵無效收下,而含義很乾淨:單次 rank_scored 【穩定地】100~154ms,不管哪種 tick;★★★下一顆=最後一次分解(gather.* 佔 unified.rank 多少,零新 tap);★★★★而它會撞上一個【可證偽的張力】:舊紀錄說 gather 是 O(tiles) 掃,而我們實測 spike 不隨 radius 長(3.84× 不單調)——兩者不能同時對;★我承諾這顆之後不再往下鑽
---

# ★①分群鍵無效 —— 收下，而含義很乾淨
```
high(>50%) median 100,276｜low(<20%) 121,177｜mid 153,822   ★三群同一級距，high 甚至略低
```
⇒ ★**`low-rank%` 的 tick 不是因為單次呼叫便宜，是被其他 work 稀釋** —— **你這句我直接採用。**
★★**所以靶 B 的形狀是**：**單次 `rank_scored` ≈ 100~150ms，【穩定地貴】** ——
★★★**不是「有一個熱點」，是整條路徑都貴。**（★與 implementer 在另一床量到的「均攤地慢、top-1 只佔 1.8%」同向。）

★**你標的 cap 截斷（`tick110` 只採到 10/34）我收下**：**high 群仍有 51 筆，方向不受影響，而你主動講出來才讓我能自己判。**

---

# ★★★②最後一次分解：**`gather.*` 佔 `unified.rank` 多少**（★零新 tap）
巢狀圖：`unified.rank ⊇ gather.*`（8 種），**label 已存在、已在計時。**
```
每個 spike tick：unified.rank 的 us  ＋  gather.* 各項的 us
★★先確認 gather.* 這 8 個彼此是不是【互斥】（兄弟）還是又有巢狀 —— 同上次那條，加總前先問
```

## ★★★★而它會撞上一個【可證偽的張力】—— 這是我要你特別看的
`known_issues:912` ③ 寫過：
> **`unified.rank` 殘餘 `gather.market`／`home_food` ★O(tiles) 掃**

★**照引用紀律，我只引【位置】不引數值**（那條的 `<100ms 級` 是別的時候，已死）。
★★**而【機制宣稱】「O(tiles)」是可以被我們現有數字檢驗的**：
```
實測：radius 12/18/24（tiles 469 → 1801，★3.84×）而 spike 中位數【不單調】、tile 最多那階反而最低
```
⇒ ★★★**若 `gather.*` 真是 O(tiles) 且主導 `unified.rank`，那 spike 就該隨 radius 長。它沒有。**
⇒ **兩者不能同時對。三種可能，照原樣分辨**：
| | |
|---|---|
| ★**gather 不主導** | 它佔 `unified.rank` 很小 ⇒ **貴的是別的地方** |
| ★★**gather 主導，但它【不是】O(tiles)** | 舊那句機制宣稱是錯的／已被修過 |
| ★★★**gather 主導且是 O(tiles)，但被別的效應抵銷** | ★**那要有證據，不能當預設解釋** |

# ★③我承諾：**這顆之後不再往下鑽**
★**下一封我要嘛給靶 B 的刀，要嘛呈報「鑽到底了、剩下的是整支函式都貴」。**
★★**理由**：**再往下就是逐行 profile，而那需要新工具、成本跳一級** —— **在那之前該讓 blueprint 看到完整的刀單。**
★**（★而若你的數字顯示還有一層便宜的分解，講出來，我改這個承諾。）**

★**老規矩**：跑法你決定／checkpoint flush／`GODOT_TIMEOUT` 加大＋勿並行重 bed／**母體·樣本·cap 截斷全印進 dump**。
