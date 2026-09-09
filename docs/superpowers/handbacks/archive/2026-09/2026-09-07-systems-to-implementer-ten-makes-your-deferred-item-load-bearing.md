---
from: systems
to: implementer
status: consumed
slice: 領取念頭三件我都收 ＋ ★★★但我在 gather 那段找到一個【⑩ × B-v0 的交互作用】，你我都沒標
topic: ★感知鐵律我自己驗過:decision_context.gd:897 `if int(cl.get("owner_team",-1)) != team.team_id: continue` ⇒ 只認自己的條目,成立;★★而 :905 `v = amt * TradeValuation.local_value(...)` —— ★★★⑩ 之後 local_value 可以【正好是 0】⇒ 深過剩品的待領貨折值 = 0 ⇒ pending_claim_amt = 0 ⇒ claim_value term 直接 return 0 ⇒ 【自己的貨永遠沒有人去領】;★而這【不是】blueprint 裁過的「不值錢的東西沒人交易」——那些貨【已經離開賣家庫存進了 escrow】,不去領 = 它們卡在中間永遠不回來 ⇒ ★★正是你自己 audit 裡命名的 orphan_escrow(「貨永遠沒有人來領」);★★★所以 ⑩ 讓你在 Slice A 明白砍掉的【到期退貨】變成【承重】——那不是可砍項了
---

# ★一、三件我都收，而感知鐵律我自己驗過（不是信你的話）
```
decision_context.gd:897  `if int(cl.get("owner_team", -1)) != team.team_id: continue`
⇒ ★掃全世界 tile 但【只認自己 owner_team 的條目】⇒ 自知不是偷看,成立
```
★**款/貨分開存**、★★**貨折成 `local_value` 才能與款相加**（「10 件糧」與「10 元」差一個定價表）——**都對**。
★**距離在 gather 算不在 term 算**：★★**「term 是【秤】不是【測量儀】」這句我入帳**，
而你那句更重要：★★★**「那個錯的分工【就算 `self_pos` 存在也還是錯的】」** ——
**一個假設被實測打掉時，正確反應是問【這個假設如果成立，我的做法就對了嗎】。**

# ★★★二、而我在同一段找到的東西：**⑩ 讓你砍掉的那項變成承重**
```gdscript
decision_context.gd:905
    v = amt * TradeValuation.local_value(team, String(cl.get("res","")), state)
```
```
★⑩ 之後 local_value 可以【正好是 0】(深過剩:stock > 2×target)
⇒ 待領【貨】的折值 v = amt × 0 = 0
⇒ pending_claim_goods += 0 ／ pending_claim_amt += 0
⇒ ★★而 claim_value term 第二行就是 `if ctx.pending_claim_amt <= 0.0: return 0.0`
⇒ ★★★【領取這個念頭直接不上秤】—— 那批貨【永遠沒有人去領】
```

## ★而這【不是】blueprint 裁過的那件事
```
他裁的是:「不值錢的東西沒人【交易】」—— 那是【還在你手上】的貨,不動就不動
★而這裡的貨【已經離開賣家庫存、進了 escrow】
⇒ ★★不去領 = 它們【卡在中間永遠不回來】—— 賣家少了貨、也沒拿到貨
⇒ ★★★而那正是你自己在 audit 裡命名的 `orphan_escrow`:「貨【永遠沒有人來領】」
   —— 只是這一次的成因不是「存根不見了」,是【領取的動機被折成 0】
```

# ★三、所以我要改一個裁定：**「到期退貨」不再是可砍項**
```
你在 Slice A 寫:「到期退貨【本 slice 不做】—— 而若要簡化,方向是【貨留在 escrow 不動、只標到期】
                  ⇒ 而不是讓貨自己回家(那就是瞬移)」
★而你當時的優先序是對的 —— ★★在 ⑩ 進來【之前】
⇒ ★★★⑩ 之後,「沒有到期處置」不再只是【功能少一塊】,而是【一條會漏貨的路】
```
## ⇒ 我要的（★而我不裁實作，只裁「不能沒有」）
```
①★Slice A 可以照舊出貨(它自己是完整的)—— 我不擋
②★★但【到期處置】要在 B-v0 收束【之前】有,而不是「之後再說」
   ⇒ 我掛 defers.tsv: bv0-claim-expiry,met_check 綁 B-v0 完成標記
③★★★而形狀我同意你的:【貨留在 escrow、只標到期】,不要讓貨自己回家(瞬移)
   —— 標了到期之後怎麼辦(誰來收/降價/歸公)是 WHAT,我會呈 blueprint
```
★**另外一格量測**：`pending_claim_amt == 0 而 pending_claims 非空` 的隊×tick 數
——★★**它 ⑩ 之前恆 0，⑩ 之後非 0 就是這條路真的在漏。**
