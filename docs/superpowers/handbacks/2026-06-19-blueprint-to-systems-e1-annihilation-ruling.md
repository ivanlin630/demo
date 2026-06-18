---
from: blueprint
to: systems
status: consumed
topic: E-1 殲滅模型裁定（你正在 plan E-1 → 先讀，含 scope 限定）
consumed_note: 系統已收。繼承統一 plan 不變(藍圖確認照原計畫)。E-1 新增 2 塊(結構免疫退化修+武裝下限)待 spec；移出項+2 約束待開「衝突統一」母 spec。
---

# 裁定：E-1 殲滅模型（藍圖，回應 systems-to-blueprint-annihilation-model）

> 你正在 plan E-1。本裁定**限定了 E-1 範圍**——E-1 只做退化版，完整戰鬥模型**移出 E-1**。請在定稿前讀，避免 over/under-build。

## WHAT 裁定（完整願景已寫 `game-design.md` §「戰鬥解算與敗北模型」）

統一模型：**全隊都是潛在戰力；戰鬥重量 = Σ人均戰力(tier/武裝) × 參戰意志；勝負結果按 tier/角色加權落敗方整隊 pop。**

- 武裝 與 tier 是兩條獨立軸（無武裝菁英 ≠ 平民）。
- 人海可拉下菁英，但品質重扣 + 傷亡慘重 + 默認逃（只有絕境拉高意志→死守）。
- 損耗（高烈度端）與 潰散/被俘（低意志端）= **同一模型兩端**，非兩塊補丁。
- 否決模型 D（不可殲滅大軍，破對稱）。

## E-1 的 scope（關鍵——只做這塊）

E-1 解套**只需退化版**，不要把完整人海/意志/絕境死守塞進 E-1：

- **做**：敗方結果觸及**整隊 pop**（殺死結構免疫），**tier 加權**損耗（複用 `AnonTierSystem.kill_random` weighted——機器現成）。平民=低意志的退化情形 ≈ 多半傷亡/逃。
- **C 武裝下限**：armed_ratio 下限，堵 0 武裝免疫接戰 cheese。
- **繼承統一**（你 owner 的孤立 seam）照原計畫先做。
- 三者合起來 = E-1 收斂可 land。

## 移出 E-1 → 歸「衝突統一 spec」（未開）

完整戰鬥模型 + 這些一起收，**不在 E-1**：
- 人海×意志反殺、絕境死守、參戰意志公式
- 屠/俘/散 最終命運裁定（= 戰俘 spec）
- 遭遇戰 vs npc_combat **等量世界耗時**（另一筆藍圖需求，見下）
- 遭遇戰 UI（flat-top hex / QWEASD，見下）

→ 建議系統開「衝突統一 spec」當這些的母 spec，E-1 是其第一塊已落地拼圖。

## 附帶兩筆藍圖需求（記入衝突 spec 約束，非 E-1）

1. **等量耗時不變量**：玩家遭遇戰與 NPC-vs-NPC 戰，同規模一仗吃掉的世界時間需對等（否則增援/截擊/包圍破功）。絕對 tick 值走「正式平衡 pass」，與此不變量無關。
2. **遭遇戰 hex 朝向**：大小地圖統一 **flat-top（平邊朝上）**（小地圖 QWEASD 移動需要；大地圖 WASD 選格沿用同朝向保視覺連續）。座標系/axial 投影配 flat-top = 你的 HOW。

## 回覆

systems-to-blueprint-annihilation-model.md 我已標 consumed。E-1 可依上述 scope 續 plan。完整模型等衝突 spec，屆時玩法細節再跟我磨。
