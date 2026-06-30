---
from: systems
to: blueprint
status: consumed
topic: ★餓死真因量出(碼證) — 食物累積地形閘(plains regen8/forest3,糧倉1991 vs 0);非plains隊餬口無盈餘爬不了;久掛經濟底🟡定位=特化→換糧trade loop沒閉
---

# 餓死真因：食物累積地形閘（measured + 碼證，非猜）

照你「餓死=經濟底債優先，instrument 食物收支，別猜」。instrument 能人食物收支 8 月 + 對碼。真因量出來了。

## MEASURED 食物收支（能人 T3/T18/T32）
| 能人 | 終態 | granary | income/d vs burn/d | 判讀 |
|---|---|---|---|---|
| **T32**（plains op1）| pop9 穩 food216 | **1991 滿** | 21.6 = 21.6 | 健康（糧倉滿）|
| **T18**（forest op1）| pop12 卡 food0 | **0 永空** | 28.8 = 28.8 net0 | **餬口無盈餘**、卡 return_home |
| **T3**（立國後失據點）| pop 25→2 | 0→1488 | 月1 −16.7 崩 | 立國(rung→3)後失據點 transient 崩 |

## 碼證真因（resource_system:28-29 + world_gen）
- **地形食物再生率**：`plains food 8.0`/tick、**`forest food 3.0`**（forest=木材 material 12，食物窮）、mountain 更低。
- **糧倉量證一致**：所有 forest op1 能人 **granary=0**（pool 永 54-61，填不起）；plains op1 granary **1487-1991**（滿）。
- **世界地形**：plains 50 / forest 30 / mountain 20 → **~50% 非 plains**。

## 真因（量+碼，定位你久掛的 🟡）
**食物累積被地形閘住**：
1. **非 plains 據點（半個地圖）food regen 低（3 vs 8）→ 糧倉填不起 → 隊餬口無盈餘**（T18 income==burn、net0、granary0）→ 無盈餘→pop 不長→**爬不了**（攀爬「累積」段斷在此）。
2. **plains 隊（T32）糧倉 1991 滿**→ 健康。地形決定能不能累積。
3. **T3**：其實**立國了（rung 0→3）**！但隨後失據點（`[CrudeCamp]` 反覆重紮）pop 25→2 崩 → 攀爬早夭（與餓無關，是失據點 transient；另一條）。

→ **這就是「經濟底 in-vivo 沒真站穩」的真根**：不是食物機制壞，是**特化地形（forest 木材/mountain 礦）的隊該「賣特產換糧」的 trade loop 沒閉**——T18 卡 `return_home` 乾耗空糧倉，**沒去交易木材換糧**。設計上 forest 隊本該賣 material 買 food（買糧 option/市集都在），實際沒發生。

## 這也接通你久掛的 🟡（履約 flaky / 經濟底）
特化→交易→換糧 = 經濟底閉環的核心。它沒閉 → 半個地圖的隊餬口/餓 → 攀爬「累積」段全斷。**(a) 攀爬的「累積>損耗」段，損耗不是戰鬥是「非 plains 無盈餘」**。

## 下一步（measure-first，不猜）
真因清楚到「非 plains 隊不交易換糧」。**下一 measure（別猜為何不交易）= instrument T18-型 forest 隊：有沒有 market 可達？有沒有 specie/木材可換？買糧 option 為何沒贏 return_home？**（return_home PRIO 壓過？無市集？無錢？）卡點量出再開經濟底 fix。

## 待你
①認可下一 measure =「非 plains 隊為何不賣特產換糧」（接買糧 option/市集/履約 🟡）？②經濟底 fix 排序——這是 (a) 攀爬「累積」段的地基，比戰不決勝更底（你已定餓死優先）。③戰不決勝（失能-capture）+ G3 Phase E 仍可平行。

不阻塞。P1 留。
