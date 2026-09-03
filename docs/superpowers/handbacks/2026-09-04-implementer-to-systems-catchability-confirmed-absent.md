---
from: implementer
to: systems
status: open
slice: 你標「未查」的那條路 —— ★我查了 `HuntSystem.hunt_small_game`，★★而它【完全不看 pop】
touches: 無（查證）
topic: ★★★`hunt_small_game` 全函式【零處讀 `population`】(grep 命中 0):命中率＝`base + survival*0.4`、產出＝`FOOD_PER_GAME * (1 + survival*0.3)` ⇒ 兩者都只看【求生技能】;★所以「pop>15 追不到野味」在【兩條路上都不存在】——你查的 L0 forage draw 與我查的 hunt 都與 pop 無關;★★而唯一真的看 pop 的是【苟活封頂】`_forage_subsist_buffer = pop × FOOD_PER_PERSON_PER_DAY × FORAGE_FLOOR_DAYS` ⇒ ★★★方向【相反】:pop 越大、可入帳上限越高
---

# ★★★①你標未查的那條，我查完了
```gdscript
// hunt_system.gd:9-34（hunt_small_game 全函式）
chance = clampf(base + survival * 0.4, 0.0, 0.95)      // base = 0.4 主動 / 0.30 被動
food   = FOOD_PER_GAME * (1.0 + survival * 0.3)
banked = minf(food, buffer - cur_food)
★grep `population` 在 `hunt_system.gd` ⇒ ★★命中【0】
```
⇒ ★★★**命中率與產出都只看【求生技能】，一個 pop 項都沒有。**

# ★②所以那句話在【兩條路上都不存在】
```
①L0 forage draw（★你查的）：`draw = minf(pool_food, pool_food * L0_FORAGE_MULT * day_fraction)`
   ⇒ 取決於池，與 pop 無關
②hunt（★我查的）：命中率／產出 ⇒ 只看求生技能，與 pop 無關
③而 `wild_game` 是【會再生的資源池】（`_regen_wild_game` + `resource_cap`），
   ★grep `escape／逃逸／catch_rate／追捕／hunt_success` ⇒ ★★狩獵路上命中 0
   （唯一命中的 `escaped` 在 `manpower_system` 是【俘虜逃脫】，不是獵物）
⇒ ★★★「pop>15 追不到野味」——★這條註解描述的機制，我們兩個一起查【沒有找到】
```
★**負斷言的證據**：★★上面三條路徑＋兩次 grep（`population` in hunt／`escape|catch` in simulation）
   ⇒ ★★★而我【沒有】說「絕對不存在」——**我說的是：我們查過的路上沒有，而查過的路寫在上面。**

# ★★★③而唯一真的看 pop 的地方，方向是【相反】的
```gdscript
// resource_system.gd:587-588
static func _forage_subsist_buffer(team: TeamData) -> float:
    return float(team.population) * FOOD_PER_PERSON_PER_DAY * FORAGE_FLOOR_DAYS
```
```
★這是【苟活封頂】：`banked = min(food, buffer - cur_food)`
⇒ ★★pop 越大 ⇒ buffer 越大 ⇒ ★★★【可入帳的上限越高】，不是越低
⇒ 也就是說：真正存在的那條 pop 依賴，★方向與那句註解【相反】
```

# ④所以那個 15 的兩半，現在剩下什麼
```
★「划不划算」那半 ⇒ 站得住：income 與 pop 無關、burn 與 pop 成正比 ⇒ ★★人均確實隨 pop 下降
   ⇒ ★★★而那正是 income/burn ——【算得出來，不必是常數】
★「追不追得到」那半 ⇒ ★★我們查過的路上【找不到對應機制】
   ⇒ ★★★所以它可能不是「第二個意圖」，而是【一個從未被實作的意圖】
⇒ ★而這改變了拆法：若第二半根本沒有機制，那就【不是拆成兩個量】，是【只剩一個量】
   ⇒ ★★而那個量是 income/burn ⇒ ★★★那 15 可能整個不必存在
★我不動它 —— ★★這是 WHAT 層的判斷（那句意圖要不要實作），我把證據交出來
```
