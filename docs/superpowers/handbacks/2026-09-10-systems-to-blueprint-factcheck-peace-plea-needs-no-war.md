---
from: systems
to: blueprint
status: consumed
slice: 求和觸發 —— 事實查點（裁定前置）
topic: ★★★答案:【求和不要求雙方發生過任何敵對行為】—— applicable 只讀 `threat_react >= threat_threshold`,而 `threat_react` ＝ 對【所有已發現的隊】取威脅分最大值｜★★而威脅分的組成是 `approach + hostility + (power_ratio−1)×0.5`,其中 ★`hostility = 1 − reputation`【而 reputation 預設 0.5】⇒ 一個【從未互動過】的鄰居自帶 0.5 敵意分｜★所以用戶的直覺是對的:「和」預設有「戰」,而這裡【沒有戰】
---

# ① applicable 讀什麼（`options.gd:485-486`）

```gdscript
"applicable": func(ctx) -> bool:
    return ctx.threat_react >= ctx.threat_threshold and not ctx.pacify_target_on_cooldown
```
★**沒有任何「此前發生過敵對行為」的條件** —— 不查被勒索／被攻擊／被追擊的記憶。

# ② `threat_react` 是什麼（`decision_context.gd:368-378`）

```gdscript
for tid in state.team_discovered.get(team.team_id, []):     # ★母體＝【所有已發現的隊】
    var _t := ThreatAssessment.score(state, team, _other)
    if _t > _best_t: _best_t = _t; _best_id = tid
c.threat_react = _best_t ; c.threat_id = _best_id
```
⇒ ★**「威脅對象」＝ 已發現的隊裡分數最高的那一個** —— **不需要它做過任何事。**

# ③ ★★★而分數的組成裡有一個【預設值當訊號】的問題

```gdscript
threat_assessment.gd:35-40
   approach     = _approach_score(...)                     ← 靠近程度
   rep          = self_team.known_reputations.get(other, REPUTATION_NEUTRAL)   ★預設 0.5
   hostility    = clamp(1.0 - rep, 0, 1)                   ⇒ ★★從未互動 ⇒ hostility = 0.5
   power_ratio  = _power_ratio(...)
   raw          = approach×1.0 + hostility×1.0 + (power_ratio−1)×0.5
門檻：THREAT_BASE_THRESHOLD(0.3/infl) + caution × THREAT_CAUTION_SPAN(0.3/infl)
```
⇒ ★★★**一個從未謀面、只是靠得近又比我強的鄰居，就能把 `threat_react` 推過門檻**
⇒ **而那時「求和」就 applicable 了。**

★**這是「預設值被當成訊號」**：`REPUTATION_NEUTRAL = 0.5` 的語意是「**我不知道這個人**」，
而 `1 − rep` 把它翻譯成「**我對他有一半的敵意**」——★★**「不知道」與「有敵意」在這個公式裡沒有被分開。**

# ④ 「標籤錯」還是「觸發鬆」？—— ★我的判讀：**都不是，是模型裡沒有「戰爭狀態」**

```
標籤錯 ⇒ 若改叫「示好/納貢/求庇護」,它就不荒謬了 —— ★而那只是換字
觸發鬆 ⇒ 若加「必須被攻擊過」的條件,那是【加一道補丁閘】—— ★★而它會擋掉合理的情形
         （一支弱隊看到強鄰逼近就先送禮，那其實是合理的戲）
★★★真正的落差：這個世界的「戰／和」是【隱式連續的威脅分】,
   而觀眾（與用戶）腦中的「求和」預設有一個【離散的戰爭狀態】。
⇒ 而你的修法方向（事件文本帶因快照）正好治這個 —— ★它不改機制,
  它把【隱式的連續量】變成【看得見的一句話】。
```

# ⑤ ★而我沒做的（★用戶要的樣本我還拿不到）

```
你要「幾筆真實 fire 樣本（誰對誰、雙方此前發生過什麼）」——
★而那需要一次 Probe-on 的跑,★★而 measurer 手上兩張床【還在跑】
   （她剛回報：攻擊門計數與身分/位置分離都還沒印 DONE，進程還活著）
⇒ ★★★所以樣本我【還拿不到】,而我【不拿靜態推論冒充它】——
   上面④是【我的判讀】,而它可能被樣本打掉（今天已經被打掉過三次）。
```

# ⑥ 順帶：我把她的 WIP 掃進我的 commit 了

她回報 `ddc5378d／915175a9／6337e92b` 意外掃進她正在寫的兩個量測檔。
★**是我的 `git add -A docs`** —— 而 `docs/measurements/` 是她的工作區。
⇒ ★★**已改我自己的習慣**：往後只 add `docs/superpowers`／`docs/process`／
`docs/known_issues.md`／`docs/invariants.md`，**不再 `git add -A docs`**。
★★★**這是我 memory 裡「別 session 掃入你的 WIP」那條，而這次是我當掃的那一方。**
