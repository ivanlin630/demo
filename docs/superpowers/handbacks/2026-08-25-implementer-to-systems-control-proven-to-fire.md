---
from: implementer
to: systems
status: consumed
slice: means-end-brick
branch: feat/means-end-brick @ 987a8b57 (pushed)
topic: ★陽性對照裝好【而且被證明會叫】——自測(故意不開 Probe)那輪真的吐 VOID;★★兩個對照分開的價值:ledger 19991 / probe 0 直接指出【是哪一套儀器沒開】,不是含糊的「儀器有問題」;★★★而自測那輪的 rate_via_authority = 0 正是你說的那台假陰性機器,若無對照會被讀成「新接線是死 code」
---

# 陽性對照裝好，**而且它被證明會叫**

## §1 兩種模式的實測對照

**正常**：
```
manufacture.rate_via_authority = 7　★非零
陽性對照 ledger=19991 / probe(collect.gather_ran)=275　★兩者非零＝儀器確實在跑
★PASS
```

**自測（`FALSIFIER_SELFTEST=1`，故意不開 Probe）**：
```
manufacture.rate_via_authority = 0　⚠ 0 ＝這段 code 從未執行，fp 不變毫無意義
★★VOID 儀器對照失效，本輪【整份作廢】（不得讀成 PASS）
    ledger 對照 = 19991　(ledger 是開的)
    Probe  對照 = 0　　　(★Probe 沒開，抓到了)
```

★★**這就是你說的那台假陰性機器的實體**：**沒有對照的話，那個 `= 0` 會被讀成「新接線是死 code」** ——
★**一個完全錯誤、但看起來很有說服力的結論。**

## §2 ★兩個對照【分開】的價值（我原本想只放一個）
`ledger 19991 / probe 0` ⇒ ★**直接指出是【哪一套儀器】沒開。**
**若只有一個綜合對照，輸出會是含糊的「儀器有問題」** —— **那還要再查一輪才知道往哪修。**
★**理由**：`driver_ledger` 與 `Probe` 是**兩個獨立開關**，**一個開一個關是完全可能的狀態**（正是自測那輪）。

## §3 ★★★守衛本身也要被驗
★**一個從沒 fire 過的守衛，跟沒有守衛一樣** ——
所以 `FALSIFIER_SELFTEST=1` **不是 debug 便利開關，是【對照的對照】**。
★**它保證的是：下次真的沒開 Probe 時，床會【自己喊】，而不是靠人記得。**

★**這與你「看門狗自己也需要被看門」是同一句話的可執行版本。**

## §4 現況（八條 ＋ 追加全清）
| | |
|---|---|
| branch | `feat/means-end-brick` @ **`987a8b57`**（已 push）|
| 八條交付閘 | ✅ 全完成（第 5 條兩證據齊全）|
| 追加①`kind` 必填 | ✅（29 呼叫點、`Parse Error 0`）|
| 追加②分群鍵 `(kind, 資源名)` | ✅ |
| ★陽性對照 | ✅ **且經自測證明會叫** |
| headless／憲法／det×3／lineage | ✅ 全綠（fp `5c1fa2fc…` ＝ merged main base）|

★**唯一仍待你裁**：**磚還沒接進決策**（沒有 production 路徑呼叫它 ⇒ acceptance ① 不可能達成）。
**接線會改變決策行為，所以我不自己動。**
