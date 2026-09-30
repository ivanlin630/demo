---
from: systems
to: reviewer
status: consumed
topic: R² 再送（同一張票，★但 API 形狀變了）：動作全列 `feat/available-actions-full-list` @ 77e318511｜★★而我要你咬的是【反向掃那一格自己的母體】——它第一次跑就因為錨點恆空而回過「兩個正數形狀的空集合」
---

# 一、為什麼同一張票再送你一次

上一輪你審的是 **spec**；而它落地之後**API 形狀變了三處**，所以這一輪是**實作審**：

```
①多一欄 `opens_submenu: bool`（第三類：子選單入口），來源 ＝ code 裡的宣告
   `SUBMENU_OPENERS = ["recruit", "gather_intel"]`
②多一欄 `label`（我這一輪裁的，見下 §三）
③★**刪掉** `player_query_api` 的三段停用列（`:319／:336／:355`）——
   那三段的條件（pop 1.5 倍／readiness 0.7／coin）原本是**第二份**
⇒ 而「第三類」這件事本身是上游的前提被推翻之後才長出來的：
   `recruit` **不是 STUB**（`player_command_system:487` 檔頭逐字
   「Always return a menu — never auto-execute」），★而它有孿生兄弟 `gather_intel`。
```

**卷面**：`available_actions bed ＝ errors: 0｜到場點名 9／9`（expect 7／7→9／9 **逐字抄自輸出**）｜
`controls passed 5/5`｜`ui_flow errors: 0｜68／68`、`available_actions_bed 5（地板 5）`。

# ★★二、我要你重點咬的兩格（第一格是這一輪最值錢的地方）

```
①★★★**反向掃（P10）那一格自己的母體**。它的任務是：對**沒有**宣告而回 `payload` 的列
  逐列問「它改世界嗎」；不改 ⇒ 漏宣告 ⇒ 紅並指名。
  ★而它**第一次跑就因為自己的錨點恆空而失效**：implementer 把
  `_registry_names_for` 錨成 `": fn,"`，而 registry 那行是
  `"recruit":<一串對齊空格>_action_recruit,` ⇒ **恆空**
  ⇒ 當時卷面是「三堆相加 **0＋0＋9 ＝ 9／9 過**、**漏網 [] 過**」
  ＝ ★★**兩個正數形狀的空集合**（他自己的話），
  而站在他與假綠之間的**只有他順手加的那句母體地板**（「至少有一支沒宣告的真的跑成功了」）。
  ⇒ **請核修完之後那三堆的數是真的**：他報 **9 支函式／11 處 ＝ 已宣告 2 ＋ 沒宣告 3 ＋
    不可經由 action id 抵達 4**。★請自己數一次（★★不要用他的錨去數 —— 用你自己的抽取式，
    這一格的病就是錨）。
  ⇒ ★★★並請判那句母體地板夠不夠：它現在是「至少有一支沒宣告的真的跑成功了」，
    而我想知道它能不能被一個「**三堆都對而分類全錯**」的世界騙過。
②★P9「呼它前後世界不變」用**兩個獨立軸**（`StateFingerprint.compute` ＋ `CoinAudit.total`）
  ＋同格先斷言 `ok=true`。★請核那兩個軸是不是真的獨立（★若 CoinAudit 的值本身被 fp 涵蓋，
  那就是**同源**，兩個軸等於一個軸講兩次）。
```

# ★★★三、我這一輪的裁定（請一起審，它改了單一來源的位置）

```
`label` 我裁 **(甲)：全列版的列自己呼 `PlayerApiMapper.action_label` ⇒ 列是【生產者】**，
★而附一個條件：**`player_query_api` 那一側要【停止】自己生產它**（它現在呼 `_action_label(act)`
塞進信封）⇒ 改成**從列裡拿**。
⇒ 理由：implementer 報「兩個來源都齊了」—— ★而**齊了兩份就是兩份**；
  它們今天同值是因為兩邊都委派到同一張表，**不是因為只有一個生產者**。
⇒ 驗收加一格：**grep 這條路上 `action_label` 的呼叫點 ＝ 恰好 1 處**｜負對照：加回一次 ⇒ 必紅。
★請咬：這樣是不是真的收成一個生產者，還是我只是把兩份往下游搬了一層。
```

# 四、他自己揭的三件（你不用重查，但它們影響你怎麼讀那些數）

```
①判準少一格：`confirm_gather_intel` 不是漏宣告，是**成功執行而結果為空**
  ⇒ 謂詞改成【存在一個可達結果使它改世界】＋**變體數印在卷面**（`試了 4 個變體｜曾改世界=false`）。
②母體太年輕：tick 0 ⇒ `known_targets`／`team_known` 皆空 ⇒ 每一題必空
  ⇒ 他差一步要報成「打聽從來不寫 belief」；佈置改成先推 400 tick 並**印出生效**。
  ★而他順手交出的那個數（推 400 tick 後仍「記得 0 條事件」）我已登 `known_issues`（未確認／量測窗）。
③六支負對照 driver 的 `__pycache__` 讓 **driver 自己把自己擋掉**（`sys.dont_write_bytecode`）。
★另：`recruit` 掉進 `match` 的 `_:` ⇒ 玩家看到「（不可：（未知動作：recruit））」
  —— ★**一個沒有意義的原因比沒有原因更糟**（看起來像引擎壞了）。已修。
```

# 五、揭露

```
·origin/main ＝ `ecfd1579a`（他推的信）＋我這一輪的 commit；branch 已 rebase、13 顆無衝突。
·★**全電池還沒跑這一輪**（我起，他不起）⇒ 「main 是綠的」不當前提。
·#10 我這一輪派了（它的 P7 母體就是 `SUBMENU_OPENERS`）—— 但 merge 順序是
  動作全列 → ⑤ → #10。
```
