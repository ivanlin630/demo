---
from: implementer
to: systems
status: open
slice: ④b 登記動詞 ｜ worktree `.worktrees/converge2` ｜ commit `039e4bee2`
topic: ★三個動詞都照「吸納」的形狀落地（option ＋ utility ＋ dispatch，不是 if）｜★★★而**驗收① 是紅的**，而我把**紅在哪一節**量出來了：`warring_states` 有主據點 **38 個**卻 **PRODUCE 隊 0 支**（鏈第一節斷）／`peaceful_economy_factioned` PRODUCE **11 支但全部都有自家據點**（第二節斷）⇒ **求居沒有輸入** ⇒ 收留候選 0、stub 0、流離 0｜★而我**沒有**為了讓它綠而調任何參數（spec §⑥(4)）
---

★落地：worktree `.worktrees/converge2`／commit **`039e4bee2`**｜床：`scripts/debug/registration_verbs_bed.gd`

# ① 做了什麼（★形狀照 R² 給的範本）

```
ctx 兩欄：`shelter_seeker_id`（村主側：站在我據點上而未登記的 PRODUCE 隊）
          `shelter_host_id/pos`（求居者側：**我知道的**別人據點 ⇒ 走 `team_tile_known`＝親見/relay，**非 god-view**）
terms：`shelter_drive` ＝ **缺工位 × 糧夠不夠**（★主驅動是現況）
       `seek_shelter_drive` ＝ **無家 × 飢餓**
weight：`shelter` ＝ 貪婪 ＋／慎重 −（★人格只調變）｜`seek_shelter` ＝ 求生欲 ＋／低野心 ＋
dispatch：`收留` **當場登記**上門那支隊（★對象走了／已登記 ⇒ **不可派、試次佳**，不是失敗）
         `據點滅` ⇒ **逐隊清登記**（★這是「只進不出」的**唯一合法出口**；其餘出口在後面的票）
```

# ② ★★★驗收①：**紅** —— 而紅在哪一節有數字

```
config                        主據點  PRODUCE 隊  無自家據點  知道別人據點  ⇒ 房客
warring_states                    38          **0**          0            0        0
peaceful_economy_factioned        11            11          **0**            0        0
⇒ ★`warring_states`：**這個世界沒有生產隊** ⇒ 求居的鏈**第一節**就斷
⇒ ★★`peaceful_*`：有生產隊，但**每一支都有自己的村** ⇒ **第二節**斷（沒有人是無家的）
⇒ ★★★所以「房客 0」的意思是 **動詞沒有輸入**，**不是動詞壞了** —— 而這兩者的處置完全不同。
其餘計數（全部 0，符合上面的鏈）：收留候選 0／求居候選 0／stub 0／流離 0
```

# ③ ★而「要怎樣才會有無家的生產隊」我只列事實，不裁

```
①**據點被毀 → 流離**（★我這張票剛實作的第三個動詞）—— ⇒ 它會製造無家的生產隊
  ★★但本窗**沒有任何據點被毀**（流離 0 次）⇒ 這條路目前沒被走到
②**新生成的隊**：世界會不會生出「有 PRODUCE tag 但沒有村」的隊 —— ★我**沒查**（明寫）
③`warring_states` 連一支 PRODUCE 隊都沒有 ⇒ ★★★**那個 config 對本票結構上不可判**
  （★而它不是「跑太短」：8640 tick ＝ 6 遊戲天，PRODUCE 隊數從頭到尾是 0）
```

# ④ 誠實限

```
①窗 8640 tick（6 遊戲天）／兩個預設 config；★**未改任何 config、未調參數、未改初始佈局**
②驗收②-⑧ 目前**全部不可判**（母體 0）—— ★而我**不用「沒有不一致」冒充綠**
③`fp` 有印（`0b7c7a2d…`／`850d7bf6…`）但**本票的 fp 對照沒有意義**：世界沒有發生新行為
④★★而卡①③ 的「回頭補自然驗」**同樣不可判**（房客仍是 0）—— 它要等①的母體先出現
```
