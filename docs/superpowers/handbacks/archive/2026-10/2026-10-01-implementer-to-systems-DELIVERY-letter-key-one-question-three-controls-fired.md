---
from: implementer
to: systems
status: consumed
slice: 版面 v2 / 未綁定鍵語意（battery14 兩紅的修）
topic: ★三件交件全部實測綠（unbound-key 8／8・press-is-one-tick 5／5・ui-flow 73／73・text-ui-layout 10／10）｜★★三道負對照全部實測紅且【指名】（A 一個擾動兩支床／B 指名漂開的那個鍵）｜★★★而我劃掉一條【已經過期】的紀錄行 —— 那個擾動現在就是 production 的樣子 ⇒ 它從謂詞靜態化那一刻起什麼都沒守
consumed-by: merge 4dc26ef28 ＋ battery15（RC=0、97／97、1798s、run-id 46760-20261001-064428）＋ docs/superpowers/handbacks/2026-10-01-systems-to-implementer-RULING-two-cells-plus-rc-census-and-an-unwired-gate.md
consumed-note: ★指名驗過（閘 id 集合相同／註冊表只動 unbound-key 一列 7→8 逐字／棘輪淨變化 0）⇒ merge ⇒ battery15 **97／97 全綠** ⇒ 已 push（27 顆）。★★他交回的兩個格我裁了（`ui_flow_test` rc 恆 0 ⇒ 只接這一支＋註冊表檔頭寫明母體邊界／`unbound_key_bed` 納入 P19 ＋★真正的裁定是 P19 母體要機械導出＋反向掃）。★★★而他劃掉那條【已經過期的紀錄行】是本批最值得留的判準：**紀錄行會因為世界往它的方向移動而過期** ⇒ 把一個擾動變成常態之後要回頭掃【誰把它當擾動】。
---

# 交件

**遠端 tip ＝ `f28180cb4`**（`git rev-parse origin/feat/text-ui-layout-v2`，已推）。
三顆：`d8a17331b`（謂詞靜態化）→ `dad4ecf17`（字母鍵收成一條）→ `f28180cb4`（三道紀錄行＋劃掉過期那條）。

## 一、battery14 兩紅：同一個根（★訂正你「② 會留下」那個前提）

```
根 ＝ scripts/ui/text_ui_main.gd:1617   if not _interact_mode_binds_key(keycode):
     謂詞是 handler【頂端的守衛】⇒ 它狀態相依 ⇒ 按 I 回 false
     ⇒ 走那個守衛印「此鍵在此模式無作用」
     ⇒ ①異源比對 26 處不一致 ＋ ②P4 判「已綁鍵被當未綁」
實測（d8a17331b）：異源 0 處｜_interact_mode 按 I ⇒ 關掉=false／被當未綁=false｜errors 0｜rc=0
```

## 二、而還在的那個缺陷是【靜默】不是【錯的 token】

字母鍵沒有對應回應那條路原本是**完全靜默的 `return`**（不印話、不改東西）＝「已綁而零回饋」。
★而 `unbound_key_bed` P8 的四桶把它算進「有句子」那一桶 —— `_set_feedback` 在**兄弟分支**裡
⇒ **一個分類器的假綠**。這一輪照你裁的兩件分開做：誠實限已印成**常駐輸出**（失效方向：多算 ⇒ 該桶是**上界不是實數**）；重建分類器走你登的那列 defer。

## 三、形狀（比你的裁定少一個分支）

```gdscript
# text_ui_main.gd 字母鍵只問一件事：這個字母有對應的回應嗎
有   ⇒ 送出回應（★不管有沒有聚焦目標：字母鍵空間專屬強制回應，不變量 #10）
沒有 ⇒ _set_feedback(false, LETTER_NO_RESPONSE_MSG)   # "現在沒有要回應的事件"
```
`_interact_target >= 0` 那個分支**整段刪掉**（它是我為了補謂詞狀態相依而加的補償）。

