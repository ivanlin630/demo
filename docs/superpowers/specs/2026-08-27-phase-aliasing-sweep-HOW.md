# 相位混疊掃描（HOW）—— `current_tick % K` 型 gate 的構造性一次清

**溯源**：S3 挖出 `GOAL_CHECK_INTERVAL` 在 far pass 上永不 fire（`4320 mod 600 = 120`）。
**blueprint 裁**（2026-08-27）：**整除混疊族 ＋ 相位逃逸併成一次構造性掃；修形統一用【相位無關式】。**

## ★★★病的完整形狀（★兩層，缺一層就會只修一半）
```
①★整除混疊：`current_tick % K == 0` 只在【宿主 pass 的評估 tick】恰為 K 的倍數時命中
   ⇒ K 不是宿主 cadence 的倍數 ⇒ ★★該 pass 上【永不命中】(不是機率低,是二元)
②★★★而既有的 LOD 補償【不算數】：`LOD_BOTH` + `trials` 補的是【跑幾次】(count)
   而 `% tick` 問的是【哪一個 tick 跑】(phase) ⇒ ★★次數補償對相位型 gate 無效
   ⇒ 補了次數,相位還是錯的,★★★而且沒有任何症狀
```
> ★**一句話**：**相位型 gate 逃過了我們所有既有的節律補償，而它安靜。**

## ★★母體（★普查不推導；★★指令寫在這裡，重跑得同一個數）
```bash
grep -rnE "current_tick *% *[A-Za-z0-9_.]+" scripts/simulation/ --include=*.gd   | grep -vE "^\s*#|Probe\.|\"mod_"
# 2026-08-27 實測 = 23 筆
```
★**四桶，互斥且窮盡，加總必須 ＝ 23**：
| 桶 | 定義 | 處置 |
|---|---|---|
| ★**(a) 相位有風險** | 宿主 pass **不是每 tick**，且 `K mod 宿主cadence != 0` | ★★**改相位無關式** |
| **(b) 宿主每 tick** | 宿主就是 tick loop 本身（`sim_runner` 那幾顆） | ★**安全，但要標記**（宿主若日後改成 cadence，它會靜默變成 (a)） |
| **(c) 恰好整除** | 宿主非每 tick，但 `K mod cadence == 0` | ★★★**仍要改** —— **它是【靠巧合活著】**，改宿主 cadence 就死 |
| **(d) 非 gate** | 不是節律判斷（如 `% TICKS_PER_DAY` 拿來算「一天中的第幾刻」） | 不動，標 `n/a` |

★★★**(c) 是本票的重點**：**「現在能跑」不是判準，【為什麼能跑】才是** ——
**`GOAL_CHECK` 舊值 600 就是 (c)：`600 mod 600 = 0` 靠巧合活了很久，重錨一改就死。**

## ★★★★判準：**每一顆都要回答「它的宿主 pass 是誰、cadence 多少」**
★**這一格答不出來的，不准判成 (b) 或 (c)** —— ★★**「我沒查到宿主」與「宿主是每 tick」長得一樣，而它們的風險相反。**
⇒ ★★★**答不出來 ⇒ 進 `NEEDS_HUMAN`，跟裸 tick 閘同一個判準形狀（沒人判過的形狀 ≠ 0 就 FAIL）。**

## ★修形（統一，blueprint 定）：**相位無關式**
```gdscript
# ✅ 累積式（首選）—— 不問「現在第幾 tick」,只問「距上次夠久了沒」
if state.world.current_tick >= next_eval_tick:
    next_eval_tick = state.world.current_tick + INTERVAL
# ✅ 錨定 offset（需要 per-actor 錯峰時）—— 相位由 actor id 決定,不由宿主 cadence 決定
```
★**禁**：**把 K 調成宿主 cadence 的倍數** —— ★★**那是把相位依賴藏進一個看起來合理的數字，下次改 LOD cadence 它再死一次，一樣無症狀。**

## ★★驗收
```
①★母體對帳 23 = (a)+(b)+(c)+(d)，且 NEEDS_HUMAN = 0
②★★每顆 (a)/(c) 修完，要證【它在宿主 pass 上真的按 INTERVAL fire】——
   ★per-actor 觸發間隔中位數 = INTERVAL（同 S3 主判準的形狀,★★不是「事件率變了」）
③★★★fp：必變（相位改了＝世界不同）——★交件先聲明走的是哪一種
④★陽性對照：把某顆的宿主 cadence 臨時改成不整除 ⇒ 掃描器必須把它從 (c) 移到 (a)；還原 ⇒ 移回
⑤★憲法閘 / 裸 tick 閘 / headless Q1
```

## ★誠實限
- ★**本票不改任何 cadence 的【長度】** —— **只改【判斷形狀】。★★任何長度變動都要單獨提出，不得夾帶。**
- ★★**(b) 桶不改但要標記** ⇒ **做完之後「相位安全」是【當下】為真，不是永久** —— 宿主 cadence 是活的。
