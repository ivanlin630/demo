# 絕境排序（iii）— 求援先於叛離的 genuine repricing（WHAT / vision）

status: LOCKED（2026-08-11：R①全靶citation+R² CLEAN、3必查項折入§2.5 → systems HOW/build）
owner: blueprint（WHAT）→ systems 做 HOW
date: 2026-08-11
溯源：① scale-economy → relief-death 6 層 gate-chain（whack-a-mole）→ 用戶拍 A iii-pivot（退源頭斷螺旋）。底查 `2026-08-11-...-iii-baseline-consolidated`（QA-verified）：threat 主導=genuine 不碰;herald 求援 mini-util=-0.004 razor-thin near-miss;defect_util=+0.13 過關但公式零 consequence-pricing。★行為變 slice（fp 預期分化 intended）。

## §1 命門（乙教訓雙向、寫死）
- **genuine 真值 modulate、非 crank 逼/刪 outcome**：兩 repricing 都是**校正 util 反映真實期望值**、非 boost 求援逼 fire、非刪絕境叛離。
- **順序湧現非腳本**：「求援先於叛離」從兩 util 的真值浮現、**不寫死 try-A-then-B 序列**。
- **不刪 genuine desperation-defection**：勢力從不救、真沒指望的隊照樣叛/逃;吃飽野心家奪權叛照樣 fire。**餓叛 ≠ 野心叛 從隊當下 state 湧現**、非兩條寫死規則。

## §2 兩靶 WHAT

### 靶1（最高 ROI、razor-thin）：herald 求援加 option-value / catastrophe-hedge 真值
- **現況**：mini-util = severity×pmult×INFO_RELIEF_EXPECT(2.4) − INFO_ANON_COST(0.8) = 只 price 直接紓困期望 − 成本、**漏「求援是對抗災難的便宜可逆 option」真 EV**。-0.004 差銅板厚。
- **WHAT**：求援 = **低成本 + 可逆（留勢力、只是問）+ 對抗 catastrophe（不問→叛→factionless→死）的 hedge**。其真期望值含 **option-value**（保住 faction+未來救援/保護的選項）——即使 P(help) 低，當 alternative 是 catastrophic-irreversible-death 時，這個便宜 hedge 的邊際值高。加 genuine hedge 項（scale with alternative 的災難程度 × 求援的便宜/可逆度）。
- **★人格 modulate 非死常數**：驕傲/自恃者仍可能不求援（重面子勝 hedge）、務實者早求——傾向從人格湧現。**非 boost 逼 fire**。

### 靶2（complementary）：defect 加 consequence-pricing 真值
- **現況**：`event_faction_defect:23` = distress×loyalty − stay、**零後果項**（叛離後果 factionless→relief 不可達→餓隊=死 未 factored）。
- **WHAT**：叛離 util 加 **consequence 真值**——餓著叛 = 失勢力救濟管道 = catastrophic（通往死）→ 該壓 util。**吃飽野心叛 = 情境不同、後果非死 → util 照高**。差異從 **starvation-state** 湧現、非寫死。
- **anti-crank**：加真後果、**非刪叛離**（絕望-abandoned 隊照叛）。

### 非靶：threat-dominance
底查證 genuine（Team2 面真雙威脅、排威脅優先=util 真贏）→ **不碰**。

## §2.5 ★HOW-binding 必查項（R² CLEAN、寫死非留 implementer）
- **②hedge 項 bounded 證明**：catastrophe-hedge 項**不得退化成「alternative 夠慘→unconditional 正」crank**——低 severity 時 hedge 項該**趨近零**（非 flat offset 讓 herald 變無視 cost-benefit 的 always-ask）;hedge scale with **catastrophe 程度 × 求援可逆/便宜度**兩者。HOW 須 machine/measure demonstrate bounded。否則 = 用「真值」包裝變相 boost。
- **③差異化走同一連續 state 變數**：餓叛≠野心叛的 consequence 項強度**必由現有連續 starvation-state 訊號驅動**（distress_pressure/food_days 類）、**禁新增 if-starving/if-not-starving 兩 branch**（隱性寫死非湧現）。HOW 明講 consequence 項 = 現有 starvation 訊號的連續函式。
- **④順序=硬量測 gate**：「求援先於叛離」是**未驗斷言**、build 完**必量測驗證真 emergent**（非文字宣稱）。硬性 gate 非 aspirational。

## §3 量測（湧現、fp intended）
- **靶1**：可救的餓隊 **求援先於叛離 fire**（Team2 求救成功活過 defect）;人格分化（驕傲晚求/務實早求）。
- **靶2**：餓叛 util 被後果壓、**餓叛率降**;野心叛（吃飽）util 不變照 fire = 餓叛≠野心叛 state-emergent。
- **共同**：順序湧現非腳本;絕望-abandoned 隊照叛/逃（genuine 保留）;F0 fp 預期變（intended）驗方向;determinism;無 regression;constitution 綠（無新硬閘、兩 repricing 是 util 項非 gate）。
- 服務 ③ 故事合理：隊不再莫名叛了悄悄餓死。
