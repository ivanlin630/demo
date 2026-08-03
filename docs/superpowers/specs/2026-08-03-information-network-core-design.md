# 資訊網（核心）— 資訊當通例的全面網、有意收集/傳播進思考層（WHAT / vision）

status: LOCKED（2026-08-04：用戶裁 (a) whole 一次量 + R① CLEAN——P1–P5 坐實、「一 root 三症」文字性驗證（D1/D2 literally 同 team_known 結構同 co-location 閘）、decay multi-hop-ready → dispatch systems whole HOW）
owner: blueprint（WHAT）→ systems 做 HOW
date: 2026-08-03
scope: **核心**（可靠傳播 + 有意收集/求援決策）；**不含對抗式資訊戰**（造謠/反情報/販賣情報 = parked `2026-07-19-*` notes、下一層）。

## 動機
§5 執行塌陷 root（measure 坐實、三層）= **資訊 dead-end**：饑荒不傳到領主（領主坐擁 3940 糧、居民餓死、distribute=0）+ 商業買單不傳到賣方（order_placed 426 / fulfilled=0）。**但修法非特例補丁**（領主直掃=用戶否定）——**資訊該是通例、全面網**（用戶定）。

## ★核心原則（用戶定）
1. **資訊 = 通例非特例**：全面資訊網，不為饑荒/商業各開特例。**一個資訊模型**。
2. **兩層**：
   - **① 被動傳播 substrate**：消息經 carrier/co-location/relay 擴散，**帶延遲 + decay**。**無死角**（不存在「永遠傳不到」）。**戰爭迷霧 = 延遲/衰減**（遠/敵 = 舊/模糊）**、非硬擋、非特例**。
   - **② ★有意收集/傳播 = 思考層決策**（用戶核心）：
     - **求援**：村莊快餓死 → **決定求援**（派求援信使）。
     - **派信使/偵察**：遠方久沒訊息 → 領主 **決定派信使查**（資訊價值 vs 派人成本）。
     - **資訊價值秤**：值不值得投資去知道。
3. **★全跑人格、禁死常數**（照妖鏡死常數人格化用到資訊層）：求援與否/派不派/值不值得 = **人格秤 util**、**零死常數門檻**（傲撐/務實早求/多疑監控/野心疏忽——傾向從人格湧現）。**genuine 非 crank**（人格 MODULATE 真 value）。
4. **感知鐵律守**：資訊靠**物理載體**（信使/斥候/逃難者/商旅）走、有延遲；**非 god-view**。intra/cross-faction = 傳播**速度/保真度差**（同機制參數不同）、**非有無**。
   - **★結構常識補則（用戶三問定案 2026-08-04，解 bootstrap 死結）**：faction 成員天生知**自家勢力所有「固定據點」的位置**（= 組織成員常識，如員工知公司分部；新據點建成公告本就傳播 → 名冊自然更新）。**硬界**：①只**位置**（地址）、零 live state（求援**內容**仍靠信使抵達）②**移動中隊伍不含**（軍/商隊/半路領主 = 照 belief/信使）③**敵方據點不含**（要偵察）④**分裂 = 名冊凍成 belief 快照**帶走（之後對方新建/棄置不知道、會過時 → 想保準得派斥候）⑤**預設公告**；「秘密據點 = 首領選擇不公告」歸對抗資訊戰層（parked），**名冊實作留隱匿旗位**（一行前瞻、不加功能）。
5. **執行物理不變**：送糧/送貨照走 convoy、信使照走路，資訊不瞬移、糧不變出來。

## 併入 whole build（§5 commerce 需、用戶已定）
- **交易面 broaden（L2）**：**任兩同格、雙方願意 → 成交**（貨源任一方任何持有 公/私/團庫、非只屋主公庫；willingness gate、非 store-type）。**★只賣真剩餘**：持有 − keep-line，**keep-line 含戰略儲備**（求生 + 前瞻:戰前武器/荒前糧/計畫料）。tile→teams bounded 非 O(N²)。
- **饑荒-flee（診斷完、2026-08-03 收斂）**：★**非獨立子系統、同一 propagation dead-end root**——居民 relocate 找糧決策**會生成**（非人格 pin、非決策 pin）、但 `food_seek_target` 靠親聞 food 賣單（team_known 共位傳:79）→ settled 不共位 → **不知糧在哪 → not-applicable → 餓死**。**修傳播無死角即同修此症**（一 root 三症：distribute 敗 + relocate 敗 + commerce-info 敗）。piecemeal-vs-whole 鐵證。

## ★整系統優先（用戶定）
**整張核心資訊網 + 交易面 做完當一個 whole、一次量**——**不切片**（feedback_whole_system_first：健全系統才有價值模擬結果、別 piecemeal 打地鼠）。§5 饑荒/商業 unstall = whole 建好後量出的 outcome。

## 現況前提（★pending R① factcheck，systems HOW-lane survey）
- **P1** 被動傳播 dead-end：`message_system propagate_on_arrival:79` = **共位才傳** → settled 不共位 = 死角。
- **P2** decay 骨架已在：`:103` `strength×(1−HOP_DECAY)×time_factor` + <0.05 drop + 義氣/慎重 distort（= 延遲/衰減底子在、缺無死角拓撲）。
- **P3** 既有跨距 firsthand 點：`read_market_board:194`（賣方物理抵市集才讀）。
- **P4** 有意收集/傳播決策 **ABSENT**：無「求援」「派信使查」決策（現靠被動 received_buy_orders、dead-end）。
- **P5** 交易面窄：`interaction:731-813` 只 owner public_storage（同格 pairwise 部分存 :240、tile-bounded 非 O(N²)）。

> R① 判準：P1–P5 file:line + 詮釋成立否？premise_contradiction → halt。

## 交 systems 的 HOW（開放，whole）
- 無死角傳播拓撲（carrier/relay/看板擴，守延遲 decay）。
- 有意 info-決策（求援/派信使/資訊價值）接 DecisionEngine、**人格 modulate util**、無常數門檻。
- 交易面 broaden（同格 willing + keep-line 戰略）。
- 饑荒-flee（若診斷是 bug）。

## 量測（★一次、whole、emergent）
- **§5 商業 unstall**：`trade.deal / convoy.dispatch / order_fulfilled` 真 >0（多床、非單床 premature）。
- **饑荒解**：`distribute.dispatch / food_delivered` 真 >0（領主經**傳到的 belief** 賑濟、非直掃）。
- **資訊決策湧現 + 人格分化**：求援/派信使 fire、**不同人格不同傾向**（傲少求、關切多查）——非齊一常數。
- **感知鐵律不破**：延遲/decay 在（遠/敵 stale）、無 god-view；determinism byte-identical；economy 不爆（keep-line 不空掏）。
- **沒湧現/沒解 = 調人格 util/傳播拓撲，非 script、非 crank、非切片補丁。**

## 血脈
- 溯源：`2026-08-03 §5 root 三層`（資訊 dead-end）；用戶 reframe（資訊通例 + 有意收集傳播進思考層 + 人格非常數 + 整系統一次量）。
- 接 parked `2026-07-19 資訊戰四動詞 / long-range-planning`（對抗戰 = 下一層）。
- 地基 KEEP（勞力池/de-patch/B/甲/後勤）。
