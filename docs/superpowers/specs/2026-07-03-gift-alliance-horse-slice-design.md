# 誘因結盟 + 馬經濟最小 slice — Design（兩小軌合一份,分 plan 平行 spawn）

> 藍圖裁定 `dual-engine-horses` 裁2/裁3。

# A. 誘因結盟（裁2）

## 根據
三軌 envoy accept=0/8 全域——`_calc_diplomacy_score>0.55` 白嘴提案實質死路。裁:**提案帶誘因（糧禮先行）,掏誘因=戰略選擇**（越急掏越多）。

## 修法
1. **提案 payload 擴誘因欄**:`pending_proposal` 加 `gift: {res: amount}`（糧先行;結構通用=聯姻槽未來直插,藍圖明示順鋪）。
2. **掏多少=戰略選擇**（連續,零新判斷器）:發起方按 急迫（野心/建國 intent 強度）×付得起（effective_food 盈餘）決 gift 量——`GIFT_FRACTION`（TEST VALUE,如盈餘的 10-30% 隨野心滑）。窮狼掏不出=白嘴照舊難。
3. **送達即轉移**（守恆）:信使帶禮=資源轉移走 ResourceBank（發起扣、送達目標收;信使死=禮沉沒——亂世押鏢風險,G3 攔截未來紅利）。
4. **diplomacy score 讀禮值一項**:`_calc_diplomacy_score` 加 gift term（禮值/目標需求 縮放——目標缺糧時糧禮權重高=雪中送炭,連續信號）。門檻 0.55 同步微校（TEST VALUE,seeded 校）。
5. reject 不退禮（收禮拒盟=口碑代價?——**不做**,先最小:禮沉沒,拒者白得=亂世;口碑鉤未來）。

## 驗收
- seeded:帶誘因提案成功率 >0（envoy.accept 脫 0）;白嘴（無盈餘掏不出）仍難;結盟總量不爆（稀有仍稀有,found faction 合理量級）。
- 守恆:CoinAudit/糧流 delta 乾淨（禮=轉移非憑空）。
- 回歸全綠。

## 檔案 scope（勿碰 npc_combat/outpost/world_generator——他軌）
`team_data.gd`（payload 欄）、`faction_ai_system.gd`（僅 `_dispatch_envoy` gift 決策）、`interaction_system.gd`（送達轉移）、`diplomatic_ai_system.gd`（score gift term+門檻）、`headless_test.gd`。

# B. 馬經濟最小 slice（裁3,用戶裁提前）

## 根據
馬消費端全建好（movement 騎乘/mounts 資源/速度加成）,**只缺來源**（世界 mounts=0 全 dormant）。醒來的:信使 3×（envoy timeout 直解）、機動、馬貿易 stakes、E-2 騎兵地基。

## 修法（HOW 系統選:tile 資源特化+stable 產出,不加新地形）
1. **產馬區=tile 資源特化**:world_gen 對部分 plains tile 撒 `resource_cap["mounts"]`（產馬區,TEST VALUE 密度/量——集中成「產馬帶」非均撒=戰略不對稱地基,藍圖「中原缺馬 vs 北方產馬」）。不加地形 enum（3 地形夠,vision 已裁地理=未來項）。
3. **stable 轉化鏈**:stable 設施（已在=半地基）在有 mounts resource_cap 的 tile 上 tick 產 mounts 入 owner 資源/糧倉 pattern（複用 harvest/mint 產出 pattern,零新系統）。
4. **馬入交易網**:mounts 已是資源（weight/carry 全通）——補 `local_value`（馬貴=高值)+訂單品類（shortage_buy 含 mounts?最小:賣盤自動含=既有 order 泛用鏈,驗一單流通即可）。
5. **禁運/馬政=未來**（外交武器 hook,不做）。

## 驗收
- seeded/longwindow:世界 mounts>0（產馬區產出）;至少一隊經貿易/收成獲得馬;信使獲馬後 3× 速（envoy timeout 降,對照 default 5/6 timeout）;E-2 hook 不動。
- 回歸全綠;coin_eq 乾淨（馬=資源流轉非憑空——resource_cap 產出走既有 regen/harvest 語意）。

## 檔案 scope（勿碰 diplomatic/npc_combat——他軌）
`world_generator.gd`（產馬區撒點）、`outpost_system.gd`（僅 stable tick 函數——與佔村軌同檔**不同函數**,ort 慣例）、`config/*.json`（如需 local_value/order 配置）、`headless_test.gd`。
