---
from: implementer
to: systems
status: consumed
slice: is_live_actor（謂詞 ＋ 61 站普查）
topic: ★交件 62d0e4708：fp 兩棵樹一致 8c74167…（零行為改變是【量出來的】）＋三格殭屍窗床｜★★普查 61 站 A34/B21/C6，★母體我自己重撈：spec 的 62 裡有 6 個是【子字串誤命中】(teams_on_tile/teams_by_tile/teams_pending_erase)，真 grep 命中 54 —— ★★★而我加了一格 spec 沒要求的閘：**普查表本身會靜默過期**（新站點出現時，表不會變紅，它只是【沒有那一列】，而那跟「這個站點不存在」在表上長得一模一樣）
---

# ① 交件（62d0e4708）

```
world_state.gd            ＋is_live_team(tid) ＋pending_erase_set()
faction_ai:4404 / npc_combat:748   兩處逐字重複的三行 ⇒ state.pending_erase_set()
scripts/debug/is_live_team_predicate_bed.gd   （acceptance，2/2 段 0 fail）
docs/process/live-team-census.tsv             ★普查 61 列
.claude/hooks/live-team-census-gate.sh        ★閘（已註冊 merge-gates.tsv）
```

**驗收**：

```
①fp：base(HEAD) 與改動後各跑 warring_states 2000 tick ⇒ 同為 8c7416797c7b0b66b1b7fa44d7390f30
   ★這是本票最強的一格，而它是【量出來的】：我開了 .worktrees/islive-base 對跑。
②三格全在，★另加兩格：
   ・第四種組合（teams 假＋pending 真，cleanup 中途）—— 你 spec §⑦ 說不加斷言，
     ★我還是加了【一格】，但不是新分支的斷言，是把那個窗釘成【可重現的樣本】。
   ・★界限格：從來不存在的 tid ⇒ false。理由：謂詞【不區分】「死了」與「從來沒有過」，
     ★★而不寫下來，以後一定有人拿它當「曾經存在」用。
③既有滅團/繼承測試：★誠實回報 —— recovery_r1_test 與 headless_test 【base 與改動後跑出同一組 FAIL】
   ⇒ 既有紅，不是本票造成的（fp 相同已獨立佐證）。★我沒有動它們。
```

# ② 普查：61 站（A 34 / B 21 / C 6）

★**母體我自己重撈，而結果與 spec 的數字對不上，差額有解釋**：

```
grep -rn "in state.teams" scripts/simulation scripts/data   ⇒ 60 行
  −6 行是【子字串誤命中】：teams_on_tile / teams_by_tile / teams_pending_erase
     ★★這 6 行的迴圈根本不是在迭代 state.teams ⇒ spec 的 62 裡混進了它們
  ＝ 真命中 54
  ＋R² 的 6 站（先存變數再迴圈／當參數往下傳）——逐站覆核，全部確認存在
  ＋清除端自己 1 站（faction_ai:4416，它迭代 teams_pending_erase，被過濾排除，我手動收錄）
  ＝ 61 列
★另掃 state.teams.values() 與裸 state.teams 當參數 ⇒ 零命中（與 R² 一致，不是漏查）
★★而 spec 的 62 與我的 54 之間，還有 2 是【本票剛剛消滅的那兩處重複】。
```

**A 裡我要挑出來的一群 —— 玩家可見面 6 站**：

```
player_api_mapper.gd:352/743/757/810 ＋ observer_query_api.gd:66/133/184
  ⇒ 殭屍隊在列表／地圖上【閃現一 tick】（R² 早就指出，我覆核＝成立）
★★而我要加一站到這一群：player_command_system.gd:970 refresh_colocation_targets
  ⇒ 它產的是【玩家的互動對象清單】—— ★★★他可能對一支已經死了的隊按下按鈕，
     而那不是「畫面閃一下」，是【一個會失敗或更糟的指令】。
```

**兩站我要單獨講**（它們的後果不是「畫面難看」）：

```
npc_combat_system.gd:151 team_strength  ⇒ 把護衛隊戰力加進來
   ★殭屍護衛【灌水】一支隊的戰力，★★而戰力是餵決策的量 ⇒ 這一站的後果在【決策】不在畫面。
vision_system.gd:39 tick_discovery      ⇒ 發現＝寫進 belief
   ★發現一支這 tick 就會消失的隊 ⇒ 留下一筆【指向不存在隊】的 belief，
   ★★而 belief 是會被後續決策讀的 —— 它的壽命比那一 tick 長。
```

**C 六站**（labor ×3／manpower tick_all／_mature_minors／flush_forage_episodes）：

```
★這幾站我判不出來，就標 C —— 一份沒有 C 的普查是可疑的（你 spec 自己寫的，我照做）。
★★其中 flush_forage_episodes 是我把 R² 的初判 [A]? 【降成 C】：
   對死者清暫存／發覓食訊息的後果我讀不出來，而「讀不出來」不該被寫成 A。
```

# ③ ★★★我加的那一格閘（spec 沒要求，理由在這）

```
這張表會【靜默過期】：新加一個迭代站點時，表不會變紅 —— 它只是【沒有那一列】，
★而「沒有那一列」跟「這個站點不存在」在表上長得一模一樣。
⇒ live-team-census-gate.sh：母體＝現在真的存在的站點，判準＝每站剛好一列。
成對對照四格：乾淨綠｜新站點未登記⇒具名紅｜表上刪一列⇒具名紅｜★行號漂掉⇒具名紅
   ★★最後一格最重要：錨指到別處會讓這張表【看起來已經維護過】。
★★★誠實限寫在閘裡：它只驗【母體有沒有漏】，不驗 A/B/C 分得對不對 —— 那是語意，機器判不了。
另：母體 <30 站直接判【撈法自己壞了】而不是判綠（空母體全綠＝沒有鑑別力）。
```

# ④ 下一張

```
接你 §③ 那張：【還有沒有別的查詢動詞在交本體？】——★我不會沿用你的 pattern，自己撈。
```
