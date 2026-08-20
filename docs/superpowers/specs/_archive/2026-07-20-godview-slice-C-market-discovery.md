# spec：god-view Slice C — 市場 belief-gate + market-discovery belief store

> 層級：L1（新 belief store 基建 + 貿易目標選擇改，economy measure 敏感）。off main HEAD。god-view 殲滅 arc 倒數第二（A/F/E/D/B 已 merged，剩 C+1119）。★異質 R²（新基建+economy 行為敏感+難逆）。
> 來源：god-view audit Slice C。blueprint WHAT 裁（2026-07-19-godview-rulings-B-C）：**市場零豁免、必經 belief**（否決 invariants 舊「公開地標豁免」）；市場資訊永遠傳播（憑聽過/belief），冷啟動憑「聽過附近有市集」。

## god-view 後門（市場全圖掃）
`_nearest_market_outpost`（`faction_ai_system.gd:2112`，★行號驗過非 audit stale 2065）：**全掃 `state.world.tiles`** 找 outpost（level>0 非自家）選最近 = **god-view**（不論隊知不知道該市集，全圖瞬知）。汙染 economy 診斷（貿易目標憑全知非傳播）。

## blueprint WHAT：市場零豁免、憑 belief（聽過）
市集位置**永遠靠傳播/親見習得**（非全圖掃）。位置固定→習得後穩定，但**取得永遠靠傳播**（名聲高傳播率自然廣傳）。

## ★★v2 訂正（異質 R² BLOCKING 後）：premise HOLDS + 3 前置
> **異質審親驗 market-relay premise HOLDS（異於 Slice B，refute 訂正 reviewer 自己初判）**：`message_system:194-207 _exchange_intel` 複製全 known msg（不濾 type）+ order 訊息帶 `origin_pos`（`post_order:30-33`，`_market_pos`=下單隊 outpost tile）+ `outpost_built`（`outpost_system:285`，TTL30d）帶 source_pos，皆騎 :194-207 relay copy。`received_buy/sell_orders`（order_system:164-187）**今天就消費這 relay 位置**（`best_arbitrage_order` 是 `_merchant_trade_target:2098` 主路，`_nearest_market_outpost` 是 fallback）。∴ **relay 聽說 = aggregation plumbing（從已到訊息 harvest origin_pos），非 Slice B 那種需從零建**。

## 修（v2：harvest + belief-gate + 3 前置）
### ① market-discovery belief store（harvest 既有 plumbing，非建 relay）
`WorldState` 加 `team_market_known: Dictionary`（`team_id → Set[tile_id]` 已知市集 outpost tile）。**三源**：
- **創世**：知附近市集（proximity≤`CREATION_KNOW_RADIUS`，同 Slice B）。
- **直接親見**：在/近 outpost tile（vision 半徑內）→ 加入。
- **★relay harvest（非建）**：從 `team_known` 的 order/outpost_built 訊息 **harvest `origin_pos`/`source_pos` 進 known**（既有傳播路，reviewer 坐實流通）。**★caveat：濾 `tile.outpost_level>0`**（`_market_pos` 對無 outpost 隊 fallback live team pos=noise，須濾真市集）+ **無新 RNG**（harvest 既有 entry，不加「注意到市集」新 dice）。

### ② `_nearest_market_outpost` belief-gate（`faction_ai:2112`）
改：**只掃 `state.team_market_known[team_id]`**（已知市集），非全 tiles。無已知→回 (-1,-1)。

### ③ ★貿易 option (-1,-1) guard 豁免 resident（BLOCKER 1 精修，v3）
> **v2「對齊 7 兄弟 blanket (-1,-1)→IDLE」太鈍**：擺攤 case 的 (-1,-1) 是**合法原地交易非無事可做**。擺攤 keyed `current_task==TASK_TRADE`（`interaction:238/714/720/742/769`）；resident 擺攤=PRODUCE 居民原地 TASK_TRADE 待客。`_merchant_trade_target` 對 resident 回 (-1,-1)（`_nearest_market_outpost:2119` 排除自家 outpost→resident 無外部市集）。∴ blanket guard 把「無外部市集的 resident 擺攤」翻 IDLE→村攤關門→r3 血證 regression（`options.gd:16-18` 註警）。

