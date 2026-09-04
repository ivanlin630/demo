---
from: systems
to: implementer
status: open
slice: ★套用 peaceful 初始政權（R² 兩輪已過）—— 而它會改變那個世界，連帶要一起做
topic: ★具體歸屬:A 北緣 6 隊(leader 9)／B 西南 4 隊(leader 6)／獨立 2(3 東南孤點、8 商隊);★★而 leader 是【代理】不是準則(config 沒有據點等級/技能),而 `leader_team_id` 只在 worldgen 寫、無 runtime 重指派 ⇒ ★★★這個選擇【永久且不自我修正】,請把這句寫進 config 註解;★而連帶比我原想的寬:任何跑在 peaceful 上問「誰贏 argmax」的既有量測都可能受影響
---

# ★①要改的（`config/peaceful_economy.json`，逐隊補兩個欄位）
```
政權 A【北緣】：★leader ＝ 9(10,4)；成員 ＝ 7(8,2) 5(9,3) 11(13,5) 2(15,6) 0(7,6)
政權 B【西南】：★leader ＝ 6(1,12)；成員 ＝ 1(2,7) 4(0,14) 10(6,10)
獨立（`faction_id: -1` 維持）：3(10,14)、8(8,8)【商隊】
⇒ ★★6／4／2 不對稱（blueprint 原則：禁刻意均分）
```

# ★★②三句要寫進 config 註解（★不是寫在 spec 就好 —— 讀 config 的人不會去讀 spec）
```
①★leader 是【代理】：blueprint 的準則是「圈內據點等級最高／統領高者」，
   而本 config 沒有據點等級也沒有技能 ⇒ 用【距圈重心最近】代替
②★★而 `leader_team_id` 全檔【只在 worldgen 被寫、沒有 runtime 重指派】
   ⇒ ★★★這個代理選擇【永久且不自我修正】—— 日後 config 有據點等級時應改回原準則
③★`8↔10` 是全資料集最近的一對（hex 2）而仍被拆開 ——【商隊 tag 刻意蓋過地理】，不是漏看
```

# ★★★③連帶（★reviewer 把範圍放得比我寬，我照他的）
```
★不只「政權相關統計」不可比 —— ★★`徵收／歸建` 變成【新的活候選】⇒ **整個競爭池改變**
⇒ ★★★**任何跑在 `peaceful_economy` 上、問「哪個 option 贏了 argmax」的既有量測與 `known_issues` 都可能受影響**
⇒ 所以套用時請一併：
   ①★跑一次 `peaceful_economy` 的前後對照（★★同 seed，只差這個 config 改動）
   ②★★把【變動最大的三個 option 勝負】列出來 —— 那是「競爭池改變了多少」的直接證據
   ③★★★而【不要】為此調任何別的東西：這一刀只讓那一層存在，不判它的效果
```

# ④驗收（★spec §④，這裡重申兩條硬的）
```
★`state.factions.size()` ＞ 0，且【每個政權有 leader 以外的成員】（否則是空政權，母體仍 0）
★★`徵收／歸建` 的 applicable 母體 ＞ 0（★★★否則政權建了而義務仍不存在 —— 那是這一刀失敗的定義）
```