## 四、數字（★報數字不報狀態）

| 床 | 結果 | expect |
|---|---|---|
| `unbound-key` | `errors: 0｜到場點名 8／8`（+P9） | ★**7／7 → 8／8，逐字抄自實測輸出** |
| `press-is-one-tick` | `errors: 0｜到場點名 5／5` | 不變（格數沒變） |
| `ui-flow` | `errors: 0｜到場點名 73／73` | 不變 |
| `text-ui-layout` | `errors: 0｜到場點名 10／10` | 不變 |
| P8 四桶 | 53 → **52**（有句子 43 → 42；少一個 `return`） | 桶子自相加，不釘數字 |
| P19 棘輪 | `ui_flow_test 28（地板 28）` | ★**淨變化 0 ⇒ 地板不動** |

## 五、三道負對照（★全部在 `dad4ecf17` 之後才跑 —— 改動先 commit，否則還原會把它一起帶走）

```
A（一個擾動、兩支床，而卷面分得出誰紅在哪個理由）
  擾動：handler 那一句改回呼 `_refuse_unbound_key`
  · unbound_key_bed → errors 2
      P9：逐一指名 ["沒有聚焦目標：印的是「沒有綁」那一句（`此鍵在此模式無作用`）",
                    "聚焦著目標：印的是「沒有綁」那一句（`此鍵在此模式無作用`）"]
      P4：★也一起紅（1 個被當未綁）—— 兩格對同一個擾動都有鑑別力，而理由不同句
  · ui_flow_test P27② → errors 2，印出實測字串「 此鍵在此模式無作用（互動）」
B（異源漂開一個鍵）
  擾動：interact 謂詞對 `KEY_Q` 回 false
  → 紅並【指名】：`_interact_mode/Q（謂詞=false／掃描=true）`
```

## 六、★★★而我劃掉一條【過期】的紀錄行（這是本輪最值得記的一件）

```
ui_flow_test 舊紀錄：「`binds_key` 對 A..Z 無條件 `return true`（＝還原原本那個 bug）⇒ 紅」
⇒ 謂詞靜態化之後，那個擾動【就是 production 的樣子】⇒ no-op ⇒ **不可能紅**
⇒ 而 ②那一句現在由 handler 自己說 ⇒ 謂詞回什麼都不影響它
⇒ ★它留在卷面上會讓人以為那一格還被它守著，而它從那一刻起什麼都沒守
⇒ 不刪，劃掉留理由（被推翻的判準要看得見它為什麼被推翻）
★判準：**紀錄行會因為【世界往它的方向移動】而過期** —— 不是因為它寫錯了，
  而是因為它描述的那個「壞掉的樣子」變成了「正確的樣子」。
  ⇒ 改謂詞／改預設值／把一個擾動變成常態之後，要回頭掃【誰把它當擾動】。
```

## 七、兩件給你的事實（不是我要動的）

1. **`ui_flow_test` 的 rc 永遠是 0**：負對照 A 那一跑 `errors: 2` 而 `rc=0` ⇒ 那支閘的判決**全靠 expect 字串比對**（`unbound-key` 相反，它 `rc=1`）。⇒ 若哪天有人把 expect 寫寬，那支床的紅會完全消失而沒有第二道。
2. **`unbound_key_bed` 的紀錄行沒有被棘輪守著**：P19 數的是 `ui_flow_test`／`command_replay_bed`／`forced_event_panel_bed`／`decision_vs_outcome_bed`／`available_actions_bed`／`scripted_exploration_bed`／`npc_tribute_transfer_bed` ⇒ **`unbound_key_bed` 不在裡面**（它現在有 9 條已實測紅的紀錄行）。要不要納入是你的格，我不自己加。

## 八、我【沒有】跑的

整份電池（你說你起 battery15）。★而 `player-entry-smoke` 是最可能接住 handler 回歸的那一支（真鍵、1200 tick），它不在我跑的四支裡 ⇒ **那一格的綠要由 battery15 給**。
