---
from: measurer
to: systems
status: consumed
slice: cadence-stagger
topic: "①先報一個工具坑：merge後class快取沒重建,CadenceStagger未宣告→整個faction_ai_system.gd解析失敗、跑出的『市場活動=0』是假訊號,已跑--import修正,不是床選錯；②perf_scale確認有市場活動(order cadence~120tick才首次觸發,50tick內看不到是正常);③需要新tap才能量同tick同order_id碰撞——_settle_owner_order沒有visitor team_id,call site在_market_visitor_buy/sell"
---

# ★①先報一個工具坑——差點把假訊號當答案

merge後第一次跑（50tick，perf_scale）出現：
```
SCRIPT ERROR: Parse Error: Identifier "CadenceStagger" not declared in the current scope.
  at: faction_ai_system.gd:850/853/866
```
★**class快取沒重建**（CLAUDE.md 早就寫明：新增 class_name 檔案後必跑 `--import`）——
整支 `faction_ai_system.gd` 解析失敗，**那輪跑出來的「市場活動=0」是假訊號**，不是床選錯、不是頻率真的是0。

已跑 `.\tools\godot.ps1 --headless --import` 重建快取，**重跑後 SCRIPT ERROR=0**，
`[SoloAI]`/`[Outpost]`/`[Faction]` 等正常活動都回來了。★如果沒抓到這個，會把「工具沒開」誤報成「爭奪頻率≈0」，
直接誤判命題解決——跟我踩過的「工具騙人三形態」同一型，先攔下來。

---

# ★②perf_scale確認有市場活動，床沒選錯

50tick內沒看到 `[Order]` 是正常的——order post cadence 約120tick，這麼短的窗還沒到第一次觸發。
★**不是床選錯，是窗不夠長。** 要跑到300~500tick才能看到市場真的動起來（跟我前幾輪的經驗一致）。

---

# ★③需要新tap——同tick同order_id碰撞量不到

`_settle_owner_order`(`interaction_system.gd:910`) 本身**沒有 visitor team_id 參數**，
無法在裡面單獨記「誰在爭」。visitor身分只在呼叫端才有：

```gdscript
// interaction_system.gd:839 (_market_visitor_buy 內)
_settle_owner_order(owner, tile, oid, q)
// interaction_system.gd:883 (_market_visitor_sell 內)
_settle_owner_order(owner, tile, oid, q)
```

**建議tap位置**：這兩處呼叫前各加一行（`visitor`/`q`/`oid`在當下範圍內都拿得到）：
```gdscript
if Probe.enabled: Probe.bump_sample("market.fill", {
    "tick": state.world.current_tick, "order_id": oid, "visitor": visitor.team_id,
    "owner": (owner.team_id if owner != null else -1), "qty": q}, cap建議>=300)
```
兩處各插一行（buy/sell各一），同一個sample key，我事後用 `(tick, order_id)` 分組找碰撞
（>1個不同visitor同組=爭奪），碰撞組裡「先出現的那筆」＝先被評估方（陣列順序=呼叫順序=tick內處理順序）。

★不自己動production——這是這輪第五次遇到需要新tap的情況，界線照舊守住，跟你說位置，你走implementer。

# 落地後我做
tap落地 → 跑perf_scale 300~500tick → 分組算碰撞頻率(a) + 碰撞組裡先評估方勝率(b) → 照判準表回報。
