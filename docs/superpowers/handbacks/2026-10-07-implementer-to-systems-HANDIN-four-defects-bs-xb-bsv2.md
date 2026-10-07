---
from: implementer
to: systems
status: consumed
slice: 四個畫面缺陷（D1–D4）＋BS 戰鬥區被看過＋XB 勒索煞車（①′③④＋§2 怨累積）＋BS v2 戰鬥區要能玩
topic: ★**交件｜已知紅 0**｜BATTERY_RC=0｜109 綠／0 紅（run-id `22173-20261007-125410`，HEAD `f4c12820d`）｜branch `feat/battle-asserted-extortion-brake` 遠端 tip **`911502ad5`**（含 merge origin/main 兩顆＋artifact 一顆）｜world-fp b64512c8 → **3bdfeb3a**（XB 改模擬＋指紋多讀兩欄）｜新列 extortion-brake
---

# 一、四個畫面缺陷（E2E 四格修前全紅：D1a 命中 8／D2b 3／D3c 20／20／D4d 22 ⇒ 修後全綠）

```
D1 事件流：來源欄經 WorldEvents.kind_label（全母體 38 個 kind 一份表，E2E 逐一驗都有短名）；沒有對照的 kind 玩家走法不印、debug 印原名
   describe() 的預設支不再把 kind 當句子；結果句資源名改中文（coin→幣、+exp→+經驗、勒索「coin+12」→「幣+12」）；介面句去掉 [Inquiry] 前綴
D2 合成側剝掉沒有寫入者的欄（_page_skylight_fields 宣告式清單，不看值）＋「其他（尚未分頁）」＋「Tick:」頁尾
   ★載體 _state_label 照印 ⇒ ui-flow 讀載體的斷言零遷移；debug 走法原樣（反向格綠）；邊界「已知情報：0 個對象」照印
D3 令結算後結果行換成完成句／被拒句（成功也換）；介面內部令 refresh_targets 不蓋結果行（command_results 帶 name；SimBridge.UI_INTERNAL_COMMANDS 一份表，床同讀）
D4 全域推進鍵 Space／X／G 抽成 _global_advance_key：主畫面推進、面板開著印「面板開著時不能推進（Esc 關閉）」（不改狀態）
   _input 分派前先認全域鍵（面板沒宣告的才轉；物品／勢力的 [G] 照面板語意）；互動面板 A-Z 先認保留字母
   強制回應字母配發跳過 X／G（response_letter_keys() 一份，面板印與 handler 讀同一份）
   ★submode 母體表：t互動／i物品／p成員／f勢力／o前哨／k公庫／u子隊／v顧問 × X／Space／G —— 修前 22 格全是「此鍵無作用」或「現在沒有要回應的事件」
     （i／f 的 G 有列出 ⇒ 面板語意、不判）
已知問題清單加四列並標已修
```

# 二、BS 戰鬥區被看過＋BS v2 戰鬥區要能玩

```
BS1 進戰後 3 拍（待機／移動／待機）每拍：六欄＋戰場＋單位列表＋鍵列＋tick 對齊｜BS3 佈置不同速（體力 1.0 vs 0.0）計時看到 3 種組合
BS2 三種結束：打完「戰鬥結束：你們打贏了」／撤出「你撤出了戰場」／投降「行動：戰中投降：投降被接受」（都回主畫面）
    ★WorldState.last_encounter_outcome：resolve_encounter_end 開頭唯一寫入（一般／野獸／平手三條結算路都經過）
v2 A 局部地圖 TextUiView.render_battle_map（沿用世界地圖格線語彙）；只畫 _player_visible_hexes，其餘「~」霧、場外「#」；@／我方小寫／敵方大寫
     看得到但在半徑 6 外 ⇒「畫面外：a（8 格）」（E2E 實測抓到：自己人在列表有、地圖沒有）
v2 B 目標欄（代號／名字／距離／射程內外／瞄準部位＋本拍打得到的清單）；R＝立刻攻擊目標欄目標（射程外 ⇒「沒有在攻擊範圍內的敵人（目標 B 距離 N 格，射程 M 格）」）
     Tab 循環看得到的敵人；↑↓ 換部位；QWEASD 只移動；attack_select 退場；滑鼠點看得到的敵人＝設目標欄
v2 C 狀態全名（健康／受傷／重傷／斷肢，TeamUiHelper.BODY_STATUS_NAME）；倒數「N 分鐘後行動」（1 tick＝1 分鐘）；單位列表只列看得到的、行首代號
     戰報存 {uN}（EncounterSystem._unit_ref），顯示換「代號（名字）」；我方移動、玩家待機、撤出也記（敵方移動不記：感知鐵律）
v2 D 勒索取整為 0 的那一份印一位小數
E2E v2 五格：V2MAP 3／3／3｜V2TGT｜V2TAB（佈置對方武裝比例 0.5 ⇒ 2 個看得到的敵人）｜V2R 戰報含目標代號｜V2PART 逐字比名表
play.py 真打：tools/play_real_battle.py（import play.py 的 start_server／read_frame，同 play_selfcheck）——追看得到的隊伍、照畫面打
  卷面 docs/measurements/2026-10-07-play-py-real-battle.txt（戰前最後 40 屏＋整場；v2 畫面；R 4 次；結果「戰鬥結束：你們打贏了」）
```

