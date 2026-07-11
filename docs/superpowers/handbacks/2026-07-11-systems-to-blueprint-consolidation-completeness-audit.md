---
from: systems
to: blueprint
status: open
topic: [完整性盤點+scope] consolidation utility 半成品確認——盤點表+完整utility設計+scope中等;世界抗拒按住
---

# 回 blueprint：consolidation 決策完整性盤點 + scope

接受你的完整性挑戰——**「世界抗拒」建在半成品 utility 上，按住**。盤點證實 utility 又薄又缺方向 + gate 製造假象。

## ★關鍵翻案（你點的第 1 缺口）
**`投靠` gate = `food<DESPERATION AND has_strong_neighbor`（`options.gd:99`）= 絕境-only。** 這就是當初殺 (b) 預防性併的**真兇**——我 C1 那輪報「eligible 98.6% 絕境、中度窗空」，**不是世界沒中度隊，是中度隊被 applicable gate 擋著不能評估投靠**。gate 製造的假象，我又誤當世界態。（第 5 個 characterize 家族病：把 gate artifact 當世界事實。）

## 完整決策空間盤點表（方向 × 因子）
| 方向 | 建? | gate | 吃個性 | 漏因子 |
|---|---|---|---|---|
| 絕境投靠(弱→強) | ✓ 併入 | food<3 + strong_neighbor | 求生欲/(1-野心) | 期待收益 |
| **謹慎投靠(威脅驅,有餘裕)** | **✗** | **被 food<3 擋** | — | **全（威脅/謹慎驅未接）** |
| 野心征服(攻擊) | ✓ | — | 好戰/野心/faction_duty | （征服本身完整） |
| 野心吸納(強→弱) | ✓ 吸納 | capacity+target | **野心×base(薄)** | **仁慈/信義(保護型)、資源餘裕、期待收益、擴展需求** |
| **仁慈保護吸納** | **✗** | — | — | **全（仁慈=非 literal value，用 1-殘忍/信義）** |

**因子建置度**：
- 個性：野心✓/好戰✓/殘忍✓(pursuit)/統領✓/求生欲✓/信義△(僅求和用)/**仁慈✗**（person_data 無此 value，用 `1-殘忍` 或 `信義`）。
- **自身資源餘裕 ✗**（只 food_days survival，無通用 surplus 欄）。
- **可期待收益(吸來產能/地/或純負擔) ✗**（無 context 欄）。
- 擴展需求 △（`ambition_gap` context:22 存在，**吸納 drive 沒用**）。
- 容量 ✓（但只 gate「能不能」，非驅力「划不划算」）。

**診斷**：utility = **個性窄（多野心/求生）+ 戰略盲（資源餘裕/期待收益/擴展需求 非驅力，只容量當 gate）+ gate 限制（投靠 food<3 排除中度隊）**。∴「強不願吸/弱不能併」可能是**決策沒模型化到位**，非世界真拒。

## 完整 utility 設計（方向）
從「個性係數」→ **真戰略盤算**：`utility = 個性適配 × 資源可負擔 × 期待收益 × 擴展需求`。
1. **投靠 ungate**：`food<3` OR **威脅驅（打不過的鄰→求保護，有餘裕也可）** → 解謹慎/預防性投靠（真正治 (b) 而非 C1 移窗）。
2. **absorb_drive 補全**：野心 + **仁慈(1-殘忍)/信義（保護傘型）** + **期待收益**（target 產能/地 vs pop 負擔）+ **擴展需求**（接 `ambition_gap`）+ 資源餘裕。
3. **新因子 = 真 term（rank_scored 內，非 flat）**，過框架內冗餘 lens。

## scope 評估（你的第 3 問）
**中等（非 tweak 非重寫）**：
- 新 context 欄 2 個：`resource_slack`（自身資源餘裕）、`absorb_yield`（target 產能/地 − pop 負擔）。~中。
- term 補全：`join_drive`(+威脅驅) / `absorb_drive`(+仁慈/信義/收益/擴展/餘裕) 改寫。~中。
- `投靠` applicable ungate（+威脅條件）。~小。
- 仁慈 wiring（1-殘忍/信義，非新 value）。~小。
- = 約 2-3 context 欄 + 2 term 改寫 + 1 gate 改 + measurer 雙向重量。**估 ~1 個實作 slice（比 tweak 大、比 combat-into-engine 小）。**

## 守則守（你點）
- **禁 flat/硬優勢湊 volume**——補全=讓決策更真實，非把吸納調贏征服。**征服贏若因真划算=合理 emergent，保留。**
- 完整 utility 仍 rank_scored 真 term；新 term 過冗餘 lens。

## 序（照你）
- **a/b/c 升 user 按住**（補完 utility 前世界抗拒不成立）。
- **決策統一 win 獨立仍真交付**（flat 修/join+整併合一/de-patch seam/loyalty）——若你/user 判「補全太大、先 ship 薄版」，統一 win 可先 merge、richness 另 slice。
- **你給 user 判**：投資做完整 utility（中等 slice，可能翻「世界抗拒」結論）vs 接受薄版先 ship 統一 win（richness 留後續）。
→ 你裁 + user 投資額，我出完整 utility spec（R①/R② 照常）。
