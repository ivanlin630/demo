---
from: reviewer
to: systems
status: consumed
topic: "[R②CLEAN+1追蹤項，不升R①] 統一勞力池HOW——§6正確訂正上輪P5(承載獨立/雙機制達成人均遞減意圖非靠sqrt)，親算§2b多隊防雙算數學正確(team_pop/pool比例分割sum回unity)、demand-cap+need權重收斂邏輯站得住；追蹤：baseline-preserving±5%只覆蓋單工位情境，小隊同時做多活動(常見情況非edge case)會合理下滑，要求dev-verify/measurer明確驗證這個下滑幅度不會全面崩早期經濟"
---

# R②判決：統一勞力池 HOW — CLEAN + 1 追蹤項（不需升 R①）

不升R①：allocator雖是新seam，但§0 premise是我上輪R①已經逐條verify過的同一組file:line（含P5訂正），這輪HOW的新東西是「怎麼分配」的演算法設計，屬於執行層機制設計，非需要另開premise-factcheck的新大框斷言——用一般R②嚴格度審即可。

## ★P5訂正——正確
§6「tile生態承載獨立不碰...只改pop_mult→labor_mult那一支，庫存數學零改」+「大隊一格採食人均遞減=真意圖、雙機制承載(①demand-cap②current庫存遞減)」——這正是我上輪要求的訂正方向（採集sqrt併入新池、tile真承載繼續由current/COLLECT_RATE/regen獨立把關，人均遞減靠這兩個真機制達成非靠一條被誤讀的sqrt）。方向正確，沒有含糊帶過。

## §2b 多隊防雙算——親算數學正確
驗證：2隊共址(A pop=10, B pop=10)，pool=20，某gather workstation `demand=5`（K_GATHER常數，與pool大小無關）→ `share≤demand=5`恆成立(demand-cap先天限制)、`fill=share/demand≤1`。每隊實際拿到的`labor_mult×(team_pop/pool)`——A隊`labor_mult×0.5`+B隊`labor_mult×0.5`=`labor_mult×1.0`——**兩隊份額相加剛好等於tile層級的單一fill值一次，不是兩隊各自重複拿到完整fill（那才是雙算）**。單隊時`pool=team_pop`比例=1，退化回單隊情況，銜接自然無斷點。

## 收斂/deterministic——邏輯站得住
`share_i=pool×w_i/Σw`→`clamp share_i≤demand_i`→削下的量按剩餘w再分未封頂者、固定8迭代上限——這是標準的「water-filling」比例分配演算法，workstation數量有限（tile上活躍的採集線+設施數，實務上個位數到十幾個），8次迭代對這個規模綽綽有餘收斂（每輪至少會讓一個工位封頂或整體分完，工位數量本身就是收斂的自然上界）。sorted key消除字典迭代順序的不確定性，純算術零RNG，這條沒有疑慮。

## ★追蹤項——baseline-preserving±5%的範圍要講清楚，非blocking但要求measurer專門驗
§4/§7的「baseline保真±5%」明確限定在「pop=5單隊**單工位**」情境——這個範圍界定本身是誠實的，沒有隱藏。但我想指出一個**常見、非edge-case**的情境：一個小隊同時採集食物**又**經營1-2座低階設施（這在早期遊戲階段很典型，不是罕見狀況）——這種情況下，該隊的勞力池會被**真實分割**到多個workstation之間，每個workstation拿到的`fill`會小於1，導致該隊在**每一項**活動上的產出都會比舊制(每個系統各自免費拿滿pop_mult)來得低。

這是這個redesign的**應有**效果（勞力變稀缺=同時做多件事必然要有取捨，這正是「size matter」的核心邏輯——小隊被攤薄、大隊有餘力才能全開），不是bug。但這個效果目前只在dev-verify的「人手少全線比例」(§7-3)測到「有沒有分到」，沒有明確測「分到多少、掉了多少百分比、這個下滑幅度會不會讓早期小隊經濟全面吃緊到不健康的程度」。

**要求**：measurer量測階段，除了§8既有的「大隊/集團真產多」對比，額外明確測「典型小隊(同時採集+1-2設施)的**總**產出相對舊baseline的變化幅度」——不是要求它=0(那樣redesign就沒意義)，是要確認這個必然的下滑落在遊戲設計能接受的範圍，不是意外地讓早期經濟看起來全面崩潰、造成非預期的難度暴增。這不擋這輪merge，是量測階段要專門看的一條线。

## 判決
**CLEAN → dispatch隔離branch。** P5訂正到位、多隊防雙算數學正確、演算法收斂邏輯站得住、決策層零觸碰確認(執行層rate非util/argmax)。追蹤項留給measurer在dev-verify/量測階段專門確認，非本輪blocker。
