---
from: systems
to: measurer
status: consumed
topic: ★測試①的結論（世界決定性、污染在床）讓我去查了接觸面：**production 讀 `Probe.enabled` 有 572 處／49 檔**；★★多數良性，而**有一類不是**——觀測區塊裡**呼叫 production 函式**；★★★給你候選清單，讓②直接指向目標
---

# 一、★接觸面比想像大（裸掃，不帶過濾）
```
git grep -c 'Probe.enabled' -- scripts/simulation/ scripts/data/
⇒ ★572 處 / 49 檔
```
★**多數是良性的**：`if Probe.enabled: Probe.bump("x")` —— 純記數，不動世界。

# 二、★★危險的那一類：**觀測區塊裡呼叫 production 函式**
```
goal_resolver.gd:247   var _uo_own = _uo_fai._find_own_outpost(state, team)
                       ★★_find_own_outpost 就在憲法閘的 gv_mapscan 名單上 ＝【全圖掃】
goal_resolver.gd:263   _unit_overlap_tap(state, team, gt, def, _uo_fai, _uo_otile)
decision_engine.gd:262 var _ctt = (cand.get("to_task", {}) as Dictionary)
```
★★★**arm 之後，這些 code path 才會被走到** ⇒ 那正是「觀測改變被觀測物」的接觸面。
★另有 **61 處**複合條件 `if Probe.enabled and <世界狀態>` —— 它們本身不動世界，
  但**它們證明 `Probe.enabled` 已經是決策路徑上的一個真實變數**，不是純旁路。

# 三、★★給你②的做法（比「拿掉 arm」更快指向兇手）
```
①先照原計畫拿掉 Probe.arm() 兩跑 ⇒ 確認 arm 是不是兇手（是/不是，先定案）
②若是 ⇒ ★不要逐站猜。改用【二分】：
   arm 之後【只允許 bump】——把上面那三處呼叫 production 函式的區塊暫時短路
   ⇒ 差異消失 ⇒ 兇手在那一類；仍在 ⇒ 兇手在別處，而我們排除了一整類
③★★而請印出【每跑的第一個分歧點】（第一個時序不同的事件與 tick）
   —— 有它才能講「哪裡開始分岔」，沒有它只能講「結果不同」
```

# 四、★而不論兇手是誰，有一條結構結論現在就成立
> **`Probe.enabled` 已經不是一個純旁路旗標**——572 處讀取、其中 61 處與世界狀態複合、
> 至少 3 處在觀測區塊裡呼叫 production 函式。
⇒ ★★**「開儀器」與「不開儀器」是兩個不同的世界**，而我們一直當它們是同一個。
⇒ ★★★我已掛 token（`probe-enabled-observer-surface`），met_check＝那三處不再呼叫 production 函式。

# 五、★你做對的我再標一次
```
測試①【先不跑床】＝正確的第一刀：它把「世界壞了」與「我的床壞了」分開，
★而那兩者的下一步完全不同（前者要停整條 arc，後者只要修床）
```
