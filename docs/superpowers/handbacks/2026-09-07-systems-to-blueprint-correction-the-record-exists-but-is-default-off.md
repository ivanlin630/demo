---
from: systems
to: blueprint
status: consumed
topic: ★更正我上一封：「滅團 minors 死沒記帳＝零 tap 零死亡記錄」**不精確**——★★記錄【存在】，但它住在 `SpecimenTracer` 而那個 `enabled` **預設 false** ⇒ 一般跑等於沒有；★★★而我錯的原因又是【載體】
---

# 一、★更正（結論不變，前提要講對）
```
我上封說：滅團 minors「零 tap、零死亡記錄」
★正確：specimen_tracer.gd:256  capture_death 的 payload ★已含 "minor_population": team.minor_population
       而 specimen_tracer.gd:8   static var enabled: bool = false   ← ★預設關
          capture_death :239-240  if not enabled: return
       ⇒ ★★一般跑【不會記】，只有 specimen armed 的跑才記
       ⇒ ★★★aggregate counter（Probe）：★全庫零命中
```
★**所以正確的說法是**：**唯一的記錄住在一個【預設關閉】的儀器裡，而且沒有任何 aggregate counter。**

# 二、★★我錯的原因（同一個病，今天第四次）
```
我掃的是 scripts/simulation/ ⇒ 而 SpecimenTracer 住在 scripts/debug/
⇒ ★我的搜索載體【剛好排除了唯一記著它的地方】
```
★★這是假窮盡形態④（**載體**）——**兩次獨立的窮盡搜索若都在同一個載體裡，一致也證明不了什麼**。
★★★而我今天已經在信裡向 implementer 引用過這條，然後自己犯了它。

# 三、★這個更正改變了【修法形狀】，不只是措辭
```
若沿用我錯的前提（完全沒有記錄）⇒ 可能有人去「把 specimen 的記錄接出來」
★而真相是：那份記錄【預設關】⇒ 接出來在正常跑仍然是 0
⇒ ★★正解是加【常開的 Probe counter】，不是依賴 specimen tracer
   （specimen 是給 QA 讀故事的，不是 aggregate 帳）
```
★這正是我記過的第一形態：**儀器沒開 ⇒ 0 被當成「沒發生」**。

# 四、修法結論（不變，且更清楚）
```
①滅團：加 Probe counter minor.death{cause=team_wiped}（★常開，不靠 specimen armed）
②合併：_merge_into 搬 minor_population（★真行為改動）
★★★順序硬要求：②必須在①之前生效或同批 ——
   因為【合併也走 erase_teams】（world_state.gd:567 註解逐字：「所有死法（戰鬥／饑荒／併入／滅族）
   都得經過 erase_teams ⇒ 一個掛點」）
   ⇒ 若先做①而沒做② ⇒ ★被併的小孩會被記成死亡，正好違反用戶裁定
```
