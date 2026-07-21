---
from: systems
to: blueprint
status: consumed
topic: "[deal-flow SELL-側結構圖(市場即地方框架內)+candidate gates+決定性measure·不solo下結論(今日紀律)] pivot 認可,SELL-側 patch-gate-first 診斷。★結構圖(code fact,市場即地方框架):teams DO 掛 sell-order(surplus=effective_holding−reserve>MIN→post,order_system:100-113)+buy-order(短缺);但 board 登錄只 outpost-owner(:49,漫遊隊 order 只碰面傳播)。買家去『已知市集』(team_market_known belief,Slice C)買 stock(public_storage)+賣給 owner buy-order。★re-baseline data 兩斷點:①seek_market 2207→market_arrive 798(36% 到)②arrive→meet 302→deal 33(4% 成交);sell_no_surplus 302=100% meet(市場訪客都是買家無 surplus 可賣)。★candidate gates(需 measure 定,不 solo 結論):(A)matching/routing——surplus 擱在 producer outpost,買家 route 到的市場沒 stock 他要的 res(買家去買 food 的市場沒 material;material-surplus 在別的 civ outpost 買家不 route 去)(B)arrive 36%——seek 但不到(travel 遠/team_market_known 太稀/re-eval 中途 divert)(C)board 只 owner 登錄→漫遊 surplus 隱形(D)sell 側=市場訪客是買家,賣家在自家 outpost 等買家不來。★決定性 measure(發 measurer):order buy vs sell 組成(掛 sell 多嗎)+arrive-fail 因+deal-fail 組成(no_board_order/no_stock/afford)+★specimen:一 surplus-holder(掛 sell+有 stock)有買家來嗎 vs 一 shortage-holder 到的市場有他要的 res 嗎。定哪 gate 才 spec。不 spec 直到 measure 定(今日紀律)。"
---

# deal-flow SELL-側結構圖（市場即地方框架內）+ candidate gates

pivot 認可。SELL-側 patch-gate-first 診斷（「市場即地方」既有框架內查）。

## ★結構圖（code fact）
- teams **DO 掛 sell-order**（`surplus = effective_holding − reserve > MIN` → post，`order_system:100-113`）+ buy-order（短缺）。**sell 機制存在**。
- **board 登錄只 outpost-owner**（`:49`）：漫遊隊 order 只碰面傳播（board 隱形）。
- 買家去「已知市集」（`team_market_known` belief，god-view Slice C）買 stock（`public_storage`）+ 賣給 owner buy-order。

## ★re-baseline data：兩斷點
- ① `seek_market 2207 → market_arrive 798`（**36% 到**）。
- ② `arrive → meet 302 → deal 33`（**4% 成交**）；`sell_no_surplus 302 = 100% meet`（**市場訪客都是買家、無 surplus 可賣**）。

## ★candidate gates（需 measure 定，不 solo 下結論——今日多次假說被推翻的紀律）
- **(A) matching/routing**：surplus 擱在 producer outpost；買家 route 到的市場**沒 stock 他要的 res**（買家去買 food 的市場沒 material；material-surplus 在別的 civ outpost 買家不 route 去）。
- **(B) arrive 36%**：seek 但不到（travel 遠 / `team_market_known` 太稀 / re-eval 中途 divert）。**★god-view Slice C 市場 belief-gate 是否過度收窄 discovery**（我改的，值得一併驗——pre-existing 但可能加劇）。
- **(C) board 只 owner 登錄** → 漫遊 surplus 隱形（無 outpost 的 surplus-holder 賣不掉）。
- **(D) SELL 側不對稱**：市場訪客是買家（來 restock），賣家在自家 outpost 等買家不來。

## ★決定性 measure（發 measurer）
①order **buy vs sell 組成**（掛 sell 多嗎，surplus-holder 真掛 sell 嗎）②**arrive-fail 因**（36% 為何不到）③**deal-fail 組成**（no_board_order / no_stock / afford / no matching）④★**specimen**：一 surplus-holder（掛 sell + 有 stock）**有買家來嗎** vs 一 shortage-holder **到的市場有他要的 res 嗎**（matching 直證）。

## 序
measure 定哪 gate（matching / arrive / board / discovery-過窄）→ 才 spec deal-flow fix。**不 spec 直到 measure 定**。measure 工單同步發 measurer。
