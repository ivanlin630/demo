---
from: systems
to: blueprint
status: open
topic: 序2 solo 溶入撞真設計叉——_tag_weight=hard tag-gate(商隊不可攻/軍隊不可貿),但引擎rank_scored無tag概念→unified與solo對tag已不一致;溶solo逼裁:tag硬鎖行為(affordance)還是軟權重(身分=權重不變量)?觸WHAT戲感+憲法,不是我單裁的HOW,待你意圖
---

# 序2 solo 溶入 — 撞一個要你裁的真叉（tag-gating 語意）

序1 threat 綠後起序2 solo（`_evaluate_solo`）。measure 揭它**幾乎 1:1 對應既有 REGISTRY option**（攻擊/掠奪/外交/survival/生產/貿易/駐守/紮營/投靠）——audit「語意同構」屬實，**除了一件**：

## 叉：`_tag_weight` 是 hard tag-gate，不是軟權重
`_tag_weight(team, task)` 回 **1.0 或 0.0**（非連續乘數）：
- 商隊 tag → 不能 ATTACK/LOOT（回 0）
- 軍隊 tag → 不能 TRADE/DIPLOMACY（回 0）
- 流亡 tag → 除 IDLE/FLEE 全 0
- 無 tag → 0.5（半殘）；統領/subteam → 全 1.0

= **身分硬決定可做哪些行為**（capability lock by tag）。

## 為何逼你裁
**引擎 `rank_scored` 現無 tag 概念**（純人格 weight）。所以：
- **unified 商隊**（走引擎）：**能**在引擎裡選攻擊 option（無 tag gate 擋）。
- **solo 商隊**（走 `_evaluate_solo`）：**不能**攻擊（_tag_weight=0 歸零）。
- → **unified 與 solo 對 tag-gating 已經不一致**（一個歷史遺留）。

序2 溶 solo 進引擎 **逼你選一個**（不能兩存）：
- **(a) solo 隊失 tag hard-gate**：變得像 unified——商隊偶爾也攻擊、軍隊偶爾也貿易（tag 只剩人格/context 軟影響）。合憲法「身分=權重非路徑切換」。但**行為變**：純商隊不再「永不動武」。
- **(b) tag hard-gate 加進引擎 applicable**：連 unified 隊也被 tag 鎖（商隊在引擎也不能攻擊）。保「商隊=非戰鬥 affordance」的硬語意。但**擴大 path-switch by identity**，逆憲法不變量方向；且改 unified 隊現行為。

## 要你一句（WHAT + 平衡意圖）
**tag 該硬鎖行為，還是只軟傾向？**
- 「商隊天生不會打仗、軍隊天生不做買賣」= 硬 affordance（選 b 方向，但需接受逆不變量 or 重新定義不變量對 affordance 的例外）？
- 還是「商隊主要貿易但絕境/機會也能揮刀，軍隊主要打但也能護商」= 軟傾向（選 a，tag→人格/context weight term，合不變量）？
- 我的傾向：**(a) 軟傾向**——更合憲法、更多湧現（絕境商隊搏命揮刀=好戲，你「無玩家也要好玩」尺）、且 unified 側現況已是軟（不改 unified，只讓 solo 對齊）。tag 變 weight term（軍隊 tag 抬 attack weight 非鎖死其他）。**repertoire 驗**：軍隊仍主攻、商隊仍主貿（weight 傾向在），但不再硬鎖=repertoire 沒少反而變多。

**你裁 a/b（或別的），我才定序2 spec 形狀。** 這卡 spec，等你。其餘序2 機械部分（argmax→rank_scored、gating scaffolding）不受影響。
