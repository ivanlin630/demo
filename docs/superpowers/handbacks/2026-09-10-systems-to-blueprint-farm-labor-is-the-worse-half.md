---
from: systems
to: blueprint
status: consumed
slice: 白工射程補查（用戶戳材料/食物之分）
topic: ★用戶是對的：**材料不中白工**（走 gained → 一般稅 split，不進地主公庫）｜★★★而你問的農業版**存在，而且比採集版更嚴重**：`labor_system.gd:72-78` 的勞力池**零 owner 檢查、零 faction 檢查** —— 房客【站著就捐出勞力】放大地主農田產出，而 `fyield` 只有 owner 收得到｜★★「吃」那條明講：**房客一粒米都吃不到**，連同 faction 都不放行 ⇒ **現況是單向的**
---

# ① 射程收窄（★你的對帳我照收）

```
材料 ⇒ 私產＋稅 ⇒ **不中**。
白工射程 ＝ **food ＋ PUBLIC_RESOURCES，且僅在【站在地主據點格上採收】時**（`resource_system.gd:413-418`）。
```

# ② ★★★農業版：**它更徹底，而且射程更寬**

```gdscript
resource_system.gd:131   if tile.farming_level > 0 and tile.outpost_owner == team.team_id:
                             var flabor := LaborSystem.farm_labor(tile)      # ← 全格勞力
labor_system.gd:72-78    for tid in state.teams:
                             if t.tile_pos == tile.tile_pos and TAG_PRODUCE in t.tags:
                                 pool += labor_pop(t)        # ★★★零 owner／零 faction 檢查
```

```
⇒ ★房客的人力進池 ⇒ 放大 `farm_labor` ⇒ 放大 `fyield`，而 `fyield` **只有 owner 收得到**。
⇒ ★★**採集版至少是房客自己選擇去採；農業版是【站著就捐】** —— 完全被動，它沒有做任何決定。
⇒ ★★★而它**連 faction 都不檢查** ⇒ **任何** PRODUCE 隊（含敵對）站在那格都在替地主種田。
  ★這一條我判它比白工本身更值得你看：**它讓「站在哪裡」直接等於「替誰工作」，而沒有任何同意**。
```

# ③ 「吃」那條（★供養契約的地基，明講）

```
`own_granary_tile`（`resource_system.gd:584-588`）＝ 腳下 ＋ `outpost_owner == 自己`
⇒ 有效糧 ＝ 私產 ＋ **自家**糧倉；消耗端同一支（`:601`／`:614`）。
⇒ ★★★**房客一粒米都吃不到**，而且**連同 faction 都不放行** ——
  ★對照：代工投料那條（`_team_works_tile`）**明文放行同 faction**，
  ★★**吃這條沒有對應的放行** ⇒ **出力放行、取食不放行 ＝ 現況是單向的**。
⇒ 這就是「供養契約」要填的洞，而它現在**不是缺一半，是缺回饋的那一整邊**。
```

# ④ 誠實限

```
①★仍是【讀 code】不是跑世界：農業版真實發生多少，要看有多少隊站在別人村格上且帶 PRODUCE ——
  ★★而那個數字**現在拿得到**（量測員的居民/位置卷已經在量共址），我沒有另外要它。
②★★★勞力池那格我只讀了 `compute_alloc` 的母體迴圈；
  **`labor_pop(t)` 內部有沒有別的條件我沒讀** ⇒ 標未驗。
```
