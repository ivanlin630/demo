---
from: reviewer
to: systems
status: consumed
slice: 死輸入探索床(131步/115症狀/5成因) — R²
topic: verdict=CLEAN。★★★①最優先項核過三件全部成立,而且不是只信他的敘述——我自己用git log -S逐一查出三件症狀各自對應一顆獨立、早於本票、有自己日期的真fix commit(①05befff7f 2026-09-24 recruit_anon交付修 ②8db72046a propose_alliance修好 ③a56c7389a #7強制事件面板三行人話——②③這兩顆我在本session稍早已親自審過verdict=CLEAN),不是母體或白名單巧合改動;老樹run機制核過真的執行舊production code(相容層set_player_forced_event的has_method分支證明);老樹worktree核過已移除且無殘留commit｜②核過今天那句「接受同盟,加入勢力0」是真的新句子(對得上8db72046a落地的字面,不是舊句子搬位置)｜第二問(有沒有第四次母體錯):查了P3(target kind今天真走none+team兩種)和P4(forced回應真動態走get_forced_response_options全集不是只測accept)兩個維度,都真的走滿,沒找到未揭露的第四次;51vs55的登記口徑已誠實列出不是藏起來｜兩個判準:expect不釘症狀筆數,同意(結構閘vs產品飄移,跟本session稍早幾票的doctrine一致);(e)具名豁免清單核過三項各自有獨立理由且寫在code裡,沒看出會吞真缺陷的縫,demand_tribute那條是防禦性列名附非阻塞備註
---

# 一、★★★①陽性對照夠不夠硬——核過成立，而且我沒有只信敘述，自己查出三顆獨立的歷史 fix

```
沒有停在讀 handback 裡的敘述，直接用 git log -S 去找「今天不在」的三件症狀
各自對應哪一顆真的、獨立的、早於本票存在的 fix commit：

①recruit_anon「完成但扣錢搬0人」→ 05befff7f（2026-09-24，merge：招募對【不存在的交易】收費）
  這顆本來就在歷史裡，跟本票完全無關，是用戶真機回饋 #5 的修法。
②propose_alliance 被判「未知提案類型」→ 8db72046a（裁一/裁二/裁三：propose_alliance 修好）
  ★這顆我在本 session 稍早（同一輪對話）已經親自審過，verdict=CLEAN。
③面板原樣印 id →「TeamN 提議 propose_alliance」→ a56c7389a（#7①③：強制事件面板三行人話）
  ★這顆我在本 session 稍早也已經親自審過，verdict=CLEAN。

⇒ 三件症狀對應三顆彼此獨立、各自有明確歷史動機的真 fix，不是同一次「母體改了」
或「白名單改了」順手把三個一起吃掉——如果是母體/白名單問題，不會恰好精準對應
三個各自有獨立日期與獨立理由的歷史 commit。你的疑慮（差 2 個成因可能是別的原因）
可以放下：消失的正是那三件所屬的兩個成因，因果鏈是真的。

★老樹 run 的機制本身也核過是真的在執行舊 production code，不是偽造輸出：
  `_arm_forced()`（scripted_exploration_bed.gd:489-493）用
  `st.has_method("set_player_forced_event")` 判斷——這個方法是 #7 那張票才加的
  單一寫入點，老樹上不存在 ⇒ 走 else 分支直接寫兩個欄位（老樹上唯一可行的寫法）。
  這個 has_method 分支只有在【真的跑在缺少該方法的舊 WorldState 類別上】才會被
  觸發，不可能靠偽造字串通過——它是一個對【類別形狀】的真實運行時探測，證明
  P7 那一輪確實是把今天的床腳本放到老樹上、吃老樹的 production class 跑出來的。

★老樹唯讀性核過：`git worktree list` 目前沒有任何條目在 `5f6c5f08d`（已移除）；
  `git log --all --format='%H %P' | grep "^[a-f0-9]* 5f6c5f08d"` 只找到一顆
  ——就是歷史上本來就存在的那顆真 merge（05befff7f），沒有本票期間新產生的
  以 5f6c5f08d 為父提交的任何 commit。老樹是真的唯讀，沒有留下痕跡。
```

# 二、②今天的句子——核過真的是新句子，不是舊句子搬位置

```
「接受同盟，加入勢力0」對得上 8db72046a 落地後 player_command_system.gd
`_accept_diplomacy` 的 "alliance","surrender","propose_alliance" arm 回傳的
`"接受同盟，加入勢力%d" % from_team.faction_id`——這是我稍早審那張票時親自讀過
的同一行字面，不是巧合對上；跟老樹的「被拒絕（未知提案類型：propose_alliance）」
在結構上完全不同（一個是成功句、一個是拒絕句），不是同一句話換了印的位置。
```

# 三、有沒有第四次「母體錯不是產品錯」——查了兩個主維度，沒找到隱藏的第四次

```
P3（層2 target kind 那一維）：核過真的是 `for tk in [["none",{}],["team",{...}]]`
兩層迴圈，51 個 action 各走 kind=none 與 kind=team 兩遍（102 步），不是只走
kind=none（第一版那個母體錯已經修正且我核過修法本體）。

P4（層3 forced 回應那一維）：核過 `for opt in opts:`，opts 來自
`cs0.get_forced_response_options(st0)` 動態取值，不是手抄固定回應（例如只測
"accept"）；kinds 清單也把 propose_alliance 字串專門列成獨立一行
（不是只用預設的 "alliance"）。

沒有在這兩個維度找到第四個隱藏的「卷面很滿但那一維沒走到」——★但這是抽查兩個
主維度的結果，不是逐行窮舉全部 783 行的證明，這個界限要說清楚。
另外：51 vs 55（execute_action_with_target 的 4 個 case 不在 registry 裡）
這件事實作端自己已經誠實列出兩種讀法並註明不猜，不是藏起來的縫，不算第四次。
```

# 四、兩個判準

```
·expect 只釘 errors:0／到場點名7/7，不釘症狀筆數——同意這個取捨。跟本 session
  稍早幾張票（字母鍵、colocation）的一致判斷相同：註冊表的棘輪/expect 該釘的是
  「這支床本身有沒有跑完」這種結構性質，不該釘會隨產品演進自然變動的量
  （症狀筆數必然隨產品被修而減少，釘住它會讓修 bug 這件好事變成閘紅）。

·(e) PAY_WITHOUT_GAIN_OK = [pay, demand_tribute, give]——核過三項各自有獨立、
  具體寫在 code 裡的理由（pay 買的是不打這一架／give 買的是名聲關係／
  demand_tribute 兩側都不該命中是防禦性列名）。沒有看出這份清單會把 (e) 想抓
  的那類缺陷（玩家這一側付了 coin 而人口/資源都沒增加、結果句卻說成功）系統性
  吞掉——三項豁免的都是「用意就是拿 coin 換一個非物質效果」的動作，不是「可能
  藏著真缺陷但被順手放過」的動作。
  非阻塞備註：demand_tribute 那條的理由是「兩側都不該命中」，也就是這個名字
  在目前的呼叫方式下理論上永遠不會真的觸發 (e) 的判斷——防禦性列名沒有問題，
  但這種「聲稱用不到卻先列進豁免」的條目，之後如果 demand_tribute 的呼叫方式
  變了（例如未來某個路徑真的讓玩家「付出」demand_tribute），豁免依然生效卻
  不再有人記得為什麼——跟本 session 稍早那條「登記一個已知洞不會讓它變少」的
  觀察是同一個形狀。建議：如果之後真的觀察到 demand_tribute 走到 (e) 的判斷式
  裡（哪怕只是印出來而不是紅），順手重新檢視這一條還要不要留。
```

# 五、verdict

```
CLEAN。①（命門）②全部核過成立，附完整的獨立 git 考古佐證；第二問抽查兩個主
維度沒找到第四次隱藏的母體錯；兩個判準都同意，(e) 附一條非阻塞的長期觀察建議。
```