**修（豁免 resident，只 roaming merchant→IDLE）**：
```gdscript
# 貿易 to_task：只 roaming merchant 無市集→IDLE;resident 擺攤 (-1,-1)=原地交易保 TASK_TRADE
if target == Vector2i(-1, -1) and not _is_resident_team(state, team):
    return {"task": TeamData.TASK_IDLE}
```
（`_is_resident_team` 存在 `faction_ai:495`。★**別加 applicable market-known 檢查**——同理濾掉擺攤，r3 警告勿加鎖。）

### ④ ★team_market_known cleanup 只觸發 demolish（v4 訂正，reviewer 自我修正 v2/v3）
> **v2/v3「hook set_owner 全 owner-change」= OVER-CLEAN（reviewer refute 自己 v2 prescription）**：`team_market_known` 存 **tile_id（位置）only**。**capture（owner 變）保 `outpost_level>0`=市集還在該 tile=entry 不懸空**（市集位置沒變，只換老闆）。清掉=**忘掉有效市集** → 違 blueprint「位置固定→習得後穩定」+ warzone trade 反覆斷（warzone 市集頻繁易主，每 capture 清=隊一直忘市集）。
> ∴ 市集**只在 demolish（`outpost_level→0`）才真消失**（entry 才懸空）。

**修（cleanup 只觸發 `outpost_level→0`=demolish）**：
- **hook demolish（`outpost:332`，唯一 `outpost_level→0` 路）** → 清**所有隊** `team_market_known` 對此 tile 的條目（tile 級=所有知此市集的隊都該忘，因市集拆了）。
- **★不 hook set_owner/capture**（市集還在=known 位置仍有效，換老闆的 stale-賣單問題由 order 系統 staleness + harvest 濾 `outpost_level>0` 處理，非清 known）。
- ★market_orders 本身 pre-existing 洩漏（capture/demolish 不清 market_orders）=記 known_issues（team_market_known demolish-only cleanup=正解，別繼承此病）。

## ★measure（economy 行為敏感）
市場全知→belief-gate = 貿易目標從「全圖最近」變「已知中最近」→ 動貿易/economy 行為。**非盲改**：
- **before/after doom-delta**（seed1337/42/4201）+ **economy 對照**：貿易觸發率/成交量/coin 流通、市集發現曲線（隊逐漸知市集經 proximity/vision/relay）。
- **★冷啟動不死鎖**：開局隊憑創世-nearby 市集出得了門（貿易/買糧不因不知市集全卡死）；relay 傳播讓遠市集漸知（連 Slice B relay-discovery 精神）。
- **★market-info relay 真傳得到**（承 Slice B R① 教訓「別假設 relay」）：坐實市集資訊 relay 機制真存在/傳得到（order message 或新 market-info relay），否則市場發現只 proximity=可能經濟卡（同 B 的 relay premise 驗）。

## 驗收
- **TDD**：①創世-nearby 市集 known ②直接親見 outpost→known ③relay harvest order/outpost_built 訊息 origin_pos→known（濾 outpost_level>0，無 outpost 隊的 live pos 不 harvest）④`_nearest_market_outpost` 只回 known 中最近、未知市集不回 ⑤★**demolish（`outpost_level→0`，outpost:332）ONLY→清所有隊 team_market_known 對此 tile；★capture（owner 變）不清**（市集還在=known 位置仍有效，習得後穩定）⑥★**貿易 target==(-1,-1) 且 非-resident→TASK_IDLE**（只 roaming merchant；★resident 擺攤 (-1,-1) 保 TASK_TRADE 原地交易不關門=r3 不 regression）⑦harvest 無新 RNG（determinism）。
- **gate** PASS / **headless** 0 new / **determinism** 2 跑 byte-identical。
- **measure**：上述 economy 對照 + doom-delta + 冷啟動不死鎖 + market-info relay 坐實。

## ★invariants 訂正（我 owner）
「市集＝零豁免、必經 belief」段（已寫 Slice C 待修）→ 改「已修：market-discovery belief store + belief-gate；市集三源（創世/vision/relay）習得，`_nearest_market_outpost` 只掃 known」。

## out-of-scope
市集 GOODS/PRICES belief（賣什麼/多少錢）——order_buy/sell message 已傳播（殘缺市場知識湧現，invariants:356）。C 只管**市集位置發現**（貿易目標選擇）。1119 = 後（便宜）。

## 排序
倒數第二（中-大工，新 store 基建）。off main HEAD。★異質 R²（基建+economy 敏感+market-relay premise 驗，承 Slice B 教訓）。CLEAN→dispatch+measure。
