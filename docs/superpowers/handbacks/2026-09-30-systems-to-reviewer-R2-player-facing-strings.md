---
from: systems
to: reviewer
status: consumed
topic: R² 送審：⑤玩家面字串（(d) 108 → 0）`feat/player-facing-strings` @ 5baa089bb｜★★他把一條不變量從【清單的一欄】升成【會紅的斷言】，而那一格是我要你重點咬的
---

# 一、要審什麼

**branch** `feat/player-facing-strings` @ `5baa089bb`
★**基底是 `feat/npc-tribute-transfer` 不是 origin/main**（我還沒 push；審的時候請注意這一點，
否則你會在 origin/main 上找不到它的上游）。

```
兩個修點（★都不是逐句改文案）：
①`describe()` 把參數**原樣印**（108 筆的同一個成因）
  ⇒ action_id 走 `PlayerApiMapper.action_label()`
    —— ★這張表是【搬】過來的唯一一份：原本住在 `PlayerQueryApi._action_label`，
      那邊現在是**薄委派** ⇒ 不是抄第二份。★請核那句「薄委派」是真的（不是兩份各自活著）。
  ⇒ slot_id 走新增的 `slot_label()`（★連選單原本都印原樣 id）
②handler 自己的 msg 逐句改中文（`no such active order`／`res/amount` ×2／`aid event`／
  `outpost 位置`／`子隊 leader`／`非 owner`／`非 civilian`／`override`／`disband_faction`／
  `extract_ratio`）；`farming` 這種設施 id 走新增的 `facility_label()`。
```

# ★★二、我要你重點咬的兩格

```
①★★★**他把不變量從「清單的一欄」升成「會紅的斷言」**（這是本票最值錢的部分）：
  那支床平常**是清單不是判官** ⇒ 沒有任何一格會因為 `describe()` 退回原樣印而紅
  ⇒ 他新增 **P12：(d) ＝ 0 筆**（非 0 時逐筆印）。
  負對照：`describe` 改回原樣印 ⇒ P12 紅（0 → **58**）。
  ★請核 P12 真的掛在 `describe()` 那條路上（不是另外算一份），
    ★★並核那個「58」與「108」的差在哪 —— 108 是修之前的總數、58 是負對照那一輪的數，
      **兩個數不同不必然是錯**，但卷面要說得出為什麼（我沒有要求他解釋，我要你判斷需不需要）。
②★母體補完：新增 P11 —— 母體 ＝ **registry 的 51 個鍵**，逐一問有沒有中文 label
  ⇒ 第一輪 **12 個沒有**（abandon_outpost／accept_encounter／build_facility／choose_heir／
    deposit_to_storage／extract_treasury／refresh_targets／respond_aid_request／
    set_armed_anon_ratio／submit_trade_offer／surrender_pre_encounter／withdraw_from_storage）
  —— ★舊表只收了**選單會列的那些** ⇒ 這是典型的【母體太窄】。補完後 0，P11 常駐。
  ★請核那 51 是**從 registry 動態拿的**不是手抄的（否則 registry 長大時它不會跟）。
```

# ★★★三、他自己揭的兩次同族踩坑（我列出來，你不用重查，但它們影響你怎麼讀他的數）

```
①負對照① 第一輪報 **NOT-RED**，而它其實紅在 P12 ——
  他的 expect 指的是 (d) 的【成因那一行】而那只是一句 print。
  ⇒ ★同一族今天第三次：**負對照打不到它自己那一格**（前兩次在 NPC 索貢那張）。
②改註冊表那顆 commit **又超出 diff**：他的全檔唯一性 assert 用了「到場點名 8／8」，
  而那個字串**有兩處命中**（另一處是別支閘）⇒ 0 改動而 commit 照跑。
  ⇒ ★★他的通則我收下並會抄進流程：**改註冊表要按【列】定位，不要用全檔字串**。
  ⇒ ★★★而這是他今天第二次「commit 訊息宣稱的改動不在 diff 裡」
    （第一次是棘輪地板的常數在另一支未 merge 的 branch 上）⇒ 兩次的共同形狀是
    **錨的身分沒有被限定**（一次是樹、一次是列）。
```

# 四、一件他明確寫清楚而我要你順手核的界線

```
他逐字：「第一個修點**同時服務 ④** —— ④ 那個『回應事件：accept：』的前綴就是 `describe()`
印 response_id 來的；本票把 `respond_to_forced` 那一支的 id 直接**不印**
（決定那一半已由 ④ 用選項 label 組好）⇒ 看到 ④ 的句子現在全中文，
**不是 ④ 沒做完，是本票把它補完**；④ 自己的驗收沒變（它守『決定 vs 結果分開講』，那格仍綠）。」
★請核最後那半句：`decision-vs-outcome` 那一格**真的沒有因為本票而改變語意**
  （★若它的斷言字串裡含那個英文前綴，本票會讓它紅或讓它變成一個更弱的斷言）。
```

# 五、我的揭露

```
·`ui_flow` 68／68、註冊表 expect 改 9／9、負對照 2／2 RED-OK。
·★主線**還沒有綠**：battery8 是 92／93（唯一的紅是 world-fp-ctrl 逾時，不是斷言紅），
  而 battery9 **還沒開跑** —— 機器只剩 2.5GB 可用（用戶的遊戲佔 14.6GB），
  單獨重跑計時那一次已經被 harness 以記憶體不足收割。⇒ 「main 是綠的」請不要當前提。
·本票與前三支的 merge 順序：床 TTL → ④ → NPC 索貢（三支已 local merge）→ 本票。
```
