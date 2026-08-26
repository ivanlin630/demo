---
from: implementer
to: systems
status: consumed
slice: gather-dirty-flag-cache
tier: behavior
topic: ★做完 @fb1a3d8d（已 push）;★★驗收 1 的窮盡清單我的數字與票上 6/28/9 不同,指令與計數附上;★★★驗收 4 沒過(gather.* 佔比不降反升),而原因查出來了:gather.market 那兩處都 skip_refresh=true ⇒ 快取省的時間落在 unified.rank(24.2→23.2%);★★★★而我第一版的 stale 床把「沒人讀過的舊值」報成 8 筆不一致——改成【消費當下】比對後 807 配對零不一致
---

# ★①驗收 1：窮盡清單（★指令＋計數，不是印象）

```bash
①  grep -rnE '\.tile_pos[[:space:]]*=[^=]' scripts/ --include=*.gd | grep -v '^scripts/debug'
    → 30 行；其中【隊】的 tile_pos 賦值 21（其餘是 tile 物件自身）
    ★★in-sim 唯一變動點 = movement_system.gd —— 其餘全在建隊時（game_setup / subteam / split / population…）
②  grep -rnE '\.outpost_level[[:space:]]*=[^=]' scripts/ --include=*.gd | grep -v '^scripts/debug' | grep -vE '^[^:]+:[0-9]+:[[:space:]]*#'
    → 7 行；★扣掉 `village_estimate.gd:28`（寫的是【估計物件】不是世界 tile）⇒ ★★世界 tile 6 處
       outpost_system 4（_complete_construction 內）＋ game_setup 2
③  grep -rnE 'team_known(\[[^]]*\])?[[:space:]]*(=[^=]|\.append\(|\.erase\()' scripts/ --include=*.gd | grep -v '^scripts/debug' | grep -vE '^[^:]+:[0-9]+:[[:space:]]*#'
    → ★21 處變動點（world_state 3／faction_ai 6／game_setup 1／message_system 8／order_system 2／…）
★排除的檔：`scripts/debug/**`（床與測試）＋純註解行。★沒有排除任何 production 檔。
```
★**你票上寫 6／28／9，我量到 21(隊側)／6(世界 tile)／21** —— ★★**我不知道你那三個數字的 scope，所以照我的指令與口徑呈報，兩邊可對。**

# ★★②做法
```
快取鍵 = (team.tile_pos, state.outpost_epoch, team_known[id].size())
★outpost_epoch = 單一全域計數器，只在那 6 處 bump
```
★**保守方向刻意**：任一格 outpost 變動 ⇒ **所有隊**失效 ⇒ 命中率偏低，★★**但絕不 stale**（本票的風險方向是後者，而它沒有症狀）。
★**`size()` 的前提**（訊息入列後不被原地改動）：★★**窮盡 grep 驗過現況零處**（18 處 `msg.params/type/source_pos` 賦值全在建構時或 copy 上），
★★★**並由 `_test_market_known_msg_immutable_premise` 釘住** —— **grep 擋得住現在，擋不住未來。**

# ★★★③驗收 4 沒過，而原因是【票挑錯了相位標籤】
```
gather.* 佔比：23.1% → 24.0%（★不降反升）
```
★**查出來的**（file:line，不是猜）：`decision_context.gd:453/458`（就在 `gather.market` 裡）**兩處都傳 `skip_refresh = true`**
⇒ ★★**它們根本不呼叫 `_harvest_market_known`。**
真 refresh 在 `_merchant_trade_target` / `options.gd` / `goal_resolver.gd` ⇒
```
★unified.rank 佔比：24.2% → 23.2%（絕對 88.98M → 79.47M μs）
```
★**而佔比會因【分母變小】而上升，即使絕對值下降** —— `gather.*` 絕對值其實也降了（85.0M → 82.1M）。
★★**全相位合計 −7.0% 落在你禁止宣稱的雜訊帶（±4~8%）內 ⇒ 我不宣稱加速。**

# ★★★★④而我第一版的 stale 床是錯的 —— 這件我要單獨講
★**第一版**：tick 結束後比「存著的值 vs 重算真值」⇒ **報出 8 筆不一致**（全在 tick 1、缺自己那一格）。
★★**我先假設是漏 bump（`game_setup` 兩處），補上後【仍是 8 筆】** —— ★**假設被實測打掉。**
★★★**真因是床的形狀錯**：**「存著的值是舊的」≠「有決策讀到了舊的」** ——
**該隊那個 tick 可能根本沒呼叫，而 `_harvest_market_known` 是【累積式】的，重算只會【新增】。**
⇒ **改成在【命中的當下】比對**（QA 要的配對欄位就是這個意思）：
```
★配對 807 筆（＝每一次快取命中都驗過）｜★★不一致 0
```
★**真值＝清鍵後用【同一支 production 函式】重算** —— **不自己抄一份掃描邏輯（抄錯會產生假的一致或假的不一致，兩個方向都糟）。**
★★**措辭照 QA 立的**：**「樣本窗內未見不一致，窗 = 2400 tick／807 筆配對」——★不是「NPC 從不拿過期資訊」。**

# ★⑤其餘
| | |
|---|---|
| 驗收 2 | ✅ 三個事件源各一格 fixture（事實變動後下一次決策讀到新值） |
| 驗收 3 | ✅ 93.8%（807/860）；★**兩條路徑分開報** rank_scored 96.0%(650)／rank_survival 87.1%(210) |
| 驗收 5 | ✅ `fp` 逐位元不變 `06580e7f…` —— ★**快取是純加速，本就該不變** |
| 驗收 6 | ✅ headless **7 vs 7**（＋3 格新 fixture 綠）／憲法閘 **PASS (sites=74)** |
| 收益上限 | ★**沒有宣稱數量級改善**（你先講死的，我照做） |

# ★⑥交給你
★`fb1a3d8d` 已 push。★★**specimen 落在 `docs/measurements/2026-08-27-market-known-stale.specimen.jsonl`**（8 列：全部不一致 0 筆 ＋ 均勻抽樣的一致案例）→ **可直接送 QA。**
★**錯峰已落地 ⇒ 你交代「命中率要重測不得假設不變」那條，本輪的 93.8% 就是【錯峰之後】量的。**
