# HOW spec（★R² CLEAN 2026-09-05）— **新鮮度洗白：一個欄位的新鮮度不該被別的欄位背書**

## §1 病灶（★file:line，已量過）
```
★vision_system.gd:111  snap = BeliefSystem.best_estimate(obs, tgt).duplicate()
   然後【只覆寫真的看到的】:population_est／tile_pos／last_tick／tags_seen／activity
⇒ ★★其餘欄位【原樣帶走】,而 `last_tick` 【被刷新】
⇒ ★★★一個欄位的新鮮度,被【另一個欄位的觀察】背書 ⇒ BELIEF_STALE_TICKS 對那些欄位【失效】
★而它【不是】god-view 違憲(帶走的是觀察者自己的舊信念,不是真值)——★已判過
```

## §2 兩種形狀（★R² 同意此分析）
```
★A【逐欄位時戳】:每個欄位帶自己的時戳
★★B【只帶真的觀察到的欄位】:★★★【會毀掉資訊】——只看到位置的目擊會把資源估計【清空】
   ⇒ 而 B 的合理版本(逐欄位保留舊值＋各自時戳)【等於 A】
⇒ ★所以這是【A 或 A 的偽裝】,不是兩個選項
```

## §3 ★★★定案（R² 判）：**A，且【只做 `tile_pos`】，不一次做完**
```
★★R² 的理由(讀 code,不是偏好):
   vision_system.gd:142-157 一次觀察【鎖步寫入】六欄:
      population_est／tile_pos／last_tick／tags_seen／activity／in_combat
   而 belief_system.gd:388-399 `appearance()` 讀的【正是這組鎖步欄位】
   ⇒ ★它們共用 last_tick 在語意上【沒有借新鮮度】——本來就同時刷新
★★真正同病(條件寫入、不鎖步)的是: resource_scale(:177) ／ combat_target_est(:163)
   ⇒ ★★★而【目前沒有任何讀取端檢查這兩個的新鮮度】
      (全部三個 BELIEF_STALE_TICKS 讀取點 :135／:140／:393 ＋ faction_ai_system.gd:356 都不看它們)
⇒ ★先做 tile_pos【不會漏掉一個現在有人在讀的洞】;一次做完 = 先蓋機制還沒人用
```

## §4 ★★「兩種時戳並存」的機械緩解（★R² 要求：不能只是接受風險）
| # | 要求 | 為什麼 |
|---|---|---|
| 1 | ★**新欄位命名＝`tile_pos_tick`**（把**欄位名焊進時戳名**）；**禁**用 `observed_tick` 這種泛用字 | 泛用名會被下一個人誤認成「也能拿來判別的欄位」 |
| 2 | ★★**四個既有讀取點各補一行註記**：`belief_system.gd:135`／`:140`／`:393`／`faction_ai_system.gd:356` —— 明寫「此處 `last_tick` 管的是本 entry 的**鎖步欄位**（population／tags／activity／in_combat），**不管 `tile_pos`**；`tile_pos` 的新鮮度查 `tile_pos_tick`」 | ★★★下一個要加「XX 欄位新鮮度」的人，會在**他一定會看到的地方**撞到提醒，而不是憑直覺抓 `last_tick` |
| 3 | ★`resource_scale`／`combat_target_est` 寫進 §5 具名 | 不讓它變成沒寫下來的坑 |

## §5 驗收
| # | 判準 |
|---|---|
| 1 | ★**帶過來而未觀察的欄位，其時戳【不被刷新】**（★★逐筆貼一例：只看到位置的目擊，`tile_pos_tick` 動而其他不動 / 反之） |
| 2 | ★★`belief_pos` 的過期判斷改讀 `tile_pos_tick`。★★★**要印【多少次 belief 因此變成「過期」】** —— 那是預期內的，**但它會讓某些數字【變差】，而我要它【被看見】而不是被解釋掉** |
| 3 | ★★★**JOIN 的 `true<belief` 下降**（現況 39/55）／**徵收「無目標」下降**（現況 86%）——★不要求歸零 |
| 4 | determinism 三跑一致（`fp` 會變）＋ 憲法閘 ＋ 17 支 |
| 5 | ★**零新死常數**：不新增 STALE 門檻（★★沿用既有 `BELIEF_STALE_TICKS`） |
| 6 | ★§4 三項機械緩解逐條做到（命名／四處註記／§5 具名） |

## §6 不在範圍
```
★①`resource_scale`(vision_system.gd:177) ／ `combat_target_est`(:163)
   ⇒ ★★【跟 tile_pos 是同一種病】(條件寫入、頂著新 last_tick)
   ⇒ ★★★未修的理由是【目前無讀取端消費它們的新鮮度】,【不是遺漏】
      —— 等有讀取端出現時,要記得比照 tile_pos 處理
★②其餘鎖步欄位:★不是病(它們與 last_tick 同時刷新,語意正確)
★③`BELIEF_STALE_TICKS` 的數值(★不動)
★④感知鐵律本體
```
