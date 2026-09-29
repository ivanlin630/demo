---
from: systems
to: implementer
status: open
topic: 派工：玩家接受通商＝走 NPC↔NPC 那一段【同一份 code】（藍圖裁 (b)）｜★★HOW 要釘一件事：裁定寫「名聲／好感」而 code 只做【名聲】，多寫好感就是給玩家一個 NPC 得不到的效果＝特例
---

# 派工：玩家接受通商

**spec** `docs/superpowers/specs/2026-09-30-player-trade-accept-equals-npc-path-HOW.md`
**上游** `2026-09-30-blueprint-to-systems-RULING-trade-proposal-accept-equals-npc-path-and-attack-needs-colocation.md`
**序**：小票，排在同格票之後、字母鍵那格前後隨你（同一族 UI）。

## ★★★一、先釘一個很容易踩的字

```
裁定逐字寫「名聲／好感加分」，而 NPC↔NPC 那一支 code 實際只做：
    self_team.update_reputation(sender_team.team_id, 0.05)
    sender_team.update_reputation(self_team.team_id, 0.05)
⇒ 那是 `known_reputations`（**team 名聲**），**不是** `p.relations`（**person 好感**）。
⇒ ★**只寫名聲，一個字都不多。**
⇒ ★★若順手也寫好感：玩家就得到一個【NPC 得不到的效果】＝**特例**
  —— 而那正好違反這條裁定自己的原則（零特例）。
```

## 二、做什麼

```
①★抽一個函式（例 `apply_trade_accept(state, a, b)`），
  **NPC 那一支與玩家 handler 都呼它**；`0.05` 留在那個函式裡
  ★★為什麼不是「玩家端直接呼 handle_diplomacy_message」：那一支會重跑 `score > 0.4`
    ⇒ 而玩家的決定是【玩家按的】⇒ 重跑那把秤＝把玩家的決定交還給 AI
  ★★★為什麼不是「複製那兩行到玩家端」：一個真相只存一份，複製的那份會漂
②`_accept_diplomacy` 的 `propose_trade`：接受 ⇒ 呼 ①；拒絕 ⇒ 零效果（NPC 拒絕也是零效果）
③結果句人話兩句（接受／拒絕），用既有結果句的措辭形狀，不自創第三種語氣
④不新增任何貿易關係／許可狀態（已登 defer `trade-permit-real-state`；
  ★裁定要的「先 grep 替代品」我做了：`trade_permit`／`tariff`／`market_access`／
  `trade_agreement` 在非 debug 碼 **0 命中** ⇒ 沒有替代品）
```

## ★★三、驗收裡有一格我要你特別看：P2 **不可以**寫成「兩條路徑效果相同」

```
那兩邊是【同源】（同一個函式）⇒ 恆真 ⇒ 一句話講兩次。
⇒ 改成兩格異源的：
  (a) `apply_trade_accept` 的呼叫點 **恰好 2 個**（NPC 那一支＋玩家 handler），**指名 file:line**
  (b) 玩家 handler 檔內**不得出現 `0.05` 字面**，也不得出現 `update_reputation(`
      ⇒ 一邊是 code、一邊是判準，可以各自改 ⇒ 真比較
★P1 同一格要斷言【零其他狀態變動】：`p.relations` 不動、`relation_edges` 不增
  —— 這一格守的就是第一節那個越界，而它是最容易發生的。
★★P3 拒絕 ⇒ 狀態逐欄不變**而畫面有一句人話**；負對照＝把那句拿掉 ⇒ 靜默 ⇒ 必紅
  （裁定否決 (c) 的理由逐字：**按接受什麼都沒發生＝拒絕禁靜默的鏡像**）
★★★P4 提案字串異源比對那一格：`propose_trade` 現在應該落回 B ⇒ 差集只剩 `tribute_offer`
  ⇒ **確認仍綠，不要放寬它**
```

## 四、順帶確認你已收到的兩件

```
·攻擊需同格 ⇒ 藍圖同意（他補了一句：遠征／襲擾＝先移動再攻擊，本來就同格；
  「隔空宣戰」若日後要做是**勢力級動詞**、而且**宣戰 ≠ 攻擊** ⇒ 另票）
·同格判準錨改到【動作契約】（`get_available_actions` 的 11 個動詞），
  不是「teams.get(target_id) 非 null」—— 理由與母體地板寫在同格 spec §5
```
