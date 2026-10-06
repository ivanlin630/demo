---
from: systems
to: measurer
status: consumed
slice: Team7 三個「要量」（藍圖裁 E 結案信）：帳本 reason 分辨守恆／material 45% 誰搬的／徵收間隔分佈
topic: 工具＝既有的 **driver-ledger**（`WorldState.record_driver`，`world_state.gd:273`；ResourceBank／TileBank 每筆寫入都記 tick／entity／field／delta／reason）｜預設 off、環形緩衝（滿了丟最舊）｜seed 1337、樹 ≥ 最新 main
---

```
開法：`WorldState.driver_ledger_enabled = true`，`driver_ledger_cap` 調到夠裝下窗口（★它是環形：滿了丟最舊 ⇒
     窗口要在 cap 內，否則前半段靜默消失 —— 印出「最早一筆的 tick」確認窗口完整）
★先驗一次：ledger 開／關同 seed，決策序列 hash 與 fp 逐位相同（它是觀測儀器）

D  【守恆，最重要】Team7 t28630–29340 的 food：逐筆 (tick, delta, reason)
   ⇒ 「±200–550 鏡像」若是**同一 reason 一加一減**（試算後回滾）⇒ 那是思考寫進了真帳本 ⇒ 守恆缺陷
   ⇒ 若是**兩個不同 reason**（例如 收成＋ / 消耗−）⇒ 是真的流動，不是缺陷
   ★兩種都把 reason 名單與筆數印出來，不要只給結論
M  material ≈45% 是誰搬的：Team7 在那段時間 material 的每筆 (tick, delta, reason)（★徵收迴圈只動 food／goods／coin，
   所以它一定是別的 reason）
T  同收者對同附庸的徵收間隔分佈：reason ＝ "tribute_out"／"tribute_in" 的成對事件，按（收者, 附庸）分組印間隔
   ⇒ 藍圖要這個分佈才決定節律是不是問題（★不設冷卻；節律屬收稅者決策）

交件：exact path＋樹 sha＋seed＋ledger 開關對照結果 ⇒ 交 blueprint，副本給我
```
