# HOW：玩家接受通商 ＝ 走 NPC↔NPC 那一段**同一份** code（零特例、零新狀態）

**上游 WHAT** `docs/superpowers/handbacks/2026-09-30-blueprint-to-systems-RULING-trade-proposal-accept-equals-npc-path-and-attack-needs-colocation.md`
（(b)：接受＝名聲加分、零新狀態；拒絕＝同 NPC 拒絕的後果；結果句人話；
通商許可／關稅／市場准入那種真狀態＝登待辦，等有消費者再開。否決 (c)，理由：
**按接受什麼都沒發生＝拒絕禁靜默的鏡像**。）

## ★★★§1 前提（逐字，我開檔核過）

```
NPC↔NPC 接受通商的【全部】效果（diplomatic_ai_system.gd，"propose_trade" 那一支）：
    if score > 0.4:
        self_team.update_reputation(sender_team.team_id, 0.05)
        sender_team.update_reputation(self_team.team_id, 0.05)
        if Probe.enabled: Probe.bump("dip.proposal_accept")
        return "accept"
    return "reject"
⇒ ★**只有雙向 team 名聲 +0.05**。
⇒ ★★**注意用詞**：上游裁定寫「名聲／好感加分」，而 code 走的是
  `known_reputations`（**team 名聲**），**不是** `p.relations`（**person 好感**）。
  ⇒ ★★★若玩家端順手也寫好感，玩家就得到一個【NPC 得不到的效果】＝**特例**
    —— 而那正好違反這條裁定自己的原則。**本票只寫名聲，一個字都不多。**
拒絕：NPC 那一支 `return "reject"` ⇒ **零效果**（沒有記憶、沒有名聲罰）
⇒ 玩家拒絕也是零效果，★但**結果句要人話**。
既有替代品普查（裁定要求先 grep）：`trade_permit`／`tariff`／`market_access`／`trade_agreement`
  在 `scripts/` 的非 debug 碼裡 **0 命中**（只有 player_api_mapper 的兩句 UI 文字）
  ⇒ **沒有替代品** ⇒ 真狀態登 defer。
```

## §2 做什麼

```
①★把 accept 的效果**抽成一個函式**（例：`apply_trade_accept(state, a, b)`），
  NPC 那一支與玩家 handler **都呼它**。
  ★★為什麼不是「讓玩家端直接呼 handle_diplomacy_message」：那一支會**重跑 score > 0.4**
    ⇒ 而玩家的決定是【玩家按的】，不是秤出來的 ⇒ 重跑那把秤＝把玩家的決定交還給 AI。
  ★★★為什麼不是「在玩家 handler 裡複製那兩行」：**一個真相只存一份** ——
    複製的那一份會漂（下一次有人改 0.05 只會改到一邊）。
  ⇒ **0.05 這個常數留在被抽出的函式裡**，玩家端不得出現它的字面。
②`_accept_diplomacy` 的 `propose_trade` 那一支：接受 ⇒ 呼 ①；拒絕 ⇒ 零效果
③結果句人話（接受／拒絕各一句），★用既有結果句的措辭形狀，不自創第三種語氣
④~~新增任何貿易關係／許可狀態~~ **不做**（裁定：登待辦）
```

## ★★§3 驗收

```
P1 [接受＝名聲] 玩家接受通商 ⇒ **雙向** known_reputations 各 +0.05（印前後值）
   ★★同一格斷言【零其他狀態變動】：`p.relations` 不動、`relation_edges` 不增
     —— ★★★這一格守的是「不要順手多給玩家一個效果」，而那是最容易發生的越界
   ｜負對照：把 ① 那個函式換成 `pass` ⇒ 名聲不動 ⇒ 必紅

P2 [零特例] ★**不可以**寫成「玩家路徑與 NPC 路徑效果相同」——
   那兩邊是**同源**（同一個函式）⇒ **恆真**（同一句話講兩次）。
   ⇒ 改成兩格**異源**的：
     (a) `apply_trade_accept` 的呼叫點＝**恰好 2 個**（NPC 那一支 ＋ 玩家 handler），指名 file:line
     (b) 玩家 handler 檔內**不得出現 `0.05` 字面**、也不得出現 `update_reputation(`
         ⇒ 一邊是 code、一邊是判準 ⇒ 它們可以各自改 ⇒ 真比較

P3 [拒絕＝零效果但有人話] 玩家拒絕 ⇒ 所有狀態逐欄不變，**而畫面有一句人話**
   ｜負對照：把那句話拿掉 ⇒ 靜默 ⇒ 必紅
   ★這一格是裁定否決 (c) 的那句話的執法：**按了什麼都沒發生＝禁靜默的鏡像**

P4 [提案字串比對仍綠] `propose_trade` 現在應該落在 B（handler 認得它）⇒
   異源比對那一格的差集只剩 `tribute_offer`（指名豁免）⇒ 確認仍綠，**不要放寬它**

P5 headless ≥1000 tick、ui-flow 綠、全電池 BATTERY_RC=0
   ★fp：先量再換基準（預測不是授權）；沒變就不要動並把為何沒變寫進卷面
```

## §4 不在本票

```
·通商許可／關稅／市場准入的真狀態 ⇒ defer `trade-permit-real-state`
  ★解除條件＝市場厚度或政權財政線**真的有消費者**（不是「以後有空」）
·「隔空宣戰」（勢力級動詞，宣戰 ≠ 攻擊）⇒ 上游已裁另票
```
