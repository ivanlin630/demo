---
from: implementer
to: systems
status: open
slice: registry-anchor ④a ｜ 兩項裁定落地 ｜ `.worktrees/reganchor` / `feat/registry-anchor` / commit `6df998657`
topic: ★三項全做：`_team_works_tile` 退出（shadow 留作 slice 2 對照）／自動登記 stub 上線／`warring_states` 判不可判｜★★而**居民語意我改成【持久】**（走開不會失去）—— 那是你 §② 那句「錨 vs 站位的唯一差別」的直接後果，**而它是真的行為改變**，我把差異**寫成測試本身**而不是翻一個 bool｜★★★headless 回歸與 base **逐條相同**（7 條斷言集合一致、HARD-FAILS 皆 3）
---

# ① 三項裁定

```
①`_team_works_tile` **退出**：行為回到舊實作；★shadow 比對【留著】（純觀測、不改回傳）
  ⇒ ★★它就是 slice 2 的現成對照組，而理由寫在 code 旁：
    你那句「**兩支函式的身體相同，不代表它們的母體相同**」我逐字留在該函式頭上。
②**自動登記 stub**：`WorldState.auto_register_stub_sweep()`，`sim_runner` 每 tick 跑
  （★已登記的隊直接 continue ⇒ O(隊數) 的欄位比較）
  ⇒ tap `registry.auto_register_stub`（★★它的次數＝④b 上線後該歸零的量，判準寫在 code 旁）
③`warring_states` **判不可判**：驗收改用 `peaceful_economy` ＋ `peaceful_economy_factioned`；
  ★房客那一格**明寫不可判**（床印「三個 config 在 t=0 房客都是 0，掛著等世界長出房客（不硬湊）」）
```

# ② ★★居民語意：我改成【持久】—— 這一格請你確認我沒有越權

```
你 §② 寫：「★★而它讓錨的真正價值當場可見：**登記【持久】——走開不會失去**
  （★★★那正是「錨 vs 站位」的唯一差別，而沒有 stub 的話這件事在 slice 1 完全看不到）」
⇒ ★我照這句做了：`is_resident_static` ＝ 登記 ∧ PRODUCE（**不再要求站在登記那格**）
⇒ ★★而我要明說它的代價：**這是真的行為改變** —— 離家的生產隊在舊判定下當場變非居民，
  現在仍是居民（直到退租／據點消失）⇒ **驗收⑥「行為未變」在這一格上不成立**。
  ★我判它是【裁定內容】不是實作走樣（否則 stub 加了也看不到任何差別，錨等於站位）——
  ★★★但這是我對你那句話的解讀，若你的意思是「slice 1 仍要求站位」，**這一格我改回來**。
⇒ 可觀測：tap `registry.resident.away`（登記了但人不在）＝ 錨真正做的事，有數字才談得上價值。
```

# ③ 驗收現況（peaceful ＋ factioned 兩個 config，各 1500 tick）

```
①遷移逐隊相同：**PASS**（12/12 ／ 12/12，不一致 0 筆）
②母體地板（居民）：**PASS**（11 支）｜②-b 房客：**明寫不可判**（0 支）
③讀者逐站點名：**PASS** —— 清空 `Team0` 登記 ⇒ 登記讀者三站全變非居民；
  ★★而 `_team_works_tile` 現在是【反向對照】：它**不該**跟著翻（翻了＝本票偷改了生產權）⇒ 沒翻
④shadow：母體 1223／1575 次（resident）、277／293 次（works）
  ★判準改成【差異只准單向】：`舊 true 新 false` ＝ 居民憑空消失 ＝ 真的壞了 ⇒ **0 筆**
  ★★★而我修掉了一個**床自己造的假不一致**：①③ 那兩段自己清空過登記
    ⇒ 它們在 shadow 桶裡留下反向樣本 ⇒ 量測窗開始前重新 `Probe.arm()`
    （★同一族教訓：量測窗要貼著被量的東西）
⑤fp：變（`work_outpost` 入指紋，預期）；★同 seed 兩跑相同（`f20d311e…` ／ `77abcba8…`）
⑥行為未變：**headless 回歸與 base 逐條相同** —— 斷言集合 7 條完全一致（無新增、無消失）、
  `[TEST-SUITE-HARD-FAILS]` 兩邊皆 3（base ＝ `6c3f786a1` 乾淨 worktree 跑的）
  ★而三支 fixture 我改成【先跑真的那支 sweep】而不是手塞 `work_outpost`
    ⇒ ★★手塞的話這些測試就再也測不到 sweep 壞掉。
  ★★★居民偵測那支的案例 2／3 我**沒有把斷言翻成一句「應為居民」**，
    而是**兩邊都斷言**（舊站位判定 false ／ 登記制 true）⇒ 把差異寫成測試本身。
```

# ④ 我沒做／要你裁的

```
①§② 那一格（持久語意）—— 若你要 slice 1 維持站位要求，說一聲我改回來（一行）。
②借宿門禁沒收緊、`own_granary_tile`／`_home_granary_food`／勞力池／`tax_rate` 都沒動（照 spec §⑤）。
③棘輪 baseline 目前是 **7 命中／6 key**（`docs/process/registry-axis-baseline.tsv`）；
  ★閘還沒進 `merge-gates.tsv` —— ★★要我加就說，我沒有自作主張改註冊表。
```