# 三、XB（卷面 docs/measurements/2026-10-07-xb-extortion-measure-before.txt／-after.txt）

```
①′ 嚴重度＝被拿走的 coin 比例；沒拿到＝TRIBUTE_RATE（不讀 readiness）；寫入點唯一 _record_extorted（接受支＋兩份拒絕支）
③ 索貢被拒：DiplomaticAiSystem.record_tribute_refused（NPC↔NPC 與玩家共呼，寫在索貢方、typed）
④ 同格拒絕支：同一對兩次間隔 ≤ 2×T1 ＝ 同一次接觸，只記一筆（TeamData.extort_contact_tick；量測 B 的 #11–13 不再寫）
§2 tributed 尚無 feud 邊 ⇒ 以同一施加者一季內強度總和呼一次 form_feud；已有邊不呼
新床 extortion-brake：P2a k 分佈 [5, 7, 6]（3 對象不同人格）｜P2b 不同施加者各 1 次 ⇒ 累積成怨 0｜P2c 隔一季不累加；正對照同季兩次成怨
spam-brake 理論式納入量到的 feud × TRIBUTE_W_FEUD（XB §2 之後怨會成邊）⇒ 理論 8＝實測 8
```

# 四、負對照（獨立 worktree，各改回一處 ⇒ 只在自己那一格紅）

```
D1 來源欄改回 kind ⇒ D1a｜D2 不剝 ⇒ D2b｜D3 只失敗換 ⇒ D3c（＋BS2 投降那句）｜D4 拿掉分派與保留字母 ⇒ D4d
BS2 end_sentence 改回 "" ⇒ BS2｜戰報不換字 ⇒ 「戰鬥區英文 torso」｜XB§2 改回單筆 ⇒ P2a（k＝-1×3）＋P2c 正對照
v2：R 不攻擊 ⇒ V2R｜Tab 不換 ⇒ V2TAB｜狀態短字 ⇒ V2PART｜地圖不看視野 ⇒ V2MAP（6／3／3）
```

# 五、電池第一輪紅 4（都是本批造成的）⇒ 已修

```
bed-kind：量測床補 @bed-kind: diagnostic
ui-flow P8s：錨改從 _global_advance_key 找 KEY_X（D4 把推進那一行搬進共用函式；主詞不變）
fp-excludes-derived：盲區 31 > 30 ⇒ 指紋讀新欄位（W|enc_outcome、TX|extort_contact，只在非空時另起一行），不調棘輪
spam-brake：見三
```

# 六、要你知道的

```
①★引擎：玩家近戰攻擊沒有距離檢查（resolve_attack 只對遠程 _check_range）⇒ 舊版瞄準模式可以隔 14 格砍人
  ⇒ v2 的 R 只打射程內（ItemAttributes.get_range，近戰 1）⇒ 從畫面已經用不到；引擎那一行沒動（會改 NPC 戰鬥，要你裁）
②索貢被拒的舊格式記憶 {reaction:"tribute_refused"}（寫在被索方）保留：player_trade_system 的交易門檻 memory_mod 在讀它；要不要遷移由你裁
③真跑觀察：玩家隊原地放著 29 天從 10 人餓到 1 人、疲勞 100%（沒有玩家指令時隊伍自己的求生不夠）
④ui_logic_test 的 _test_attack_select_hint 仍測那支 static 提示函式（模式已退場，函式沒刪，免動那支床的到場點名）
⑤票 T 停在 feat/fatigue-by-activity 1495e194e（剩 E2E P1 21／22），本件 merge 後回去接
```
