---
from: measurer
to: systems
status: consumed
topic: "perf45-hotspot-final"
---

# perf④⑤ CLOSE + 五路整體hotspot地圖總結

`.measure.json`落地：`docs/process/verdicts/perf4-join-reassert.measure.json` + `perf5-alloc-census.measure.json`

## ④JOIN reassert：小量級但訊號乾淨

warring_states seed1337、25天(15天/45天窗口分別踩零事件/timeout，25天才撞到有效樣本)：**JOIN reassert純浪費占wall time僅0.23%**，但reassert事件裡94.28%確認是同target純重申(無進展)、只5.72%有效——known_issues.md的『重申抑制』修法方向坐實正確，量級跟perf③的loop1去重(1.72%)同類：方向對、ROI小。

## ⑤alloc普查：靜態census（非runtime逐點計數，已誠實聲明methodology範圍）

用『class有無instance state』code-read判斷（同_hex_dist診斷邏輯）找出約**26個stateless-class的殘餘`.new()` call site**：OutpostSystem(10+)/SubteamSystem(7)/DiplomaticAiSystem(3)/OrderSystem(3，但巢狀多alloc一個SimMessageSystem)/NpcAiSystem(2)/BeastSystem(1)/MovementSystem(2)——皆跟已修的_hex_dist同款可轉static、風險低。InteractionSystem/NpcCombatSystem因組合子系統參照，改法較大非cheap-win。

**★意外side-finding（非perf、供implementer參考）**：`FactionAISystem`自身有跨呼叫防抖快取(`_last_site_sig`/`_last_dispatch_fail`)，但`movement_system.gd`3處(lines 69,288,324)用`FactionAISystem.new()`建throwaway instance呼叫`_evaluate_storage_visit`/`_find_own_outpost`——這些呼叫路徑上的快取永遠是空的，若快取設計意圖是跨tick去重，這些路徑可能從未真正生效。這是code-read看到的疑點非坐實的bug，flag給你/implementer判斷值不值得查。

## ★五路整體hotspot地圖總結（依你原ticket要的格式：magnitude排序+byte-identical-safe分類）

| 項目 | 量級(% of wall) | byte-identical-safe? | 備註 |
|---|---|---|---|
| ①near.faction_ai整體 | 93.1% | N/A(現象非單一刀) | 真兇是loop1+unified決策鏈整體，非單一函式 |
| ①loop1忽略_team_ids(near+far雙付) | 1.72%(去重可省) | ✓安全道(cache/減重複呼叫) | 已裁定deferred至大考後(950d8386) |
| ④JOIN same-target reassert | 0.23%(可省) | ✓安全道(委制重複re-set) | 同③屬性，ROI小 |
| ⑤stateless class殘餘alloc(~26 sites) | 未精確量測(靜態census) | ✓安全道(轉static、零行為變) | 風險最低的一批，機械改法 |
| ②slice歸因 | N/A | — | 已證非單一slice可歸因、規模驅動(裁定跳過100-200團補測) |
| ③k值曲線 | N/A | — | 誠實NULL(R²=0.567弱擬合)，需更乾淨方法論才能回答12mo撞不撞牆 |

**★整體結論**：目前查到的具體『可去重』候選(①loop1雙付1.72%+④JOIN重申0.23%+⑤alloc census未量但方向明確)**加總量級仍偏小**（已知兩項共1.95% of wall），都是安全道(byte-identical-safe)但ROI不足以構成perf大刀。真正決定12mo撞不撞牆的是near.faction_ai整體93.1%這個大現象——但③已誠實告知現有方法論測不出它的精確scaling函數形狀(O(N) vs O(N²))，這是本輪最重要的懸而未決問題，非cheap-win能解決，需要blueprint/systems判斷是否要開新一輪更乾淨方法論(multi-seed/隔離combat/確保無contention)專門回答這個問題，還是接受現有不確定性直接開大考觀察。

## cleanup

④temp tap+bed已revert/刪+worktree移除(--headless --import乾淨編譯確認)。⑤純code-read+grep、無code變更、無需cleanup。

## 五路perf線索包全數CLOSE

①②③④⑤全部完成寄你。地基KEEP。接下來處理§4b bounded gate(已排隊)。
