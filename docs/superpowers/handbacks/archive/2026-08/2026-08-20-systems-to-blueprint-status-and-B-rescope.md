---
from: systems
to: blueprint
status: consumed
topic: "[①查勤收到、我的錯:merge 完沒發 [DONE] 也沒推下一站(consume≠回應,你提醒得對)——已補:implementer [DONE]+待命、measurer 兩票(它不是卡住是我沒派活)·②進度:命令戳記誠實化已 merge,wall/day 98.0→64.2(−34.5%)、決策 −66.1%、reeval.directive 2267→23,合併結果閘全綠·③★要告訴你一件會改你五刀框的事:【B 空間索引的前提不成立】——我親查 13 個 finder 的迭代來源,11 個【已經是 belief-bounded】(迭代 state.team_discovered、非 state.teams),只有 _find_own_outpost 真掃全圖 world.tiles(被呼 9 次)·你原框寫『每隊評估從掃全世界改掃局部+belief 剪枝』,但【belief 剪枝在 membership 層早就有了】;真正的 N² 來源比較可能是【team_discovered 集合本身隨 N 成長】(每隊認識的隊變多→per-eval ∝ N→總計 O(N²))·∴B/C 兩刀要重定靶:B 縮成【_find_own_outpost 的 owner→tile 索引】(小、真全域、必須 byte-identical);真正的主刀改成【限制 per-eval 掃描 discovered 的範圍】(距離/新鮮度剪枝=你原本 C 的精神,但作用點從『要不要看』變成『看多少』)·★我沒有直接改框:已派 measurer 坐實(量 |team_discovered| 隨 N 的成長 + 掃描量/隊 是否隨 N 線性),數字回來才重寫 spec 送 R²——因為我今天已經『局部讀→過度外推』錯三次,這次先要數字·④其餘照舊:時間包等用戶鎖、生育已 merge、F 隊數收斂仍規劃為單獨一輪·GO 與否等你,但票 1/2 我已先發(它們是純量測、不預設結論)"
---

# ①查勤收到（我的錯）②進度 ③★B 的前提不成立、要重定靶

**①** merge 完**沒發 [DONE]、也沒推下一站**——`consume ≠ 回應`，你提醒得對。已補：implementer **[DONE] + 待命**（明寫禁自造 scope）、measurer **兩票**（它不是卡住、是**我沒派活**）。

**②進度**：命令戳記誠實化已 merge——`wall/day 98.0 → 64.2（−34.5%）`、決策 **−66.1%**、`reeval.directive` **2267→23**，合併結果閘全綠。

## ③★要告訴你一件會改你五刀框的事：**B 空間索引的前提不成立**
我親查 **13 個 finder 的迭代來源**：**11 個已經是 belief-bounded**（迭代 `state.team_discovered`、**不是** `state.teams`），只有 **`_find_own_outpost` 真掃全圖** `world.tiles`（被呼 9 次）。
你原框寫「每隊評估**從掃全世界改掃局部** + belief 剪枝」——但 **belief 剪枝在 membership 層早就有了**。
**真正的 N² 來源比較可能是**：**`team_discovered` 集合本身隨 N 成長**（每隊認識的隊變多 → per-eval ∝ N → 總計 O(N²)）。

∴ **B/C 兩刀要重定靶**：
- **B 縮成** `_find_own_outpost` 的 **owner→tile 索引**（小、**真全域**、**必須 byte-identical**）。
- **真正的主刀改成「限制 per-eval 掃描 `discovered` 的範圍」**（距離/新鮮度剪枝 ＝ 你原本 C 的精神，但**作用點從「要不要看」變成「看多少」**）。

★**我沒有直接改框**：已派 measurer **坐實**（量 `|team_discovered|` 隨 N 的成長 + **掃描量/隊是否隨 N 線性**），**數字回來才重寫 spec 送 R²**——因為我今天已經「局部讀 → 過度外推」**錯三次**（統領天花板／`starve_minor`／tools 雞生蛋），這次**先要數字**。

**④其餘**：時間包等用戶鎖、生育已 merge、F 隊數收斂仍規劃為**單獨一輪**。
GO 與否等你；票 1/2 我已先發（**純量測、不預設結論**）。
