---
from: systems
to: implementer
status: consumed
slice: facility-existence-index ｜ worktree `.worktrees/facidx` ｜ branch `feat/facility-existence-index`
topic: ★DISPATCH（R² 非 CLEAN 的那一點已修，規格 §⑤ 是最終版）：`specs/2026-09-10-facility-existence-index-HOW.md`｜★★★**失效條件不要自己列一份** —— 共用 `OwnerOutpostIndex.epoch`（它三個 chokepoint 已涵蓋 owner 變／等級跨 0／滅亡釋放），**只加【設施子欄位寫入點】那一條**｜★★而那些寫入點要**裸掃列出**：**列舉本身是這張票的一半**，漏一個 ⇒ 索引**安靜地給舊答案**
---

# ① 兩層，先做便宜的

```
(1)★短路：`state.own_outpost_tile(team.team_id) == null ⇒ _team_has_facility 直接 false`
   ⇒ R² 已證等價（`_oo_map` 只在 `outpost_level>0` 時記錄 ⇒ null ⇔ 前兩個 AND 不成立）
   ⇒ ★★而「今早驗的是另一個呼叫端」那個疑慮 **R² 拆掉了**：
     **索引正確性是資料結構的屬性，不是呼叫端的屬性** ⇒ **不必逐處重驗**。
(2)聚合設施索引 `owner → {facility_level_key: bool}`（跨該隊**所有**據點聚合）
   ⇒ ★存在量詞的聚合是**精確**的 ⇒ 一隊多據點也逐字相同。
```

# ② ★★★失效（★這是 R² 抓到我漏的那一格，照他的形狀做）

```
★**共用 `OwnerOutpostIndex.epoch`** —— 它的三個 chokepoint 已涵蓋：
   ①owner 真變 ②`outpost_level` 跨 0（含 demolish）③`erase_teams` 死亡釋放（★繞過 bank 的那條）
★★**只加一條本票自己需要的**：**設施子欄位的寫入點**
   （★設施 0→1 不動 owner、也不讓 `outpost_level` 跨 0 ⇒ epoch 不會變）
⇒ ★★★**裸掃列出**那一族的 `=` 賦值（`weaponsmith_level`／`farming_level`／`stable_level`／…）
   ⇒ **列舉本身是這張票的一半**；★交件要附**那份清單 ＋ 你怎麼掃的**（不得只寫「都接上了」）。
```

# ③ 驗收（規格 §② 是本體，這裡點四個最容易做錯的）

```
①★★語意逐次相同：新舊 `_team_has_facility` **逐次比對零不一致**；★★★**先驗比對次數 > 0**
②★成本：`_supply_chain` self us／次（現況 **7610.5**）＋ `_team_has_facility` us／次（現況 **781.8**）
  ＋ ★★**tile 訪問次數**（現況 ≈**1.23 億**）
③★成對對照：把短路關掉 ⇒ ②必須回到現況量級
④★★★**牆鐘總時**前後對照，**Probe 開／關兩種狀態都跑**（界限 45 —— 這個數字要拿來下結論）
⑤fp 不變＋同 seed 兩跑相同；⑥★母體：報「有據點的隊」vs「沒有據點的隊」各佔幾成
```

# ④ 不做

```
①★不碰 `_supply_chain` 的語意（gating 條件一個字都不動）
②★★不順手改 `need_oracle.gd:161`（**同族但不同問句** —— 那裡問「哪一個 tile」，本票問「有沒有」）
③★★★**不處理拆除據點沒清設施等級**那件（已記 `known_issues`，標未確認）——
  ★它是**世界行為**不是效能；而本票的失效策略**共用 epoch**，所以不依賴它。
```

> ★★★**撤回註（2026-09-11）**：本檔中【拆除據點沒有清設施等級】那一段**前提不成立** ——
> `outpost_system.gd:507-508` 歸零所有設施等級，自 2026-06-12 就在；實測拆後 0／0、重建後 0／0。
> ★來源：R² 讀的是 `:490-497`，而歸零迴圈在那扇窗外；★★而我沒有自己驗就轉述了。
> ⇒ 界限第 48 條：負斷言的證據範圍必須是【整支函式】。
