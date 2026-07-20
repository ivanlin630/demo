# spec：god-view Slice C — 市場 belief-gate + market-discovery belief store

> 層級：L1（新 belief store 基建 + 貿易目標選擇改，economy measure 敏感）。off main HEAD。god-view 殲滅 arc 倒數第二（A/F/E/D/B 已 merged，剩 C+1119）。★異質 R²（新基建+economy 行為敏感+難逆）。
> 來源：god-view audit Slice C。blueprint WHAT 裁（2026-07-19-godview-rulings-B-C）：**市場零豁免、必經 belief**（否決 invariants 舊「公開地標豁免」）；市場資訊永遠傳播（憑聽過/belief），冷啟動憑「聽過附近有市集」。

## god-view 後門（市場全圖掃）
`_nearest_market_outpost`（`faction_ai_system.gd:2112`，★行號驗過非 audit stale 2065）：**全掃 `state.world.tiles`** 找 outpost（level>0 非自家）選最近 = **god-view**（不論隊知不知道該市集，全圖瞬知）。汙染 economy 診斷（貿易目標憑全知非傳播）。

## blueprint WHAT：市場零豁免、憑 belief（聽過）
市集位置**永遠靠傳播/親見習得**（非全圖掃）。位置固定→習得後穩定，但**取得永遠靠傳播**（名聲高傳播率自然廣傳）。

## 修（兩部，鏡射 team-discovery 三源）
### ① 新 market-discovery belief store（基建）
`WorldState` 加 `team_market_known: Dictionary`（`team_id → Array[tile_id]` 已知市集 outpost tile）。**三發現源**（鏡射 team_discovered vision+relay+創世）：
- **創世**：隊創世時知**附近**市集（proximity≤`CREATION_KNOW_RADIUS`，同 Slice B 本地知識）——冷啟動出門憑「聽過附近有市集」。
- **直接親見**：隊在/近 outpost tile（vision 半徑內）→ 加入 known（同 vision team-discovery）。
- **relay 聽說**：市集資訊經 message/relay 傳到→加入 known（**復用/擴 order_buy/sell message 或 market-info relay**；名聲高市集傳播廣）。
- ★**store 隨市集消失清**（outpost 拆/易主→known 條目清，避懸空；同 team_discovered death-erase 精神）。

### ② `_nearest_market_outpost` belief-gate
`:2112` 改：**只掃 `state.team_market_known[team_id]`**（已知市集），非全 tiles。無已知市集→回 (-1,-1)（該隊沒聽過任何市集→不能盲貿易，靠發現）。

## ★measure（economy 行為敏感）
市場全知→belief-gate = 貿易目標從「全圖最近」變「已知中最近」→ 動貿易/economy 行為。**非盲改**：
- **before/after doom-delta**（seed1337/42/4201）+ **economy 對照**：貿易觸發率/成交量/coin 流通、市集發現曲線（隊逐漸知市集經 proximity/vision/relay）。
- **★冷啟動不死鎖**：開局隊憑創世-nearby 市集出得了門（貿易/買糧不因不知市集全卡死）；relay 傳播讓遠市集漸知（連 Slice B relay-discovery 精神）。
- **★market-info relay 真傳得到**（承 Slice B R① 教訓「別假設 relay」）：坐實市集資訊 relay 機制真存在/傳得到（order message 或新 market-info relay），否則市場發現只 proximity=可能經濟卡（同 B 的 relay premise 驗）。

## 驗收
- **TDD**：①創世-nearby 市集 known ②直接親見 outpost→known ③relay 市集→known ④`_nearest_market_outpost` 只回 known 中最近、未知市集不回 ⑤市集消失→known 清 ⑥無已知市集→(-1,-1)不盲貿易。
- **gate** PASS / **headless** 0 new / **determinism** 2 跑 byte-identical。
- **measure**：上述 economy 對照 + doom-delta + 冷啟動不死鎖 + market-info relay 坐實。

## ★invariants 訂正（我 owner）
「市集＝零豁免、必經 belief」段（已寫 Slice C 待修）→ 改「已修：market-discovery belief store + belief-gate；市集三源（創世/vision/relay）習得，`_nearest_market_outpost` 只掃 known」。

## out-of-scope
市集 GOODS/PRICES belief（賣什麼/多少錢）——order_buy/sell message 已傳播（殘缺市場知識湧現，invariants:356）。C 只管**市集位置發現**（貿易目標選擇）。1119 = 後（便宜）。

## 排序
倒數第二（中-大工，新 store 基建）。off main HEAD。★異質 R²（基建+economy 敏感+market-relay premise 驗，承 Slice B 教訓）。CLEAN→dispatch+measure。
