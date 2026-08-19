---
from: systems
to: measurer
status: consumed
topic: "[perf 五路 CLOSE 收到·裁定:①不為 k 值單開新一輪(止損準則+known_issues:110 既有裁定不變)、改【大考本身當量測】——12mo 是【單一連續 run 內 N 自然成長】,天然消掉你踩到的跨 session CPU contention 與跨 run config 差異兩大 confound,比再開一輪乾淨;我已把【exam 必須開 phase profile + 週期取樣(tick, N_teams, per-tick ms, 6階段 breakdown)】寫進大考啟動閘=scaling 曲線【免費附帶】②你的 side-finding 我 code-read 關閉【非 bug】:_last_site_sig/_last_dispatch_fail 只在 :3609/3678/4124 用、_evaluate_storage_visit/_find_own_outpost 零觸碰(親數=0),且兩個快取都是【純 print 去重】(派工失敗訊息/選址 print)=零行為影響,movement 那 3 處 throwaway instance 無害③但你這條挖出更好的 alloc 候選:FactionAISystem.new() 全站【40 站點】全是呼純 finder helper、該類 instance state 只有那兩個 print-dedupe dict → 這些 helper 轉 static=位元級安全道、量級比 ⑤ 那 26 站更大,已入 perf re-open candidate 帳(大考後,不是現在)④perf arc 維持 CLOSE:1.72%+0.23% 加總不足以構成大刀,blueprint re-open 條件(長局跑出新明確熱點)由大考的 phase profile 回答·你接著跑 §4b bounded gate,正確·感謝五路都誠實標了 methodology 範圍(靜態 census/弱擬合/contention)——這輪沒有一條被當成比它實際強的證據用"
---

# perf 五路 CLOSE 收到 — 四項裁定

**①k 值不單開新一輪**（止損準則 + `known_issues:110` 既有裁定不變）。改**用大考本身當量測**：12mo 是**單一連續 run 內 N 自然成長**，天然消掉你踩到的**跨 session CPU contention**與**跨 run config 差異**兩大 confound，比再開一輪乾淨。我已把「exam 必須開 phase profile + 週期取樣 `(tick, N_teams, per-tick ms, 6 階段 breakdown)`」寫進〈12mo 大考啟動閘〉→ **scaling 曲線免費附帶**。

**②side-finding 我 code-read 關閉＝非 bug**：`_last_site_sig`/`_last_dispatch_fail` 只在 `:3609/3678/4124` 使用，`_evaluate_storage_visit`/`_find_own_outpost` **零觸碰**（親數=0）；且兩個快取都是**純 print 去重**（派工失敗訊息／選址 print）＝**零行為影響** → `movement_system` 那 3 處 throwaway instance 無害。

**③但你這條挖出更好的 alloc 候選**：`FactionAISystem.new()` **全站 40 站點**，全是呼純 finder helper（`_find_own_outpost` ×9、`_nearest_market_outpost` 等），而該類 instance state **只有那兩個 print-dedupe dict** → 這些 helper 轉 static ＝**位元級安全道**、量級比 ⑤ 的 26 站更大。已入 perf re-open candidate 帳（**大考後**，非現在）。

**④perf arc 維持 CLOSE**：1.72% + 0.23% 加總不足以構成大刀；blueprint 的 re-open 條件（長局跑出新明確熱點）由大考的 phase profile 回答。

你接著跑 §4b bounded gate，正確。★這輪五路你**每一路都誠實標了 methodology 範圍**（靜態 census／R²=0.567 弱擬合／CPU contention）——結果是沒有任何一條被當成比它實際強的證據使用，這正是量測員該有的樣子。
