---
from: systems
to: implementer
status: consumed
topic: ★兩個小修（blueprint GO，無設計選擇＝直修）：①滅團 minors 加常開 counter ②合併搬 minor_population；★★★而它們有【順序陷阱】：先做①不做② ⇒ 被併的小孩會被記成死亡，正好違反用戶裁定
---

# 一、用戶裁定（語意，不是我的意見）
```
①滅團且【無倖存成人】⇒ minors 同滅，且【記死亡帳】（死因 = team_wiped）
   理由：無人照料不活＝中世紀誠實，零特例
②被併（成人仍在）    ⇒ 小孩【跟隊走】
```

# 二、★★★順序陷阱（先講，因為它會讓你白做）
```
world_state.gd:567 註解逐字：
  「★所有死法（戰鬥／饑荒／併入／滅族）都得經過 erase_teams ⇒ 一個掛點」
⇒ ★合併【也】走 erase_teams（subteam_system.gd:212 → state.erase_team(absorbed_id)）
⇒ ★★若先加「erase 時記 minor 死亡」而沒先搬 ⇒ 被併的小孩會被記成 team_wiped 死亡
   ——那正好是用戶裁定的【反面】
```
⇒ **②先行或同批**。搬完之後 `absorbed.minor_population` 應為 0，erase 記到的自然只剩真正無人倖存的。

# 三、錨點（我已窮盡掃過，`scripts/simulation/` 下 `minor_population` 22 行 / 8 檔）
```
②合併搬運：scripts/simulation/subteam_system.gd:285  func _merge_into(state, absorber_id, absorbed_id)
   ★該函式目前明確搬 leader_id / named_members / anon，★唯獨沒碰 minor_population（全檔零命中）
   ⇒ 加：absorber.minor_population += absorbed.minor_population; absorbed.minor_population = 0
①滅團記帳：scripts/data/world_state.gd:549  func erase_teams(tids)
   ★:572 已有 SpecimenTracer.capture_death(...)——但★★SpecimenTracer.enabled 預設 false
   ⇒ ★★★不要依賴它：加【常開的 Probe counter】minor.death{cause=team_wiped}
     （specimen 是給 QA 讀故事的，不是 aggregate 帳；靠它 ⇒ 正常跑永遠 0，而 0 會被讀成「沒發生」）
```

# 四、驗收（★兩條，缺一不可）
```
①★守恆：合併前後 Σ minor_population 守恆
   ★★用【全池】口徑（世界上所有 team 的和），★別自寫子集普查
   —— 血證：⑨② 自寫兩池普查報「coin 消失 −1210.61」，換成既有全池 CoinAudit.total() 後 = 0.00，100% 假影
②★★陽性對照（會紅才算數）：
   造一個「有小孩的隊被併」⇒ counter 的 transferred 必須 > 0、且該隊的小孩【沒有】出現在 death counter
   造一個「有小孩的隊全滅」⇒ death counter 必須 > 0
   ★★★兩個對照缺一個，就分不出「搬對了」與「兩邊都沒發生」
```

# 五、範圍與時機
```
★兩修都小、無設計選擇（blueprint：直修不再問）
★★時機：批 2 之後；★但若你有空檔可先行（blueprint 授權）
★★★不要順手改行為以外的東西——②已經是真行為改動（世界會多出本來會消失的小孩）
```
