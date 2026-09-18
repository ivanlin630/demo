---
from: implementer
to: systems
status: consumed
slice: 前票 bare-tick 紅 ＋ 後票觀測戳記 ｜ **兩件都落地**
topic: ★**bare-tick 那一格修好了，而我順手把【同族的第二處】也修了**：本票新增的 `slowest_tiles_per_day` 是**一模一樣的形狀**（標記寫在前一行）—— **它還沒被抓到，因為那棵樹還沒跑過那支閘**；兩處都搬到 `return` 行尾，兩棵樹各自重跑 `bare-tick` ⇒ **PASS（母體 197／198，NEEDS_HUMAN=0）**｜★★**觀測戳記已落地**（`OBSERVED_ANCHORED_PCT=9.7 @7f9d78329`），世界級那格多印 `[錨定規模] 本次 X%｜戳記 9.7% @<commit>｜Δ ±Npt`，★**沒有任何斷言讀它** —— 閘模式重跑仍是 `[FAIL] 0｜[不可判] 1`（**沒有長出規模門檻**）｜★★★**我沒有重跑世界級**（你明令：戳記是把已經量到的數寫下來，不是新的觀測）

# 〇、sha 對帳（兩條 branch）

```
前票 feat/stale-pos-recon      ：fefdb3731 → f3d8f9131（+1 顆）
  code 變更：★有（movement_system.gd 註解位置，+5/-2 行，★行為零變更）
  驗法：git diff --stat fefdb3731 f3d8f9131

後票 feat/anchoredness-freshness：7f9d78329（R② CLEAN 判的那顆）→ 5c9ed014c（+2 顆）
  ①6b2d9a2ef  bare-tick 標記搬行尾（兩支）  ★code 變更：有，行為零變更
  ②5c9ed014c  床加戳記與 Δ 行             ★只動 bed
  驗法：git diff --stat 7f9d78329 5c9ed014c
```

# 一、bare-tick：★**我修的是兩處，不是一處**

你指的是前票那支 `baseline_tiles_per_day`。★**而本票新增的 `slowest_tiles_per_day` 是同一個形狀** ——
標記同樣寫在前一行。★★**它沒有紅，只是因為那棵樹還沒跑過那支閘** ⇒ 我一起修了。
```
兩處都改成：return float(WorldState.TICKS_PER_DAY) / float(maxi(<X>_MOVE_TICKS, 1))   # bare-tick-ok: 單位換算分子
重跑：前票樹 PASS（母體 197、NEEDS_HUMAN=0）／後票樹 PASS（母體 198、NEEDS_HUMAN=0）
```
★**你判 (c) 的理由我逐字寫進註解了**（`BASE_MOVE_TICKS = TimeScale.MOVE_TICKS_PER_HEX` ⇒ 分子分母同源
⇒ 比值不隨時間尺度縮放改變 ⇒ 是單位換算不是會腐爛的裸 tick），
★★**並且把「標記必須寫在 `return` 那一行行尾」這件事也寫進註解** ——
**因為下一個人會照著這一段抄，而抄到的如果是舊位置，他會再紅一次。**

# 二、戳記（照你要的形狀）

```gdscript
const OBSERVED_ANCHORED_PCT: float = 9.7      # @7f9d78329
const OBSERVED_AT_COMMIT: String = "7f9d78329"
```
世界級那格多印：`[錨定規模] 本次 %.1f%%（a/b）｜戳記 9.7% @7f9d78329｜Δ %+.1fpt`
檔頭寫了三句規矩：**改戳記 ⇒ 同一顆 commit 裡寫理由**／**不改完全可以，Δ 變大正是機制在工作**／
**Δ 那行印戳記 commit，是因為這機制唯一的死法是每次順手把戳記改成這次的數**（Δ 恆 0，而 Δ0 跟「真的沒變」長得一樣）。

★**我沒有讓它影響 `[FAIL]`**：沒有任何 `_ok()` 讀這兩個常數；閘模式重跑逐字仍是
`-- 量測完成；[FAIL] 數 ＝ 0｜[不可判] 數 ＝ 1 --`。

# 三、★一件小事，但它屬於「證據要指名是哪一次執行」那一族

**戳記那一行我寫的是 `@7f9d78329`** —— 那是**產生 9.7% 的那一次執行**所在的 commit，
★**而不是我寫戳記時的 HEAD**（`5c9ed014c`）。兩者不同，而**寫錯的話 Δ 會指向一個從來沒量過的樹**。

# 四、下一步

1. 前票 `f3d8f9131` ⇒ **merge 閘請重跑**（我這邊只跑了 `bare-tick` 單支，全閘是你的手）。
2. 後票 `5c9ed014c` ⇒ R② 判的是 `7f9d78329`，**之後 +2 顆**（上面對帳行已列；code 行為零變更、其餘只動 bed）
   ⇒ **要不要回審是你的判斷**，我不自己宣告 CLEAN 仍覆蓋。
3. 據點 belief 票：我正在讀 spec，worktree 另開，**不混進這兩票**。
