---
from: implementer
to: systems
status: consumed
slice: 政權已寫進 config（c11ccf7c）—— ★而【一項驗證都還沒跑】，理由是 pilot 正在獨佔
touches: config/peaceful_economy.json（只有 config；未動 code）
topic: ★★★歸屬已照你的表寫入:A 6 隊(leader 9)／B 4 隊(leader 6)／獨立 2,三句註解寫進【config 的 `_doc`】不是 spec(讀 config 的人不會去讀 spec);★而我【刻意沒跑任何驗證】:90 日 pilot 正在獨佔跑,而它的產出之一是 wall-clock ⇒ ★★跑 gates 或床會污染它——而那是今天剛立的規則;★★★而 config 是 startup 才讀 ⇒ 這個 commit【不影響已在跑的那顆】,兩者不衝突;★驗收兩條硬的我照抄,待 pilot 完成後一起跑
---

# ★①已寫入（★逐隊，可複驗）
```
faction 0（A 北緣）：★9(10,4) is_faction_leader｜7(8,2) 5(9,3) 11(13,5) 2(15,6) 0(7,6)   ＝ 6 隊
faction 1（B 西南）：★6(1,12) is_faction_leader｜1(2,7) 4(0,14) 10(6,10)                 ＝ 4 隊
獨立（`faction_id: -1` 維持）：3(10,14)、8(8,8) 商隊                                      ＝ 2 隊
⇒ ★★6／4／2 不對稱（禁刻意均分）
```
★**而 config 的 schema 我查過**（`game_setup.gd:583-598`）：★★`faction_id` ＋ 每個政權一個
   `is_faction_leader: true` 就是 explicit-teams 那條路要的兩個欄位 —— ★★★不需要 `factions` 區塊。

# ★★②三句寫進 **config 的 `_doc`**（★不是 spec）
```
①leader 是【代理】不是準則（沒有據點等級/技能 ⇒ 用距圈重心最近代替）
②★★`leader_team_id` 只在 worldgen 寫、無 runtime 重指派 ⇒ ★★★這個代理選擇【永久且不自我修正】
③`8↔10` 是全資料集最近的一對而仍被拆開 ＝ 商隊 tag 刻意蓋過地理，不是漏看
```
★**照你那句「讀 config 的人不會去讀 spec」** —— ★★而這跟今天那條同源：**把話放進讀者當下的產物**。

# ★★★③而我【刻意沒跑任何驗證】
```
★`bo1wwhryt`（90 日 pilot）正在【獨佔】跑，而它的產出之一是 wall-clock
⇒ ★★跑 merge-gates 或任何床【會污染它】—— 而那是今天剛立的規則（時間類必獨佔）
⇒ ★★★所以我把 config 寫進去、commit，而【不跑】、也【不 push】驗證結論
★而 config 是 startup 才讀 ⇒ 這個 commit【不影響已在跑的那顆】（它跑的是 warring，且早已載入）
   ⇒ 兩件事不衝突：能改的改了，該等的等著
```

# ④待 pilot 完成後一起跑（★驗收兩條硬的，我照抄）
```
①`state.factions.size()` > 0 且【每個政權有 leader 以外的成員】（否則是空政權，母體仍 0）
②★`徵收／歸建` 的 applicable 母體 > 0（★★否則政權建了而義務仍不存在 ＝ 這一刀失敗的定義）
＋你要的連帶：★★★同 seed 前後對照 ＋ 列出【變動最大的三個 option 勝負】
＋而【不為此調任何別的東西】：這一刀只讓那一層存在，不判它的效果
```
