# 衝突統一（戰鬥解算與敗北模型）— 母 Spec / Umbrella

> 藍圖裁定（handback `2026-06-19-blueprint-to-systems-e1-annihilation-ruling`）要求系統開此母 spec，收束完整戰鬥模型 + 移出 E-1 的項目 + 兩條藍圖約束。
> 願景單一源（WHAT）：`game-design.md §戰鬥解算與敗北模型`（藍圖 owner，本 spec 只引用不複製）。本 spec = HOW 的 seam/拆解索引，子 spec 各自獨立 land。

## 願景摘要（引用 game-design.md，勿在此 drift）

統一模型：**戰鬥重量 = Σ 人均戰力(tier × 武裝兩獨立軸) × 參戰意志；勝負結果按 tier/角色加權落敗方整隊 pop。**
- 損耗（高烈度）與 潰散/被俘（低意志）= 同一「重量 × 意志 → 結果」模型兩端，非兩塊補丁。
- 人海可拉下菁英（品質重扣 + 傷亡慘重）；平民默認逃，絕境才死守（沿用 desperation × values）。
- NPC-vs-NPC 與玩家遭遇戰共用，無玩家專屬不可殲滅大軍（否決模型 D）。

## 子 spec 拆解（各自獨立 land；E-1 是第一塊已落地拼圖）

| 子 spec | 狀態 | 範圍 |
|---|---|---|
| 繼承單一源 `specs/2026-06-19-leader-succession-single-source` | ✅ spec+plan done，待 worktree 實作 | leader 繼承單一 owner（E-1 孤立 seam） |
| E-1 結構免疫退化修 + 武裝下限 `specs/2026-06-19-e1-annihilation-degenerate-design` | spec 中 | 敗方結果觸整隊 pop（tier 加權存活）+ armed_ratio 下限堵 0 武裝免疫 |
| 完整重量×意志模型 | 未開 | 人均戰力公式（tier×武裝）、參戰意志公式（desperation×values）、人海品質重扣 |
| 屠/俘/散 命運裁定（戰俘 spec） | 未開（known_issues #2） | 低意志端最終命運；接收容量/勞役/釋放 |
| encounter ↔ npc_combat 等量耗時 | 未開 | 見約束 1 |
| 遭遇戰 UI（flat-top hex / QWEASD） | 未開 | 見約束 2 |

E-1（繼承統一 + 結構免疫退化 + 武裝下限）三塊合起 = 世界收斂可 land；完整模型後續逐塊接。

## 藍圖約束（記為不變量，跨子 spec 必守）

1. **等量耗時不變量**：玩家遭遇戰與 NPC-vs-NPC 戰，**同規模一仗吃掉的世界 tick 需對等**。否則增援/截擊/包圍時序破功。絕對 tick 值屬「正式平衡 pass」，與此不變量正交。
   - HOW 待解：encounter 是 per-round 互動（多 tick），npc_combat 是抽象回合（`process_ongoing_combat` 每 tick 一輪）。兩者世界耗時對齊需共用「一仗 = N 世界 tick」換算或統一節奏。落 `invariants.md` + 完整模型 spec。
2. **遭遇戰 hex 朝向 flat-top（平邊朝上）**：大小地圖統一。小地圖 QWEASD 移動需要；大地圖 WASD 選格沿用同朝向保視覺連續。座標系/axial 投影配 flat-top = 系統 HOW。落遭遇戰 UI spec。

## 範圍 / 邊界

- 本 spec 只索引 + 釘約束，**不含實作**。各子 spec 自帶 plan。
- WHAT 改動回藍圖（game-design.md owner）；HOW/seam/不變量系統 owner。
- 完整模型的玩法數值（人均戰力係數、意志公式權重）開子 spec 時再跟藍圖磨。
