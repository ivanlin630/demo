# 人口儀器 HOW（先儀器後修法；用戶核可 arc 形狀 2026-09-07）

## §0 為什麼是儀器不是修法
用戶核可的形狀＝**先儀器後修法**。理由在本專案已有血證：
繁殖 arc 的問題清單裡「各環節零 counter」被 blueprint 升為**最重**——
★**沒有 counter 的環節，任何關於它的斷言都只能靠讀 code 推論**，而
[[feedback_static_read_epistemic_limit]]：**讀得出「什麼存在」，讀不出「跑幾次」。**

## §1 ★先查 code 的那一格，已經查完了（結論改變了設計）

blueprint 清單 ⑥ 標「先查 code 再量」。**查完了，而答案讓那格從【量測】變成【造記帳點】**：

```
窮盡掃 scripts/simulation/ 下所有 minor_population（22 行 / 8 檔，不帶過濾）
⇒ ★變動點只有三個：
   population_system.gd:87     team.minor_population -= n     成年（小孩→成人）
   reaction_system.gd:327,336  team.minor_population += 1     出生
   resource_system.gd:331      team.minor_population -= md    饑荒小孩死亡（FAMINE_MINOR_DEATH_RATE）
⇒ ★★滅團 / 合併 / 轉移：★零命中
   （`subteam_system.gd` 全檔零命中——它明確搬 leader / named_members / anon，★唯獨沒搬小孩）
```
**⇒ 結論：孤兒蒸發＝【是】，而且是結構性的。** 小孩隨著隊被 `erase_team` 一起消失，
★**沒有任何 tap 會響，也沒有任何死亡被記錄**——它不是「死亡」，是**從帳上不見**。

## §1b ★★★用戶裁定（2026-09-07）把這格從【開放量測】變成【驗收既定語意】

```
用戶裁：
  ①滅團且【無倖存成人】⇒ minors 同滅，且★【記死亡帳】
     理由：無人照料不活＝中世紀誠實，零特例
  ②被併（成人仍在）    ⇒ 小孩【跟隊走】
```
★**而我上面那份窮盡掃已經回答了「現行 code 是否如此」：★★兩格都不符合。**

| 用戶要的語意 | 現行 code | 差在哪 |
|---|---|---|
| 滅團 ⇒ minors 同滅 **且記死亡帳** | 隨 team 一起消失，**零 tap、零死亡記錄** | ★**死是死了，但【沒有記帳】** ⇒ 卷面永遠是 0，而 0 會被讀成「沒發生」 |
| 被併 ⇒ 小孩**跟隊走** | `subteam_system.gd` **全檔零命中** `minor_population`；它明確搬 leader／named／anon | ★★**小孩沒被搬** ⇒ 合併時等於**靜默蒸發**，而用戶要的是「跟著走」 |

⇒ ★★★**所以這格不是儀器票，是【修法票 + 儀器票】**：
```
修法：①erase 路徑加死亡記帳（★不是加行為——它本來就死了，是把它記下來）
      ②合併路徑搬 minor_population（★這【是】行為改動：從蒸發變成轉移）
儀器：兩者都要有 counter，否則改完也不知道有沒有生效
```
★**而②是真的行為改動**（世界會多出小孩），所以它要走完整驗收：合併前後
`Σ minor_population` 守恆（★用 CoinAudit 那種【全池】口徑，別自寫子集普查——今天的血證）。


★★★**所以 ⑥ 的第一格不是「量孤兒有沒有蒸發」（code 已答），是【造一個它消失時會響的記帳點】。**
沒有那個點，卷面上這一格永遠是 0 —— 而 **0 會被讀成「沒發生」**（[[feedback_instrument_lies_three_forms]] ①）。

## §2 儀器清單（per-隊 per-窗 counter）

| # | 儀器 | 現況 | 要做的 |
|---|---|---|---|
| ① | 出生 | `breed.born` 已有 | 補 **per-隊** 維度 |
| ② | 成年 | 無 | `population_system.gd:87` 掛 tap（小孩→成人流量） |
| ③ | 晉升 anon→named | 無 | **各管道分計**：繼位（`event_system`）／領主提拔（`faction_ai`）／named-scarcity A・B ⇒ 都經 `PersonGenerator.generate_for_team`，★在該入口分 `reason` 記 |
| ④ | 死亡 | 部分 | **分軸**：餓死／戰死／其他 × **成人／小孩分列**（`resource_system.gd:331` 已是小孩專用支路，好掛） |
| ⑤ | 淨成長率 | 無 | 隊級 + 世界級（★由 ①②③④ 推導，不獨立量，避免第二本帳） |
| ⑥a | ★**滅團記死亡帳 + 合併搬小孩** | ★**兩者現行 code 都沒有** | **修法+儀器**（見 §1b）：`erase_team` 記 `minor.death{team,count,cause=extinction}`；`_merge_into` **搬** `minor_population` 到吸收方並記 `minor.transferred` |
| ⑥b | 饑荒死亡順序 | 有 rate 無 counter | 記成人／小孩**各自死亡數與發生 tick**，才能看出順序與比例 |

★**⑥a 的形狀已由用戶裁定（§1b）**：滅團＝同滅+記帳（記帳非行為改動）／被併＝跟隊走（★這是行為改動，要完整驗收）。
★★棄養／送養機制＝用戶裁**先不加**，等卷面數字。

## §3 產物
```
90 天人口卷 + 對比輪（★同 seed）｜分層讀數 config vs runtime（照 §7-D）
★可與 C-refill 床併一張卷（它要 factions + 大團，人口卷也吃得下）
```

## §4 ★判讀預註冊（★在看到數字之前寫，而這正是它危險的地方）
```
①晉升率 vs named 死亡率：追不追得上（追不上 ⇒ named 層長期萎縮）
②生育條件疊乘後的【有效】出生率（★reaction_system.gd:231 註解已標：
   小隊 `minor_population < population*0.2` 疊 safe+fed ⇒ 生育慾望結構性恆 0）
③孤兒蒸發量級（⑥a 建好之後才有數字；★在那之前這格是【未量】不是 0）
```
★★**預註冊的風險我標在這裡**（[[feedback_prewritten_verdict_convinces]]）：
上面三條是**看到數字前寫的**。★★★**若某格的數字剛好符合預期，要先問「這個儀器有沒有可能只是沒接電」**，
而不是直接當成證實。

## §5 驗收
```
①六格 counter 都有【非零的一次】（★零不算通過——零與沒接電同形）
②★★陽性對照：把該機制關掉/擾動，對應 counter 必須變（會紅才算有鑑別力）
③⑤淨成長率 = ①+②−④ 對得上（★對帳式，而它只證明母體內部無漏，★★不證明母體完整）
④卷面必帶誠實限：「貨幣量未過校驗（±14× 待判）」若跑在 ⑨ 世界上
```

## §6 排程
★**批 2 收口後（B-v0 merge）第一優先**（blueprint 裁）。本 spec 先鎖形狀，不 dispatch。
