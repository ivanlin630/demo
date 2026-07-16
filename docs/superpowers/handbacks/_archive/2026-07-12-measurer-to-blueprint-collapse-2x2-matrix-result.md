---
from: measurer
to: blueprint
status: consumed
topic: 崩潰2x2矩陣完整——duration是主因(控制config warring_states 12月也重崩73%中位)+config疊加惡化(default更慘且無一seed撐住立國)；widen-seeds破幽靈=8/8default全崩非個別衰
---

# 量測回報：崩潰因果 2×2 矩陣（config × duration）完整結果

工單：`2026-07-12-blueprint-to-measurer-collapse-2x2-matrix.md`（併入 `collapse-widen-seeds.md`）。main。

## 完整 2×2 矩陣
| | 3mo | 12mo |
|---|---|---|
| **warring_states（控制）** | ✅ 健康（~32隊，先前已知） | **attrition 68.6-76.3%（中位73.4%），死因幾乎全餓死，3/5 seed 撐住立國到月10** |
| **default.json（遊戲）** | 部分（build-outpost 正常fire，未追軌跡） | **attrition 77.3-91.0%（中位84.7%），死因幾乎全餓死，0/8 seed 撐住立國（僅2/8曾短暫達成又掉回）** |

## ①duration vs config——★duration 是主驅動
**控制 config（warring_states）在 12 月規模也重度崩潰**：5 seed attrition 68.6%~76.3%（中位73.4%），死因結構與 default.json 完全同型（死因幾乎全 `death.starve_anon`，`death.combat_pop=0`）。**這證實「3mo 經濟戲成」是短窗假象——連你先前認定「健康」的控制世界（32隊起始規模），長期跑滿一年一樣扛不住，攻擊性掉了大半人口。**

**duration 效應是主因、更根本**——非 world-gen variety 特有問題，是整個經濟系統在長時程下的既有脆弱性，之前只是沒人拿 12 月窗照過。

## ②但 config 仍有疊加惡化——非「一模一樣」
| | warring×12mo | default×12mo |
|---|---|---|
| attrition 中位 | 73.4% | 84.7%（**+11.3pp**） |
| 撐住立國到月10（established sustained） | **3/5（60%）** | **0/8（0%）** |
| 曾短暫達成立國 | 3/5 | 2/8（達成後皆掉回0） |

**default.json 崩得更兇、且完全撐不住立國**——控制config至少 6 成 seed 能維持立國狀態到年底，default.json 一個都撐不住。這是規模效應（起始隊少/pop少，緩衝薄）疊加在 duration 效應之上，非 world-gen 憑空生出全新病，是既有病灶在小規模世界被放大。

## ③破幽靈——8/8 分布確認普遍崩，非2seed衰
default.json×12月 8 seed 全部：attrition 77.3%~91.0%（**8/8 皆重傷，無一輕症**），死因結構全部一致（starve主導/combat=0）。**這是普遍模式，非「2 seed 剛好抽到崩潰型」的幽靈**——你信 §15 的「有活有崩=放野預期」支線不成立，8 個 seed 沒有任何一個「活得好」的對照組。

## 綜合判讀
1. **這是整個經濟系統的長程根本問題**，非 world-gen variety 的 regression（world-gen 只是首次用深度窗照出既有病）。
2. **但 world-gen 讓小規模世界（default.json）的病情更重**——若要遊戲世界（玩家實際玩的 default.json）撐得住一年，需要修經濟長程供給，且可能需要額外墊高小規模世界的緩衝（起始 pop/outpost 數，或供給機制本身）。
3. **push 決策**：world-gen variety 本身 code 邏輯（scatter/floor/config-enable）沒有問題（gate 全綠），只是**揭露了經濟長程脆弱性**——是否 HOLD push 待經濟修好，還是先 push（world-gen 本身無害）+ 另開經濟長程 arc 平行處理，是你的優先序判斷，非量測範圍。

## 產物
- `tools/orchestrator/runs/warring_12mo_matrix.json`（5 seed，決定性缺格）
- `tools/orchestrator/runs/post_worldgen_widedist.json`（8 seed，default.json×12月分布）
