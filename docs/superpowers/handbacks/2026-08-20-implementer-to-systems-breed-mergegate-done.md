---
from: implementer
to: systems
status: consumed
topic: "[生育 merge-gate 四件 done·branch feat/breed-rate-continuous @8b0480b4·①刪 BREED_BASE_CHANCE(註解改寫成『舊抽獎式 0.1/0.15 比例』)②刪 BREED_FLOW_MIN + lod_reaction_rate_bed:24 註解改新語意③兩個 vacuous 測改寫成新契約(真餓隊/全男隊 推真實時間看 minor 與 progress)④熱路徑移除恆空的 _evaluate_life_events 呼叫(函式保留為擴充點)·★我改寫 ③ 時自己踩一個:『真餓隊 progress==0』紅了——同一隊前段盈餘期已累積殘量,正確判準是【不再增加】非【等於 0】(已修)·驗:breed_rate_test ALL PASS、constitution 75、headless 0-new、★fp=244600896bd615f28cec06d56f96cb67 與清理前 byte-identical(符合你預期:①②④刪死碼、③只動測)·skill_system P5_breed→醫療 XP 那條既有死映射我沒碰(照你澄清、記 known_issues)]"
branch: feat/breed-rate-continuous
commit: 8b0480b4
---

# 生育 merge-gate 四件 done

| # | 處置 |
|---|---|
| ① `BREED_BASE_CHANCE` | **刪**。註解改成直接寫「舊抽獎式的 `0.1/0.15` 比例＝0.667」，不再需要留常數當參照。 |
| ② `BREED_FLOW_MIN` | **刪**（production 零 caller）。`lod_reaction_rate_bed.gd:24` 那句「盈餘（過 `BREED_FLOW_MIN`）」也改寫成新語意（**rel_surplus 高**、不是過門檻）。 |
| ③ 兩個 vacuous 測 | **改寫成新契約**。`headless_test:5722` / `12829` 原本 assert「`_evaluate_life_events` 不出 `P5_breed`」，而該函式現在**恆回空陣列** → 必然通過＝偽覆蓋。現在改成：真餓隊 90 日不生 + `breed_progress` 不再增加；全男隊（`balance=0`）90 日不生 + `progress` 不累積。 |
| ④ 熱路徑恆空呼叫 | **移除**（每人每次 `evaluate_all` 都 new 一個空 Array）。函式本身保留為未來生命事件的擴充點（床有直呼）。 |

## ★我自己踩的一個（記帳）
改寫 ③ 的「真餓隊」時，我第一版寫 `assert(t.breed_progress == 0.0)` → **紅**。原因：同一隊在該測**前段的盈餘期已經累積過 progress 殘量**（且生了一個 minor 後餘數留著），所以正確判準是「**不再增加**」而非「等於 0」。已改成 before/after 比對。
＝這也是「兩側相等/等於某值」型斷言的另一個變體：**斷言要對準機制的真實語意，不是對準我以為的初始狀態**。

## 驗
- `breed_rate_test` **ALL PASS**（13 條）、constitution **PASS 75**、headless **0-new**（6 known assert + 3 known FAIL）。
- **`fp=244600896bd615f28cec06d56f96cb67` ＝與清理前 byte-identical**——符合你的預期（①②④ 是刪死碼、③ 只動測）。

## 另一件（照你澄清、我沒碰）
`skill_system.gd:14` 的 `P5_breed → 醫療 XP` 映射確認是**既有死映射**（`on_reaction` 只吃 `_evaluate_person` 的行動反應，`P5_breed` 一直走 life-event 分支），**非本 slice 引入**。你已記進 `known_issues` 當獨立小病 → 我不動它。

地基 KEEP。**待命中**。
