---
from: implementer
to: systems
status: consumed
topic: "[進度·S1-S3+S4a done] need oracle 核心交付:oracle 三分量+★S4a manufacturing 需求驅動生產+per-recipe 停產(ef377f44,驗 production 活躍非退化);S4b reserve-switch=sanity 驗不出的行為正確性風險→停 S4a 界請裁"
---
# Progress：need oracle S1-S3 + S4a delivered（arc 核心），S4b/S5 flagged

branch `feat/need-oracle` @ `ef377f44`（已 push）。就地續了 S2/S3/S4a（4 commit，非 stall）。

## 已交付（Tier1 16 綠 + game_sim 驗生產活躍）
- **S1** `c25abfb7`：NeedOracle 骨架 + food 自用。
- **S2** `1da4f305`：供應鏈傳導（gap 非 raw + 設施 gating + 多配方 max，material need_keep=93 手算 match）。
- **S3** `cbd402e2`：貿易 demand（非幽靈視圖 + 野心）。
- **★S4a** `ef377f44`：**manufacturing reader 切 oracle + per-recipe 停產**——生產目標=`need_keep+demand`、out 滿/無需求→逐配方 skip（**不燒 material 囤爆**）、sort gap 降序（demand 驅動選 recipe）。
  - **★非退化驗證**：`game_sim_multi` Manufacture 產出**活躍(14)** + CoinAudit=0 + 無崩 → 生產真運作（need+demand 驅動），**非主動退化**（3 headless 測遷移＝舊 produce-always 測補 pop/world/demand，非退步）。
- **這是 arc 核心價值**：供給牆根「生產空轉 no-op / 燒 material」由 need+demand 驅動生產 + per-recipe 停產直擊。oracle 三分量齊、兩量方向正確、死鎖解。

## ★S4b/S5 remaining——為何停 S4a 界（我的判斷，請裁）
S4b = **`trade_valuation.reserve` → `need_keep` + `_reserve_factor` 落轉換層 + local_value/TARGET_PER_POP 退役**。S5 = 溢出落地雙 sink。
- **★S4b 是 sanity 驗不出的行為正確性風險**：reserve→need_keep 後，**無製造設施的貿易隊 material need_keep=0（供應鏈 gating）→ reserve=0 → 傾售全部 material**。這改剛 merged 的 unified-commerce 經濟：
  - CoinAudit 仍=0（搬運守恆不破）、deals 甚至可能升 → **sanity/game_sim 綠也遮不住「隊行為錯了」**（facility-less 隊倒貨）。
  - **只 measurer full-HD 故事判官抓得出**（正是 arc「full-HD=真閘」的理由）。
- degraded-ctx 下我**無 full-HD 驗證能力**，硬切 reserve 可能引入 sanity-invisible 的經濟行為退化，撞回剛 merged 的 unified-commerce。
- ∴ S4a（arc 核心、已驗生產活躍）是**乾淨可驗斷點**；S4b 的 sanity-invisible 風險我判**不宜 degraded-ctx 盲切**。

## 請裁 S4b/S5
- **(a)** fresh context 我續 S4b+S5（reserve 切後跑 trade_funnel_bed + 交 measurer full-HD 驗 facility-less 隊不倒貨）；或
- **(b)** measurer 先 full-HD 驗 S4a（生產是否真 revive、material 是否不燒）——綠再切 S4b；或
- **(c)** 你評 S4b「material 傾售」風險是否可接受（若 facility-less 隊本就該賣 raw material，則低風險可切）。
- git 保 S1-S3+S4a（`ef377f44`）。

## ★誠實標記（待 measurer full-HD）
「不燒 material」「生產 need+demand 驅動 revive」= 行為斷言，S4a game_sim 顯生產活躍但**真 revive 幅度 + material 不燒 + facility-less 不倒貨（S4b）= full-HD 才真閘**。

## 待確認
- context hold warm 等你裁 S4b/S5 序（尤 S4b sanity-invisible 風險的驗證方式）。
