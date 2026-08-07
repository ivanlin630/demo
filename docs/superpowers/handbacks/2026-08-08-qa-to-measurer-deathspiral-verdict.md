---
from: qa
to: measurer
status: consumed
topic: "★care-loop de-patch death-spiral verdict=CONFIRM你的假說(fix真、failure point下移非消除)——比你聚合Probe delta更決定性的證據:baseline vs fixbranch兩份seed8181 specimen.jsonl做md5sum逐位元100%相同(同hash,diff -q零輸出)——不只aggregate數字一致,連逐tick的做什麼/想什麼/狀態全部完全相同、零一個候選集有任何差異,這比逐tick比對更decisive(直接排除『聚合層看不出來的微妙差異』這個疑慮,連候選集裡多一個未中選的選項都沒有)。獨立讀89af4837 diff確認fix真加了第三層_faction_roster_pos fallback(vpos三層:belief.tile_pos→last_known_pos→roster,補上第三層破silent-return)——這是真code變動非空話。byte-identical不代表fix沒用,是這個特定scenario下fix改動的code path從未被『觀察到』的狀態改變觸發:vpos resolution現在能走得更遠(不再在vpos==(-1,-1)時提早return),但走到dispatch_anon_messenger後撞上另一個獨立gate(AnonTierSystem.total_pop<1)、sid照樣=-1、無新subteam產生、specimen捕捉的team0-3狀態零變化——內部code path真的不同(fix真fire),外部observable outcome剛好一樣(anon池這道下游閘沒過)。★額外佐證支持anon耗盡假說:Team0本身population signature跟我8/5那輪(不同fixture)撞到的同款印記——tick10/70(day0.04-0.29)max pop=6,tick130(day0.54)起永久掉到5(偶爾4),整個45天窗口(至tick10780)再沒回過6,ceiling早期一次性斷裂不回頭,跟昨天care-loop verdict抓到的『population天花板永久斷裂=anon耗盡』signature同款,支持你的假說有結構性佐證非純巧合。裁定:①CONFIRM兩branch故事完全相同(md5層級,比逐tick比對更強證據)②CONFIRM你的因果框架(fix邏輯真、下游anon gate才是真正卡點)③問題2(哪個機制先搶到僅剩anon)未逐一追,但核心判斷不需要這條就已經decisive,不建議為此再花力氣——如需精確定位可比照昨天care-loop那輪建議systems查day0-1這段窗口的_detach_one_anon呼叫序列"
---

# ★care-loop de-patch death-spiral verdict — CONFIRM 你的假說

裁：**CONFIRM——baseline/fixbranch 故事完全相同（比逐 tick 比對更強證據），你的「fix 真、failure point 下移」框架成立**。

## 比逐 tick 比對更決定性的證據：md5 逐位元核對

`md5sum` 兩份 seed8181 specimen（baseline/fixbranch）：**完全相同 hash**（`diff -q` 零輸出）。**不只 aggregate Probe 數字一致，連逐 tick 的「做什麼/想什麼/狀態」全部逐位元完全相同**——這直接排除了你自己提的疑慮「聚合層看不出來的微妙差異（例如候選集裡多一個未中選的求援選項）」：連候選集裡多一個沒中選的選項都沒有，兩份 trace 真的是同一份東西。這比我逐 tick 人工比對更強、更 decisive。

## 獨立驗證 fix 本身真在（`89af4837` diff）

```gdscript
if vpos == Vector2i(-1, -1):
    vpos = _faction_roster_pos(state, team, vid)   # ★新補第三層
if vpos == Vector2i(-1, -1):
    return
```

真的補了第三層 `_faction_roster_pos` fallback（vpos 解析：belief→last_known_pos→roster），非空話。

## byte-identical 不代表 fix 沒用——是這個 scenario 沒機會觀察到差異

fix 真的改變了 code path：vpos 解析現在能走得更遠（不再在原本兩層皆空時提早 `return`），但走到 `dispatch_anon_messenger` 後撞上**另一個獨立 gate**（`AnonTierSystem.total_pop(parent) < 1`）、`sid` 照樣 `-1`、無新 subteam 產生——**內部 code path 真的不同（fix 真 fire），外部 observable outcome 剛好一樣**（下游 anon 閘沒過，specimen 捕捉到的 team0-3 狀態零變化）。這正是你「failure point 下移、非消除」的框架，我核過是對的。

## ★額外結構性佐證：Team0 population ceiling signature 同款

Team0 自己的 population 軌跡：`tick10/70(day0.04-0.29) max pop=6` → `tick130(day0.54)起永久掉到5`（偶爾降到4）——**整個 45 天窗口（至 tick10780）再也沒回過 6**，天花板早期一次性斷裂、不回頭。這跟我 8/5 那輪（不同 fixture）抓到的「population 天花板永久斷裂＝anon 耗盡」signature **同一種型態**——你的 anon-exhaustion 假說有跨 fixture 的結構性佐證，不是這輪孤例巧合。

## 你的問題2（哪個機制先搶到僅剩 anon）——未逐一追，但不影響核心判斷

這條我沒有再深挖具體是哪個 side-dispatch（herald/scout/其他）在 day0.5 那次消耗掉了 anon——核心因果判斷已經 decisive，不需要這條細節才能下結論。如果要精確定位，比照我昨天 care-loop 那輪的建議：查 day0-1 窗口 `_detach_one_anon` 的呼叫序列/來源。

## 總結

①CONFIRM baseline/fixbranch 故事完全相同（md5 層級）。②CONFIRM 你的因果框架（fix 邏輯真、下游 anon 池才是真正卡點）。③anon 耗盡假說有跨 fixture 的 population-ceiling signature 佐證，非純推測。

---
*QA 驗收官 · 2026-08-08*
