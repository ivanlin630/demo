---
from: systems
to: reviewer
status: consumed
slice: flee-to-safety（#5 一張 spec）
tier: R2
topic: ★藍圖裁「逃＝逃往安全」+無安全處則退化戒備 + 漏套真位在【選 FLEE 那一步】;★★而我先盤點了三個方向源:①己方據點 ②同 faction 成員位置【兩個現成】③【記憶安全處根本不存在】⇒ 本刀不建,明寫;★★★退化目標 `TASK_PREPARE="備戰"` 是既有 option 不必新建;★要你重點打:(a)applicability 擋在選步會不會把恐懼吞掉 (b)「逃往安全」與既有 _flee_away_tile 反向邏輯的關係
---

# 背景（藍圖已裁，不用審）
**「逃」語意升級＝【逃往安全】非只逃離威脅**；方向源＝**belief 己方據點／盟友／記憶安全處**（self-knowledge，零 god-view）。
**威脅 unknown 且無 believed 安全處 ⇒ 退化【原地戒備／聚攏】**（恐懼轉行為，不消失）。
**漏套真位 ＝【選 FLEE 那一步】**（不是下游填值那兩行——那兩行在 `try_set` 之後，改不了行為）。

# ★①方向源盤點（★我做的前置，直接改變本刀成本）
```
①★己方據點：`faction_ai_system.gd:6075 _find_own_outpost` —— ★★現成，且是 self-knowledge（零 god-view）
②★同 faction 成員位置：`faction_data.gd:33 known_member_states`
   —— ★★現成，且 `belief_system.gd:129` 已經用它做同-faction 位置通道（含 staleness gate）
③★★★【記憶安全處】—— ★掃 `scripts/data/*.gd`：**沒有這個欄位**（`tile_data.gd:17` 的 L0 shelter 是 tile 屬性，不是隊的記憶）
   ⇒ ★★**本刀【不建】它** —— 建它＝新增一整套「安全記憶怎麼寫入／怎麼過期」的機制
   ⇒ ★★★而【前兩個就夠 (c) 成立】：本刀用 ①②，③留給未來（若證明不夠）
```
★**退化目標**：`team_data.gd:20 TASK_PREPARE = "備戰"`，且 `options.gd:397/503` 已是既有 option ⇒ **不必新建 task。**

# ★★②形狀
```
★選步（applicability）：FLEE 的 applicable 條件加上【存在一個 believed 目的地】
   —— ①自家 outpost 的 believed 位置 或 ②同 faction 成員的 believed 位置
   ⇒ ★★沒有 ⇒ FLEE【不 applicable】⇒ 引擎自然去 rank 別的（★而「備戰」就在候選裡）
★★移動：`movement_system.gd:84 _flee_away_tile(state, team, flee_from_pos)`（★現況＝算反向 away-tile）
   ⇒ 改成【朝 believed 安全處】走；★★★而 away-tile 那條在【有威脅座標但無安全處】時仍可能有用 —— 見要你打的(b)
★backstop（`movement_system.gd:88`）：★保留 —— 它現在是【冗餘】而不是【主要收尾】
```

# ★★★③要你重點打的兩件
```
(a)★藍圖說「恐懼必有出口，禁被 guard 吞掉」。★★而我把 FLEE 擋在 applicability
   ⇒ ★★★這算不算「吞掉」？我的理由：擋掉的是【一個做不到的動作】，
      而恐懼會在同一輪 rank 裡走到「備戰」——★但這依賴「備戰的 applicable 條件會成立」，
      ★★而我【沒有查】備戰在那個情境下 applicable 不 applicable ⇒ ★★★請你查這一格
      （若備戰也不 applicable，那恐懼【真的】會被吞掉，spec 就得改）
(b)★「逃往安全」與既有 `_flee_away_tile`（反向逃離）的關係：
   ★★兩者是【取代】還是【並存】？——★★★有安全處走安全處、沒有安全處但有威脅座標走反向？
   而若是並存，那「無安全處」就【不必】退化到備戰（還能反向逃）⇒ 這會改變 spec 的骨架
   ⇒ ★我傾向並存，但這是行為設計的邊界，請你判我有沒有越到 WHAT
```

# ★★★⑤R② 回覆後補上的兩件（reviewer 查實，systems 複驗）

## (a) 恐懼不會被吞掉，★而中間有一個【既有】的窄 band
```
options.gd:400-401 "備戰" applicable: threat_react >= threat_threshold   ⇒ ★不需 destination
   ⇒ ★★【真的恐懼（過 threshold）】保證有出口，applicability 擋 FLEE 不會吞掉它
★★★而 reviewer 撈到：options.gd:76-81 "逃跑" applicable 【不檢查 threshold】，只檢查 threat_pos != -1
   ⇒ ★兩道閘問的是【不同種類的問題】：FLEE 問「有沒有座標(可行性)」、備戰問「怕不怕(強度)」
   ⇒ ★★band ＝ `threat_pos != -1` 但 `threat_react < threshold`：加 destination 要求後可能兩者皆不 applicable
★systems 判：★★benign（低於反應門檻＝沒怕到需要出口，隊會去 rank 正常選項）
   ⇒ ★★★而「判它 benign」要有數字撐 ⇒ **驗收加一格：落進該 band 幾次**
   ⇒ 已另立 known_issues 條目（★這 band 是既有結構落差，不是本刀新造）
```

## (b) 並存 —— 照 reviewer 的三層優先序寫死
```
①目的地可解        → ★朝目的地（逃往安全）
②目的地過期/無，但威脅座標仍在 → ★★away-tile（既有 _flee_away_tile 保留）
③兩者皆無          → ★★★backstop release（保留為冗餘）
⇒ ★reviewer 指出這【不是越界 WHAT，是 HOW 層的 staleness race 防禦】——我採納
   （★★belief 會過期，而「目的地剛才還在、這一 tick 過期了」必須有下一層接住）
```

# ④驗收
```
①★`fp` 會變（行為修正）⇒ 差在哪要說得出來
②★★沿用 #5 的量測：flee 機會母體／續卡事件／續卡隊數去重 —— ★★★修後【續卡隊數應趨近 0】，
   而【機會母體不該塌】（若 FLEE 隊數也掉到 0，那是把恐懼擋掉了，不是修好了）
③★退化路要有計數：「因無安全處而改派備戰」幾次 —— 恆 0 表示退化路沒被走到，要查
④★★backstop release 次數應【下降】
⑤★★★band 計數：`threat_pos!=-1 且 threat_react<threshold 且無目的地` 落進幾次 —— ★恆 0 代表 band 不存在；★★非 0 而數字大 ⇒ 我判的 benign 要重判—— 它從主要收尾降級成冗餘
```
