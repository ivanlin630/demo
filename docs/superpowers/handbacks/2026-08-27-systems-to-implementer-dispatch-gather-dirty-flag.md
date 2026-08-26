---
from: systems
to: implementer
status: open
slice: gather-dirty-flag-cache
tier: behavior
topic: ★★★DISPATCH(R² CLEAN)——★排在你手上錯峰【之後】;★★而本票最大的風險不是效能是【stale 決策】:漏失效=NPC 拿過期世界做決策,而它沒有症狀(決策照常發生、數字照常好看,只是內容錯了);★驗收 1=窮盡三個具體欄位的寫入點(不是整個 gather(),量級只有 6/28/9),沒過後面都不用看
---

# ★★★DISPATCH：`docs/superpowers/specs/2026-08-27-gather-dirty-flag-cache-HOW.md`（R² CLEAN）
★**排在你手上的錯峰【之後】，別插隊。**

## ★前提（★量出來的）
```
666 配對（同隊連續兩次【真呼叫】gather()）｜same 628｜diff 38 ⇒ ★94.3% 沒變
★★變化 100% 集中在 burst tick；★★★non-burst tick ＝ 0 變化
事件源明確：team_known 的 relay 訊息（order 張貼／outpost_built），不是噪聲
```

# ★★★★①最大的風險不是效能，是【stale 決策】
> ★**快取漏失效 ＝ NPC 拿【過期的世界】做決策** ⇒ ★★**行為 bug，不是 perf bug，而且【沒有症狀】：
> 決策照常發生、數字照常好看，只是內容錯了。**

# ★★②驗收 1（★沒過後面都不用看）：**窮盡【三個具體欄位】的寫入點**
★**範圍不是整個 `gather()`** —— **它讀一堆不相干的東西（population／food／labor／feud／vendetta…）。**
★★**快取只需要對 `_harvest_market_known`（`faction_ai_system.gd:3463-3485`）讀的三樣負責**：
```
①team.tile_pos                                掃描中心
②state.world.tiles[...].outpost_level             vision 半徑內 ＋ relay 訊息指到的 tile
③state.team_known[team_id] 的 relay 訊息（★僅 order_buy／order_sell／outpost_built 三種 type）
★R² 實測量級：6 ／ 28 ／ 9 —— ★★小，窮盡可行
```
★**要求**：**貼 `grep -rn` 指令、`| wc -l` 出數字、寫明有沒有排除任何檔。**
★★**「我想到的那幾個」不算窮盡**（★**而我今天在這件事上自己錯過四次，防線是指令不是印象**）。

## ★而「改成比對快取鍵」不是逃生口（★R² 已分析，別走這條）
**`outpost_level` 要嘛重掃 vision 範圍比對現值（＝正是要省掉的開銷），要嘛維護世代計數器並在每個寫入點 bump（＝還是要找到那 6 個）。**
⇒ ★**換個機制沒有迴避掉窮盡的工作量，只是換個名字。**

# ★③兩條路徑都要正確（★命中率只在一條上有數字）
```
★驗過的：rank_scored（decision_engine.gd:50）——94.3% 來自這裡
★★沒驗的：rank_survival（:306 ← faction_ai:5296，屬 loop3.survival）
```
★**快取必須對兩條都正確**（★**它們共用同一個 `_harvest_market_known`，正確性沒有商量餘地**）；
★★**命中率兩條【分開報】**，第二條的數字在本票量出來。

# ★④其餘驗收（spec 有全文）
2. ★★**stale 防線**：**每一個窮盡清單上的事件源，各一格 fixture** —— **事實變動後【下一次】決策必須讀到新值**
3. 命中率實測（分母＝真呼叫配對數，不是隊數／tick 數） 4. `gather.*` 對 `dt` 佔比下降（★**禁用全局 wall-clock**，雜訊 ±4~8% > 效果）
5. ★**`fp` 會變** —— ★★**本條不要求 `fp` 不變、也不要求命中率最大化；只要求每一次差異都能對應到清單上的一個具體事件源。**
   ★★★**它懲罰的是【沉默】不是【變動】** —— **做成零命中一樣要解釋為什麼。**
6. 守恆帳／headless(7)／憲法閘
7. ★★★★**QA 故事稽核**：**「NPC 沒有拿過期資訊做決策」是 behavior 因果結論** ⇒ **必附 `SpecimenDumpHelper` specimen trace 送 QA，禁自判。**

# ★⑤收益上限先講死
```
gather.* 對 dt ≈ 35%  ×  命中率 ≈ 94%  ⇒ ★上限 ≈ 33% of tick，而那是【上限】，實際更少
```
★★**本票不得宣稱數量級改善** —— **這條 arc 是常數因子問題（blueprint 已收）。**
★**錯峰落地後命中率要重測，不得假設不變**（變化會從 burst tick 散開）。
