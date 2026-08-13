# 生存經濟基座 — 接入+產出 arc（WHAT / vision）

status: LOCKED-pending-R²（2026-08-13 用戶核可分數改法+紮營/進駐區分;B6 PENDING 用戶裁）
owner: blueprint（WHAT）→ R² → systems HOW
溯源：③ 長期故事驗證全鏈收口（全實測、帳關）：世界富（池 -0.04%/倉 +2.5%）但 91% 流浪接不到 → 四段鏈：①紮營分數結構永輸（26 戰全敗、camp_drive flat 1.0×人格 0.5 vs 求生 1.0）②進駐從未派出+建設 12/15 noop（手不聽腦）③安家後採糧硬零（labor cache 3 天 lag）+ material 排擠 food（need 不隨飢餓升級）+ 小團 pool 地板④→零累積→市場空→餓死碎裂→零興衰。效能（faction_ai 93.7%）= **獨立後續 arc**（純優化、byte-identical 驗證、排在 12/24 月驗收跑之前），不入本 arc。

## §1 命門（用戶定、寫死）
- **禁 crank**：不發明新分數、不調常數到贏。紮營/進駐價值 = 接**既有邊際經濟計算層**（移民 R1/投資 R2 同款、用戶已核）——「住哪裡值多少」= 一個模型四動詞（移民/投資/紮營/進駐）、零特例零新旋鈕。
- 人格 MODULATE 非 GATE;survival-boost order-preserving 結構不動。

## §2 A 接入層
### A1 紮營價值 = 邊際經濟真帳（分數修法、用戶核可）
紮營價值 = （地的期望食物流[地形 regen 估] − 現有收入[覓食餬口地板]）× 緊迫度（存糧跑道）。
★bounded 驗證（防 crank 判準、machine-demonstrate）：有家有倉→邊際≈0 不紮;富流浪→緊迫低不紮;瀕餓+肥沃平原→高值紮;**瀕餓+只有山地→紮了沒救→不紮**（灌分做不到這條）。
### A2 進駐（settle）派出鏈修通
TASK_SETTLE 從未 dispatch = 執行斷。與紮營同秤：進駐拿現成基礎（倉/等級/設施）、代價 = 可達性+村餘裕（共池邊際遞減、邊際經濟層本就會算）。**不寫死偏好**：有村投村、無村開荒 = 湧現。
### A3 建設執行 noop 修
決策贏 15 次、12 次 try_set_noop（tick10 bootstrap 外全斷）= 手不聽腦第 4 型。pin noop 點修通。

## §3 B 產出層
### B4 settle 時 invalidate labor cache（明確 bug、小修）
labor_alloc 3 天 cadence cache、新居民硬零 57-80% 採集 tick。settle/紮營成功 → 立即 ensure_fresh。
### B5 food need 隨飢餓升級（need-oracle gap、連統一矩陣 need-oracle arc）
現況 food need 恆不隨 famine_days 升 → material 排擠 food（team87 礦 0.083 vs 糧 0.008）= 餓著採礦。修：need 公式接飢餓狀態（餓越久 food need 越高 → 勞力自然回糧）。genuine：從真實狀態算、非常數;bounded：吃飽的村照常採礦。
### B6 小團 pool 地板（PENDING 用戶裁）
pop1-3 勞力池被 maxf(1.0) 地板夾死結構性採不動。裁項：「小團本來就弱」（genuine、連有大有小）vs「1 人在平原該自足」（生存底線）。**未裁不動**。

## §4 量測（湧現、硬數據、本 session 教訓全套用）
- 帳關才報;直讀 tap 禁回推;先讀既有 log。
- A1/A2:紮營/進駐真 fire 且 bounded 四象限驗證;佔據率 8.6%→顯著升;**分化**（有村投村/無村開荒/有家不動）。
- A3:建設 order→execution 完成率 12/15 noop→顯著升。
- B4:新居民首 3 天採糧非硬零。B5:飢餓村勞力回糧、吃飽村照舊（bounded）。
- 端到端:居民 food-security 脫離 0 天;團隨身層不再 -72.9%;（觀察）碎裂/合併比、starve 曲線改善。
- determinism/regression/constitution 綠;fp 比對標 intended-change。

## §5 後續（非本 arc）
- **效能 arc**（緊接）:rank_scored 快取/剪枝、byte-identical 驗證、於 12/24 月驗收跑前完成。
- 12/24 月長局驗收跑（兩 arc 後）。
- vitals spec（DRAFT 待用戶過目）→ systems invariant 閘。
