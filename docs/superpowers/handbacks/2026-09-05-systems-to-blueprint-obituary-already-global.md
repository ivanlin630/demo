---
from: systems
to: blueprint
status: open
slice: ★★★用戶那一問查下去 —— **現況就是【god-view 式全域訃聞】，而且對【所有死法】都是**
topic: ★用戶問「刪合併屍體會不會影響遙遠隊伍的舊記憶」⇒ ★★而查下去:現況【不是不影響,是直接把記憶刪掉】—— `erase_teams` 逐 observer 清 `team_known[obs].erase(dtid)`、清 `team_discovered`、清 `f.known_member_states.erase(tid)`;★★★所以你剛裁的②【禁 erase 順手清別人 belief】—— 現況【正在做】,而且不只合併,是【戰鬥/饑荒/併入/滅族全部】;★而這讓 R² 的第三案(路由進既有 chokepoint)【會把違規擴大】,不是解法 —— 票的範圍因此變大,我回報而不自己擴
---

# ①查證（★file:line）
```
world_state.gd:592-594  f.member_team_ids.erase(tid) ／ ★f.known_member_states.erase(tid)
world_state.gd:632-636  ★★for obs in team_known: … team_known[obs].erase(dtid)   ←【逐 observer 清】
world_state.gd:637-640  同法清 team_discovered
⇒ ★★★一隊死掉 ⇒【全世界立刻忘記它】—— 而那正是你裁的②要禁的東西
```

# ★★②而它不只發生在合併（★這才是範圍問題）
```
★`erase_teams` 是【所有死法】的單一 chokepoint(戰鬥／饑荒／併入／滅族)
⇒ ★★所以「死了就全世界忘記」是【現況的通則】,不是合併特有
⇒ ★★★而那讓「鬼城情報」這條法【現在根本不可能發生】:
   —— 一支隊死了,沒有人還記得它在哪 ⇒ 不會有人跑去一座空城
```

# ★★★③而 R² 的第三案在新 WHAT 下【不再是解法】
```
★R² 查得對:erase_teams 是既有 chokepoint,而它處理了所有懸空引用
⇒ ★★而它處理的方式【就是清掉別人的記憶】—— 在你裁定之前那是合理的
⇒ ★★★所以「把漏出去的 call site 路由進去」＝【把違規擴大到合併路徑】
   —— 而不是修好它
★而我【不自己擴票】:這已經從「清屍體」變成【改 erase 的語意(tombstone)】,
   ⇒ 它會碰到所有死法 ⇒ ★★範圍與風險都不是原票的量級
```

# ④★要你裁的（★兩條路，我給尺寸不給決定）
```
★(a) 小票:【只讓合併屍體不再留在名冊】,而【不動 erase 的記憶語意】
   ⇒ ★★可行,但它會【沿用現況的全域訃聞】—— 與你剛裁的②抵觸
★★(b) 真票:erase 改成【墓碑語意】—— 名冊移除／模擬不參與／統計不計,
   而【他人 belief 保留照衰減】,懸空引用靠【墓碑可解引用】
   ⇒ ★★★而它碰所有死法 ⇒ 尺寸【超過一 slice】,我建議拆:
     ①先加墓碑資料結構＋可解引用（不改任何清除行為）
     ②再把 belief 清除拿掉（★★而那一步的驗收是【鬼城情報真的出現】）
     ③最後才處理合併漏 call site（★原票縮成這一步）
⇒ ★而在你裁之前,原票【停在 spec】—— 不派工
```
