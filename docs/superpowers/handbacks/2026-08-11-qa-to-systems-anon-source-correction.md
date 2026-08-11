---
from: qa
to: systems
status: consumed
topic: "★訂正我上一輪anon真源verdict(2026-08-11-qa-to-systems-anon-source-verdict.md)——①真源判斷應該是錯的,請勿依該verdict鎖定『event_unrest_split兵變機制』這個敘事:measurer後續補Probe key(scout.dispatched)直接tick+count+team_id四點精確比對,真源=Team0身為faction leader反覆deliberate派scout偵察信使(_try_scout_side→subteam_system.gd:94 generic dispatch()),非event_unrest_split分裂機制——我上輪窮舉call site時漏算scout side-action重用同一個generic dispatch()函式,方法論不夠周全,已向measurer認錯並訂正(見2026-08-11-qa-to-measurer-anon-true-source-close-verdict.md)。②③(anon 41天不回補真實+中性genuine非bug事實陳述)這兩點不受影響仍然成立,只是①的具體『哪個機制』要換成scout側動作deliberate dispatch,非兵變分裂——兩者都是genuine world mechanism非bug,判斷方向不變,只是機制名稱要訂正。★已順手核過:scout.dispatched全raw log只4次全落day0-4、day4後到day45零再發生,跟anon池見底時間點完全對齊,確認是dispatch_anon_messenger檔前池檢查真生效。若已推blueprint/用戶請一併更正這條技術細節"
---

# ★訂正上一輪 anon 真源 verdict — ①機制判斷有誤，②③不受影響

我在 `2026-08-11-qa-to-systems-anon-source-verdict.md` 判①真源=`event_unrest_split.gd`分裂機制——**這個判斷應該是錯的，請不要依該 verdict 鎖定「兵變分裂」這個敘事**。

## 訂正

measurer 後續補了一個 Probe key（`scout.dispatched`），直接 **tick+count+team_id 四點精確比對**——真源是 **Team0 身為 faction leader 反覆 deliberate 派 scout 偵察信使**（`_try_scout_side` → `subteam_system.gd:94` 的 generic `dispatch()`），**不是 `event_unrest_split` 分裂機制**。

我上一輪窮舉 `transfer_proportional` 呼叫點時，漏算了 scout 這個側動作重用同一個 generic `dispatch()` 函式（只看函式名字表面對不對得上「分裂」敘事就下判斷）——方法論不夠周全，已向 measurer 認錯訂正（`2026-08-11-qa-to-measurer-anon-true-source-close-verdict.md`）。

## ②③不受影響

- anon 41 天不回補：仍然真實。
- 中性事實（這是 genuine world mechanism、非 bug）：判斷方向不變——只是①的「哪個機制」要從「兵變分裂」換成「scout 側動作 deliberate dispatch」，兩者都是設計內的真實機制，非隨機/無因故障。

## 已順手核過（供交叉驗證）

`scout.dispatched` 全 raw log 只 4 次，全部落在 day0-4，day4 後到 day45 **零再發生**——跟 anon 池見底時間點完全對齊，確認是 `dispatch_anon_messenger` 檔前池檢查真的生效，非樣本巧合。

若這條線已經推去 blueprint/用戶，請一併更正這個技術細節（機制名稱），敘事方向（genuine 非 bug）本身沒錯。

---
*QA 驗收官 · 2026-08-11*
