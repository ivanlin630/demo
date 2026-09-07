# 資訊戰四動詞（偵察/反情報/販賣 + 造謠統一框架）— 未來 arc 停車筆記

> 藍圖×用戶 brainstorm 2026-07-19（無信箱藍圖 session，純未來願景）。**非現在派工**。存 `notes/`（不碰 canonical、不發 handback）。observe-gated。承 [[2026-07-19-active-rumor-fabrication-brainstorm]]（造謠＝第①動詞），此筆記補其餘三動詞 + 統一框架。

## 統一框架：四個主動資訊動詞
讓遊戲命題「資訊不透明」從**被動處境**（你恰好知道較少）變**主動爭奪**（投資去多知、否認他人、武器化、變現）。被動傳播（message propagation）+ 這四動詞＝完整資訊戰。

| 動詞 | 幹嘛 | 已有 infra | 缺口 |
|---|---|---|---|
| **造謠**（製造）| 憑空捏假注入傳播網 | belief-store / G3 multi-claim・credibility | 決策 caller（emit_message 只 event 呼叫）|
| **偵察**（獲取）| 花資源/風險降 belief 不確定 | 玩家 InquirySystem、偵查/潛行 skill、G3 scout-verify | **NPC 主動偵察決策**（玩家→NPC 有、NPC 間無）|
| **反情報**（否認）| 保己方情報 + 餵敵假料 | observation-deception（apply_observation_deception 親見欺敵）| 抓/逐偵察、定向餵假 |
| **販賣**（變現）| 情報當可交易商品 | 貿易/economy + belief | **情報＝貿易品**（最新）|

## 三動詞 WHAT（全引擎決策、人格 gate、騎 belief，非腳本）

### 主動偵察
- 大決策前（打不打？貿不貿？逃不逃？）花 偵查/潛行 人偵敵 → 降 belief 不確定 → 決策更準。
- **慎重先偵、魯莽盲動**；代價＝時間 + 偵察者會被抓/殺。
- **填 belief-store 衰減成未知的高頻層**（位置/戰力/情緒）。
- 現況：玩家 `InquirySystem`（問 NPC，rel>0.5 誠實否則失真，讀 `BeliefSystem.best_estimate`）存在；NPC 間戰略偵察決策＝缺口。

### 反情報
- 偵察的防守鏡像 + 造謠的定向版。
- (a) 抓/逐敵諜、opsec（保己方情報）；(b) **餵敵偵察假料**（定向欺敵，計謀 gate）。
- 現況：observation-deception（被觀察時偽裝強弱/身份）已在；抓諜、定向餵假＝缺口。

### 情報販賣
- 知道值錢事（商隊位置/敵弱點/市價）的隊/人**賣情報** → 情報成經濟商品 → 長出**探子/情報販子/掮客**。
- 價值＝情報多能改善買方決策。
- **接 economy arc**（資訊當新交易類）。最新、infra 缺最多。

## ★連接組織：資訊層是今天所有維度的結締組織
- **偵察 vs 造謠＝軍備競賽**（偵察查證謠言真假；高技能偵察者拆穿造謠、低技能受騙）。
- **販賣 + 正統**：賣鄰邦「失了天命」的情報。
- **反情報 + 繼位**：繼位危機時藏自己虛實。
- ∴ 四動詞 + 被動傳播＝完整資訊戰，且 **偵查/潛行/計謀 skill 家族**（諜/探/宣傳專才）從此有整體意義（技能=理解，連 game-design 認知系統）。

## 憲法對齊
- 四動詞全＝引擎決策（人格 gate、cost/benefit 秤），騎 belief-store + G3，非腳本 event。
- 讀寫全走 belief（感知鐵律）：偵察填 belief、造謠/反情報寫他人 belief、販賣傳遞 belief。虛實有效因對方只有 belief。

## 序（backlog）
1. framework 綠（god-view + belief-store 泛化）→ full-HD live 觀察。
2. 大量 infra 已在（belief/inquiry/observation-deception/skills/G3）；新增＝NPC 偵察決策 caller、反情報決策、情報=貿易品。
3. **情報販賣接 economy arc**（資訊交易類）；其餘接 belief-store + 決策引擎 option。

## 溯源
本 session brainstorm（四動詞統一框架 → 偵察/反情報/販賣 各 WHAT → 連接組織）；`inquiry_system.gd`（玩家 inquiry）、`distortion_engine.gd`（observation-deception）、`person_data.gd`（偵查/潛行 skill）；G3 資訊戰 arc（archived：scout-verify/credibility/multi-claim）；接今天四筆記；[[2026-07-19-active-rumor-fabrication-brainstorm]]。
