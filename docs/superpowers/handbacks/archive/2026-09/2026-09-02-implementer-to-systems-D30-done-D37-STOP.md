---
from: implementer
to: systems
status: consumed
slice: D 級即銷（#30 ／ #37）
tier: infra
topic: ★#30 已無事可做:`_calc_reserve` 連同那句說謊的註解【2026-08-26 已被 03fdf03c 整支刪掉】(該條目寫於 8/25、隔天就修了)⇒ 條目 stale,判給你;★★★#37 我【停下來報】——那床不是 fixture 壞,也不是測一個不存在的行為:它在 2026-08-21 `bdad0174`(紮營 de-patch 拿掉瀕餓門檻)那天變紅,而現在【站在自己 L0 營地上「再紮一次營」贏過「把它升成 L1」】;★證據=逐 option util dump + 該 commit 的 diff
---

# ★①#30 `_calc_reserve`：**已經沒有東西可修**
```
★窮盡 grep（scripts 全樹，無 head 無 glob）：`_calc_reserve` ＝ ★★0 個出現
★那句說謊的註解（「留底邏輯收進 TradeValuation.reserve…NPC + 玩家路徑同用」）＝ ★★0 個出現
★★★誰刪的：`03fdf03c`（2026-08-26）
   "refactor(valuation): delete the default that lets a decision be blind to its own state"
⇒ ★條目寫於 2026-08-25，★★【隔天就被修掉了】—— 而條目留著沒動
```
★**真身在哪（你要求先查再判）**：`trade_valuation.gd:87`
`static func reserve(team, res, leader_values, state) -> float`，★★**29 個 caller**，
★★★**而 `state` 現在是必填**（那顆 commit 的標題就是「刪掉那個讓決策對自己狀態盲目的預設值」）
⇒ ★**你要的第二種處置（「註解改成『此機制已移除』」）也不需要**：機制沒有被移除，是**收斂到單一源了**，
  而那正是原註解宣稱、當時卻還沒做到的事。
⇒ ★★**要處置的只剩 `known_issues` 那條（你 own）** —— 它現在描述一個不存在的檔案狀態。

# ★★★②#37 `settlement_s2b_test`：**停下來報**（依你③的規定）

## ★不是 fixture 缺欄位（我照你的提示先查了）
```
臨時 probe（跑完已刪）在該 fixture 下 dump：
  can_settle_here    = true          ← ★紮根的 applicable【成立】
  settle_site_quality= 1.0
  settle_eta_days    = 6
  food_runway_days   = 9999
  tile lookup 5005   = 存在
⇒ ★★fixture 沒有缺欄位。★★★紮根是【被秤輸的】，不是不 applicable
```

## ★★逐 option util（★這是「先 dump 再開藥」）
```
  紮營  u = 0.1943   ← 贏
  紮根  u = 0.1364
  建設  u = 0.0880
```

## ★★★而 `紮營` 的目標是【隊腳下那一格】—— 也就是它自己的營地
```
_find_unowned_farmable_tile(state, team) ⇒ 回 (5,5)，而隊就站在 (5,5)
★根：`faction_ai_system.gd:5527` 的 `dirs` 第一個是 `Vector2i.ZERO`（本格）
★★而 :5533-5534 只擋 outpost_level>0／有主／山 —— ★★★【沒有擋 camp_level>0】
⇒ 「在自己已經紮好的營地上，再紮一次營」是永遠可選的
★我加了第二塊可耕地重跑 ⇒ 目標仍是 (5,5) ⇒ ★★這不是「一格世界」的 fixture 退化
```

## ★★★它是哪一天變紅的 —— **有具名 commit**
```
`bdad0174`（2026-08-21）"camping no longer waits for starvation, and losing is now visible"
  ★該 commit 的 diff：
    -  return ctx.food_days < ctx.desperation_entry_threshold and ctx.has_farmable_tile …
    +  return ctx.has_farmable_tile and not ctx.has_own_outpost,
★★而 s2b 的 fixture 是 food=100／pop=5 ⇒ food_days = 25 ⇒ ★【不瀕餓】
⇒ ★★★那天之前：紮營【不 applicable】⇒ 紮根獨贏 ⇒ 床綠
   那天之後：紮營恆 applicable ⇒ 0.1943 > 0.1364 ⇒ 床紅
```

## ★所以我判：**三種可能裡它是第三種**
```
①fixture 壞    ⇒ ★不是（欄位齊、applicable 成立）
②測一個已不存在的行為 ⇒ ★★也不是（紮根 option 還在、§4a 設計還在、to_task/commit-hook 都在）
③★★★【一個已 merge 的 de-patch 改變了行為，而這張床是唯一看見它的東西】—— 是這個
```
⇒ ★**依你③的規定我不自己動**：★★不拆、★★★也不「調 fixture 讓它綠」——
  **調 fixture（例如把食物調低讓紮營不 applicable）＝ 把一個真的行為改變藏起來**，
  那正是你②禁的「把一張假守衛換成另一張」。

# ★③要你裁的（★而我有傾向，說出來但不執行）
```
①★「站在自己 L0 營地上，紮營贏過紮根」是 intended 嗎？
   ★★de-patch 的原意是「沒有被動收入的隊不該等到瀕餓才准紮營」——
   ★★★而「在自己營地上再紮一次」不在那個原意裡（它不解 catch-22，它只是同一格的 no-op-ish 動作）
   ⇒ ★我的傾向：`_find_unowned_farmable_tile` 的候選應排除【camp_level>0 且是自己紮的】那格，
     或 紮營 在 `can_settle_here == true` 時不 applicable（已在自己營地 ⇒ 生產性動作是紮根）
   ⇒ ★★但那是 production 行為改動 ⇒ 你的 spec、不是我自己動
②★★在①裁定之前，這床要不要先標成【已知紅、原因具名】而不是留著當無聲的紅
   ⇒ ★★★因為它現在的狀態正是你今天入 cases 的那個：「一張紅著、沒有人在讀的床」
③★若你裁「新行為是對的」⇒ 那床的斷言要改寫成新行為，而那時我需要你給【新的預期是什麼】
```

# ④驗與限
```
★production diff = 0、床 diff = 0（臨時 probe 已刪，`git status` 空）
★限①：我只驗了 s2b 的 ①③④⑥⑦ 那幾條紅；②⑤⑧⑨ 本來就綠，我沒動
★限②：★★我沒有驗「2026-08-21 之前這床真的是綠的」——
   ★★★我推的是【那天的 diff 讓 applicable 從 false 變 true】＋【fixture food_days=25 不瀕餓】
   ⇒ 要坐實只需在 bdad0174^ 上跑一次這張床；★我沒跑（那要 checkout，而我不在那條線上）
```
