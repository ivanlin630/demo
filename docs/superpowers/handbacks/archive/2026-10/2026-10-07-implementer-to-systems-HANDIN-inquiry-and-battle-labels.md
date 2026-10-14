---
from: implementer
to: systems
status: consumed
slice: 打聽：說了什麼就記下什麼（I1／I2／I3／I5）＋終端戰鬥區 §3（戰鬥區中文、名表收成一份）
topic: ★**交件｜已知紅 0**（E2E 剩的打聽兩條清掉）｜BATTERY_RC=0｜108 綠／0 紅（run-id `47271-20261007-084835`，HEAD `08828cf56`）｜branch `feat/inquiry-writes-what-it-says` 遠端 tip **`05cca15a2`**（含一顆 merge origin/main，戰鬥區那幾顆是同一批 sha）｜fp 不變（量的）｜新列 inquiry-writes
---

# 一、改了什麼

```
I1 MessageData.copy_of()（message_data.gd，搬自 message_system._copy_message；那支刪掉）⇒ 三處同呼：
   message_system.gd 兩處（到達交換、打聽交換）＋ inquiry_system.gd 偽造訊息那一行（舊：RefCounted 呼 .duplicate() ⇒ SCRIPT ERROR）
I2 InquirySystem.DISABLED_REASON {"ask_food_source": "對方說的糧源還不會記進你的情報"}
   get_options() 每個選項多 enabled／disabled_reason｜選題清單：不可的印「[n] 標籤（不可：原因）」、按它印原因不下令
   confirm handler：灰掉的題目 ⇒ ok:false＋原因、不呼 resolve_inquiry／_exchange_intel（零寫入、零擲骰）
I3 _exchange_intel 的訊息那段：每複製一則新訊息 written +1（已知的照舊 continue、不算）
I5 confirm handler：mode≠silent、written＝0、payload 非空 ⇒「他說的你早就知道了」（其餘三句不動；不是拒絕字樣）
另：InquirySystem.SELF_KNOWLEDGE_TOPICS ["ask_faction_status"]——handler 的特例分支與 E2E 紅二判準讀同一份
   （E2E 走法換成「第一個可選的題目」之後，選到的是自家勢力狀況 ⇒ 不寫 belief 是設計（spec I4）⇒ 紅二不適用、印出）
```

# 二、驗收

```
P0 探索床 P7[4]（藍圖點名）：關係壓 0.1（不誠實）＋對方一則近期訊息＋擲骰用 seed 控制（找第一個 randf()<0.3 的 seed 重播）
   ⇒ 第一則 is_distorted ＝ true、原訊息不被改｜修前：SCRIPT ERROR「Nonexistent function 'duplicate' in base 'RefCounted (MessageData)'」＋該格紅
P1 新床 inquiry_writes：兩隊同勢力（_decide_exchange_mode ⇒ honest，不靠擲骰）、對方知道兩則你不知道的 ⇒「記下 2 筆」＝真的新增 2 則
   普查床重跑（樹 f347c5720 之後）：SCRIPT ERROR 0｜ask_food_source 88 次全是原因句（普查的分類器不認得這句，歸 n/a）｜
     ask_recent_events told 的 written 有值了（3／6／4／1／22…；修前結構性 0）；47 次歸 n/a ＝「他說的你早就知道了」（分類器同樣不認得新句）
     ★普查那支是量測員的，我沒改它的分類器；它的 jsonl 我跑完還原了（沒動 artifact）
P2 全都知道 ⇒「他說的你早就知道了」、新增 0｜反向：都不知道 ⇒「記下 2 筆」
P3 同 P0（固定 seed 下那一例印出來了）
P4 走 TextUI：t tab 1 →（畫面印的「打聽情報」鍵）⇒ 選題清單「[1] 哪裡有糧食？（不可：對方說的糧源還不會記進你的情報）」
   按 1 ⇒ 結果行印原因｜訊息數 0→0｜記憶頁不變｜世界 tick 不動
P5 E2E：KNOWN 清空 ⇒ errors 0｜已知紅排除 0；expect 改成「…｜已知紅排除: 0（）」
P6 fp：本輪 world-fp ✓、world-fp-ctrl ✓ ⇒ 基準不動（打聽只在玩家下令時跑，fp 床 player_id=-1）
已知問題清單「打聽」那列標已修
```

# 三、負對照（獨立 worktree，各改回一處）

```
I1 改回 .duplicate() ⇒ 探索床 SCRIPT ERROR 1 行＋P7[4] 紅
I3 拿掉訊息那段的 +1 ⇒ P1 紅（句子變成「早就知道了」，對不上真的新增 2 則）
I5 改回「記下 0 筆」⇒ P2 紅
I2 enabled 一律 true ⇒ P4 紅（選題清單沒灰）
```

# 四、要你知道的

```
①E2E 走法現在選到的打聽題是自知題 ⇒ 走法裡沒有一步驗到「打聽寫進 belief」；那一半由 inquiry_writes 的 P1 守
③ui_logic「顯當前部位」原本比英文 torso ⇒ §3 之後提示印「胸」⇒ 改成比中文名且不含原文（08828cf56；第二輪電池就是這一格紅）
②command_replay 的 P13b 原本挑選題清單第一個 ⇒ 現在是灰掉的問糧源 ⇒「那 5 次真的執行成功 0／5」紅
  ⇒ 改成挑第一個**可選**的題目（同一個 branch 一顆 commit，f3494ceab）——第一輪電池就是這一格紅
```

# 五、終端戰鬥區 §3（同一批）

```
a. 中文名表收成一份：TeamUiHelper.BODY_PART_NAME／BODY_STATUS_SHORT／ITEM_NAME（＋part_name／status_name／item_name）
   來源三份：team_ui_helper._body_summary（部位、狀態短字）／text_ui_main ITEM_DISPLAY／_build_inv_str SLOT_NAMES
   ⇒ 部位名六個逐字相同（SLOT_NAMES 多右手／左手兩格）⇒ **三份沒有分歧**
   ⇒ text_ui_main 的 ITEM_DISPLAY 與 SLOT_NAMES 改成指向同一份（別名，讀者不用改）
   ⇒ encounter_view 寫 Label 那幾行換字：主角狀態「頭：健」、裝備「右手：低階近戰武器」、瞄準部位；儲存值一個字不動
   ★狀態用既有的短字（健／傷／重／截）—— 既有表只有這一套，沒有另造長字
b. 終端自驗新走法「戰鬥（攻擊同格隊）」：佈置同格隊、走 PlayerRepl.press_on（t → tab → 1 → 綁定表的攻擊鍵）
   ⇒ (a) 認得戰鬥版面（戰鬥區取代地圖框＋不印動作區）、走法數地板 8 → 9、加一格「真的有一支是戰鬥區」
   ⇒ 負對照（encounter_view 換回修前）：(d) 紅 8 個英文識別字（head／healthy／torso／right_arm／left_arm／right_leg／left_leg／weapon_melee_low）
★順帶看到、沒動：物品面板（_build_inv_str）已裝備那一行印的 grade 仍是原文（例 weapon_melee_low）—— 今天的走法裡沒有裝備所以 (d) 沒咬到
```
