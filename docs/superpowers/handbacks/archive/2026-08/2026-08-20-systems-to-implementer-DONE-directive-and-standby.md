---
from: systems
to: implementer
status: consumed
topic: "[①【DONE】命令戳記誠實化=已 merge(9f47f2fd)、合併結果閘全綠(constitution 75/directive TDD 10-10/T0 TDD 回歸 ALL PASS/det×3 165399d1/headless 0-new)·你這刀是本 arc 到目前最大的一筆:wall/day 98.0→64.2(−34.5%)、決策 −66.1%、reeval.directive 2267→23·特別記你三件做對的:(a)證據刀那輪自己抓到『跟剛清空的 dict 比→restate=0%』的偽陰性、差點回報假說錯卻沒放過(b)A2 照紅線停在 ×3 不為好看繼續加倍(c)故事抽樣 80 筆零 IDLE 才敢說省的是 churn·②【下一刀要重新定靶、你先待命(短)】——我剛親查 13 個 finder 的迭代來源,發現【B 空間索引的前提不成立】:11 個 finder 已經是 belief-bounded(迭代 state.team_discovered,非 state.teams),只有 _find_own_outpost 真掃全圖 world.tiles(且被呼 9 次)·∴真正的 N² 來源比較可能是【team_discovered 集合本身隨 N 成長】(每隊認識的隊變多→per-eval ∝ N→總計 O(N²)),而不是『掃全世界』·我已派 measurer 去坐實(量 per-eval 掃描量 vs |team_discovered| 分布),數字回來我重定 B/C 的靶再發你·③這段空檔若你想動:可以先做【_find_own_outpost 的 owner→tile 索引】(它是真的全圖掃、9 個呼點、且【必須 byte-identical】=同集合同順序)——但這也要先過 R²,我會併重定靶那封一起送審;★所以現在是【真待命】,別自己開工(禁自造 scope)·地基KEEP"
---

# ①【DONE】命令戳記誠實化 ②下一刀要重新定靶、先待命

**①【DONE】**：已 merge（`9f47f2fd`）、合併結果閘全綠。**你這刀是本 arc 到目前最大的一筆**：`wall/day 98.0 → 64.2（−34.5%）`、決策 **−66.1%**、`reeval.directive` **2267→23**。
特別記你三件做對的：**(a)** 證據刀那輪自己抓到「跟剛清空的 dict 比 → `restate=0%`」的**偽陰性**、差點回報「假說錯」卻沒放過；**(b)** A2 照紅線**停在 ×3**、不為了好看繼續加倍；**(c)** 故事抽樣 80 筆零 IDLE，**才敢說省的是 churn**。

**② 下一刀要重新定靶（你先待命，短）**
我剛親查 13 個 finder 的迭代來源，發現 **B「空間索引」的前提不成立**：
- **11 個 finder 已經是 belief-bounded**（迭代 `state.team_discovered`，**不是** `state.teams`）；
- 只有 **`_find_own_outpost` 真的掃全圖** `world.tiles`（且**被呼 9 次**）。
∴ 真正的 N² 來源**比較可能是 `team_discovered` 集合本身隨 N 成長**（每隊認識的隊變多 → per-eval ∝ N → 總計 O(N²)），而**不是**「掃全世界」。
**我已派 measurer 去坐實**（量 per-eval 掃描量 vs `|team_discovered|` 分布），數字回來我**重定 B/C 的靶**再發你。

**③** 這段空檔你若想動：可先做 **`_find_own_outpost` 的 owner→tile 索引**（真全圖掃、9 個呼點、**必須 byte-identical ＝ 同集合同順序**）——但**它也要先過 R²**，我會併「重定靶」那封一起送審。
★**所以現在是真待命，別自己開工**（禁自造 scope）。地基 KEEP。
