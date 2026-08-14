---
from: systems
to: blueprint
status: open
topic: "[founding arc證據包CLOSE(強力坐實arc問題陳述)+★crash排序決策須你/用戶裁·①證據(seed1337 3月baseline):founding=碎片自救spam坐實(253次觸發88.9%pop1-3、median=1、0%pop11+=走投無路1-3人就地紮營非殖民)+27.8%outpost卡死團id(82/295、S1a問題真實)+takeover現況2.6%camp96%(S1修後應往takeover爆、branch比對中同輪出gate②③)→驗證settlement arc問題陳述+餵§4 overflow_split決策化rationale·②★crash排序決策:own_granary_tile Nil crash我升級=量測完整性blocker(measurer新證據onset day15非tail-end=mid-sim真null-caller、推翻teardown假說;風險非cosmetic=mid-sim null→effective_food靜默漏算糧倉→可能污染食物決策/量測憲法級;blocks 12mo arc validation深根在12mo才顯連day15都撞)→修法pin-root非盲guard(guard遮silent undercount違症狀vs根)·★決策:S1 merge後slot一investigation-slice pin day15 null-caller(先解量測地基)vs續S2(L0階梯)?=arc排序你/用戶裁·③tap-gap note:outpost_owner reason從未可觀測(每tick無條件clear_driver_ledger丟棄、measurer臨時tap才挖出)=permanent tap候選(觀測性憲法feedback_full_transient_observability)·S1 gate branch比對measurer在跑、綠我merge·地基KEEP"
---

# founding arc 證據包 CLOSE + crash 排序決策

## ① founding 證據（seed1337 3月窗 baseline、強力坐實 arc 問題陳述）
- **founding=碎片自救 spam 坐實**：253 次觸發，**88.9%(225) 是 pop1-3 碎片、median=1、僅 6.3% 達 pop7-10、0% 達 pop11+** → founding 絕大多數是走投無路 1-3 人**就地紮營自救**、非有組織殖民。
- **鬼城 owner 現況**：total 295，**27.8%(82) 卡死團 id**（S1a 問題真實、3月窗 82 推 12月~300 軌跡合理）、alive 61.7% / empty 10.5%。
- **takeover 現況小眾**：151 筆 set_owner reason = camp 96.0% / **takeover 2.6%** / capture 1.3% → 現況撿現成路是小眾（吻合 ticket「~30 可認領」量級）。**S1 修後應往 takeover 顯著位移**（branch 比對中、同 S1 gate②③ 一輪出）。
- **→ 驗證 settlement arc 整個問題陳述**（碎裂→non-viable 小隊→spam camp→鬼城堆積）+ 餵 **§4 overflow_split 決策化** rationale（碎片機械源坐實）。這是你 WHAT arc 的證據地基，供你/用戶信心。

## ② ★crash 排序決策（真需你/用戶裁）
`own_granary_tile(state=Nil)` crash——**我升級=量測完整性 blocker**（known_issues:77 已更）：
- **新證據推翻假說**：measurer 見 onset **day15（非 tail-end/teardown）**、6mo/2mo 兩窗撞、被 timeout 殺 → **mid-sim 正常運行期真 null-caller**（非 teardown stale-ref）。
- **風險非 cosmetic**：mid-sim null-state → own_granary 返 null → team `effective_food` **靜默漏算自家糧倉** → 可能污染食物決策/量測（[[feedback_full_transient_observability]] 憲法級）。
- **修法=pin-root**（runtime trace 定位 day15 null-caller）**非盲 guard**（盲 `if state==null:return null` 遮掉 silent undercount=症狀補丁遮根）。
- **★決策**：**S1 merge 後 slot 一 investigation-slice pin day15 null-caller（先解量測地基，12mo horizon 才驗得了 arc 深根）vs 續 S2（L0 階梯）**？= arc 排序，你/用戶裁。我建議：**先 pin crash**（否則 12mo validation 撞牆、後面 S2/§4 效果都量不到），但這是排序 call 歸你。

## ③ tap-gap note（觀測性）
measurer 挖出：`field=="outpost_owner"` 的 driver-ledger entry **每 tick 被無條件 `clear_driver_ledger()` 丟棄、從未被 tap 過** → outpost_owner reason 在任何既有 dump 都不存在（measurer 臨時 tap 才挖出、待 revert）。=**permanent tap 候選**（[[feedback_full_transient_observability]]：新 decision/state 必接 tap）。順帶記，非本輪阻塞。

S1 gate branch 比對 measurer 在跑，綠 → 我 merge。地基 KEEP。
