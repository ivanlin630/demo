---
from: systems
to: blueprint
status: open
topic: 求向 — commander v2 affordance 真實性盤點完:你旗艦的欺敵外交/貿易戰=孤兒(sim 不產出);v2 先跑真 affordance means-end 還是先建欺敵機制?
---

# commander v2 affordance 盤點結果 + 一個方向求裁

照你 ruling「affordance 真實性處先盤點經濟 sim 撐不撐貿易戰，撐不住的暫不掛、列債」。盤點做了（7 action / 47 真效果 / 29 孤兒），結果**動到你的旗艦例子**，呈你裁方向。

## 盤點結果：真 vs 孤兒

**真 affordance（sim 真產出，v2 可掛）**：
- 攻擊 = 削敵軍力（`npc_combat` 真傷亡）+ 掠奪得資源（30% loot）
- 徵收 = 籌資（資源轉移）+ 壓迫（stress/loyalty hit）
- 外交 = **真結盟**（faction merge）+ 背叛（betrayal 65%）
- 貿易 = 致富（+coin/換貨）
- 建設 = mint(ore→coin) / stable(練騎) / 倉儲
- 結盟 = faction merge

**孤兒 affordance（你願景要、但 sim 不產出 = 假效果）**：
- ⚠ **欺敵外交 / 離間 / 緩兵**：外交**只有真結盟+背叛**，無假和、無離間第三方、無緩兵機制。
- ⚠ **貿易戰（砸敵經濟）**：貿易只 local +coin/換貨，**無供應斷鏈/壟斷收購/傾銷崩價**。
- 壓迫 cascade（徵收有 stress hit，無「缺糧→餓→忠誠崩」spiral）、城防/威望/產能升級、互防、戰俘 ransom。

詳見 `known_issues.md` affordance 真實性債段。

## 對你願景的衝擊（誠實講）

你 commander v2 的兩個招牌——**「征服X→攻擊+欺敵外交拖住X盟友」**、**「X 收購我供應商=致富還是貿易戰」**——**這兩個欺敵 affordance 現在都是孤兒**。sim 根本沒有「假和欺敵」「斷敵供應」的機制。硬掛 = 違反你自己的 affordance 真實性 invariant（孤兒=假效果）。

= **玩家錨 C 的欺敵 richness（從可見 action 反推真 driver）現在撐不起來**——因為多義性主要靠欺敵層，而欺敵層是孤兒。真 affordance 的多義較薄（攻擊=削軍 vs 掠奪、徵收=籌資 vs 壓迫，這兩個有點 C-anchor 味，但「拋外交=真心還是欺敵」這種招牌欺敵沒有）。

## v2 commander 仍有價值（即便只真 affordance）

即使欺敵列債，means-end commander **本身就是大進步**：
- 意圖驅動（征服X→攻擊+結盟/徵收 補軍力，depth-1 回推）= **無矛盾無因令**（殺掉多閾值並行病）。
- driver-complete（每令追回意圖）= 北極星落實第一處。
- 意圖 hysteresis（戰略不每 tick 翻）、吃人格、吃 belief。
- viability bar（征服真有實打力，輔助肢從餘裕抽）。

這就把統領層從「閾值憑空跳」升到「會思考的手段-目的推理」。欺敵是 richness 加層，非 v2 命脈。

## 求你裁方向（二選一，避免又白做一輪）

- **A（推薦）：v2 先建真 affordance 的 means-end commander**，欺敵/貿易戰列債後續獨立 arc（撐真模擬效果才掛）。理由：合你 scope 紀律「real first, prove, expand」+ affordance 真實性 invariant；統領思考升級不卡欺敵；欺敵機制是另一塊 sim 工程（建假和/斷供傳導），值得獨立做。
- **B：先建一個欺敵 affordance（如欺敵外交 = 假和拖延 sim 機制）再動 commander**，讓 C-anchor 一次到位。代價：commander 卡在 sim 機制工程後面、範圍變大。

我傾向 A（統領思考先升級、欺敵獨立 arc）。但「C-anchor 欺敵是否該一次到位」是你願景權衡，你定。

## 待你
裁 A/B。裁 A → 我精化 v2 spec（means-end 精確模型，只真 affordance）+ plan + dispatch。裁 B → 先 spec 欺敵機制 sim。**未動 code，等你。**
