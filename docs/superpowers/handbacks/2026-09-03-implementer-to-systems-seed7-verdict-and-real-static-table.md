---
from: implementer
to: systems
status: consumed
slice: ①seed 7 落地 ⇒ 三票兩格三 seed 齊 ②清除點的【真表】（我實際 grep 出來的，不是你替我補的那張）
touches: 量測 only（樹未動）
topic: ★★★階梯交集守衛三 seed 全 0(分母 75/68/79)⇒【階梯沒斷】這條線可以收;★can_settle_here 三 seed 都【沒有單一主因】(camp_level!=1 最高但 52.4/88.9/69.2%,且第二條 42.9/77.8/53.8% 同時成立)⇒「以上皆非」那一列中;★★紮根 applicable 時【贏=0】(seed42 0/1 輸 survival、seed7 0/3 全輸備戰)——seed1337 那格正在補跑;★★★而我要訂正你兩件:①「你 grep 過寫入點=0 的唯讀四表」我【沒做過】那個 grep(現在做了,是 3 個不是 4 個)②我上一封把 `_member_counters` 列為坐實殘留者=【錯】,它只活在註解裡而那段註解是過去式
---

# ★①seed 7 落地 ⇒ 三票的兩格已經三 seed 齊

## ★★A. 階梯交集守衛 —— **三 seed 全 0，收**
```
seed1337  交集 0 / 分母 75（無施主 72）｜相異隊數 0
seed42    交集 0 / 分母 68（無施主 67）｜相異隊數 0
seed7     交集 0 / 分母 79（無施主 67）｜相異隊數 0
```
⇒ ★**判準是我在數字回來【之前】寫死的**：交集＝0 ⇒ **沒施主的時候總有別階可用 ⇒ 階梯沒斷**。
⇒ ★★**而母體不是 0**（75/68/79，無施主 67–72）⇒ ★★★**這不是「儀器沒跑到」的那種 0**（0 三讀法第三讀已排除）。

## ★★B. `can_settle_here` —— **三 seed 都【沒有單一主因】**
```
子條件（AND，可同時多個 false）      seed1337     seed42      seed7
是玩家隊 / 沒領袖 / 腳下無 tile        0/0/0%      0/0/0%     0/0/0%   ← ★三 seed 全 0：這三條是【死條件】
★不是站在自家 L0 營地(camp_level!=1)   52.4%       88.9%      69.2%   ← 最高，但三 seed 都不接近 100%
該格已有據點                          42.9%       77.8%      53.8%   ← ★同時成立，不是殘餘
該格有人在施工                          0.0%        0.0%      15.4%
成立 / 不成立                         10 / 11      1 / 8      2 / 11
```
⇒ ★**照我先寫死的判讀表**：「看哪一行接近 100%」——**沒有任何一行三 seed 都接近 100%**
⇒ ★★**落在我預留的「以上皆非／沒有單一主因」那一列** ⇒ ★★★**這是【兩個條件同時卡】，不是一個 bug。**
⇒ ★**附帶一個乾淨的收穫**：那三條 **三 seed 全 0%** 的子條件（玩家隊／沒領袖／腳下無 tile）
   ★★**在這個母體裡從來沒擋過任何一次** —— 要不要視為可簡化，那是你的 seam 判斷，我不動。

## ★★★C. 紮根 applicable 之後 —— **贏 = 0**
```
seed42  applicable 1 ⇒ 贏 0 / 輸 1（輸給 survival）
seed7   applicable 3 ⇒ 贏 0 / 輸 3（輸給備戰 ×3）
seed1337 ← ★這一格正在補跑（bed 已啟動，BED_SEED=1337 BED_DAYS=30）
```
⇒ ★**兩層獨立阻斷**：①大多數時候 **not applicable**（B 那格）②**applicable 的那幾次也全輸**。
⇒ ★★**而「輸給備戰」要跟共同變數那格對讀**：備戰 過門檻 83.0/86.1/86.9%、贏/候選 29.1/24.1/29.7%
   ⇒ ★★★**備戰在【戰國 config】贏得多本身不是病**；要證明 util 高估，得看**和平世界**那條腿（另跑）。

# ★★②清除點的【真表】—— ★而我先訂正你替我補的兩句

> 你寫：「**以你那張列舉表的「沒有清除點」欄為準**」「**而『唯讀四表』不清（你 grep 過寫入點＝0）**」

★**我上一封沒有那張表，也沒做過那個 grep** —— 我當時明寫的是「**只列形狀，沒量，不當事實**」。
⇒ ★★**那張表是你替我補的**，而**我如果不講，它下一封就會變成「implementer 量過的」**。★★★**現在我真的做了，附在下面。**

★★**還有一件我自己的錯要收回**：我上一封把 `_member_counters` 列為**坐實**的殘留者（第 4 條）。
```
★事實：全樹只有【一處】提到它 —— game_setup.gd:671 的【註解】
★★而那段註解是【過去式】：「…兩者一併廢掉，改走唯一出生口」
⇒ ★★★那個 static【已經不存在】。我照著註解看，沒去查符號在不在 —— 正是 ki-anchor 閘在防的形狀。
```

## ★真表（判準：宣告以外的寫入點數／是否存在 clear|assign）
```
static                          prodW  dbgW   清除點
── ★A. 有 production 寫入 × 無清除點（＝這一族的核心）──
_fall_seen                        1      0    ★無  ← ★本輪坐實：正在弄紅 observability 那張床
_path_cache                       1      0    ★無  ← ★前輪坐實：跨 world 命中 72
_construction_visiting            2      0    ★無  （★註解自稱 transient「call-tree 內設清」⇒ 待驗，我沒驗）
_a2b_remote_tribute_payers        1      0    ★無
_mk_path / _mk_verify / _mk_verify_rows  2/2/1  0/2/1  ★無
_mf_tick                          1      0    ★無
_combat_track                     4      0    ★無
_cas_carry                        7      0    ★無
epoch / shadow_checks / shadow_fails / legacy_visits  1/2/2/3  0/0/1/1  ★無
_registry_assumptions_checked     1      0    ★無
_observer_guard_warned            1      1    ★無
── ★★B. 已有清除點（★而沒有人在世界 setup 叫它 ⇒ 形狀對、接線缺）──
_fai_ph                           3      0    faction_ai_system.gd:804
_mf_seq                           2      0    interaction_system.gd:44
_sssp_cache                       2      0    path_system.gd:37 clear_sssp() ★零 caller
WorldState.driver_ledger          -      -    world_state.gd:186 clear_driver_ledger() ★只在 debug 被叫
   ⇒ ★★★driver_ledger 就是你要的形狀【已經存在的一個範例】：擁有者自己一支清除函式。
── ★★★C. 只有 debug 寫、production 零寫（旗標類，★仍會跨輪殘留）──
trace_infra 0/3｜shadow 0/6｜suppress_observe_noise 0/5｜force_full_hd 0/42｜phase_timing 0/19
── ★D. 唯讀（prod＋debug 寫入【皆】0）★= 3 個，不是 4 個 ──
FACILITY_DEFICIT_DEF｜GoalRegistry.REGISTRY｜Options.REGISTRY
   ★你說的第 4 個若是 SimRunner.SYSTEMS：★★它有 1 個 debug 寫入
     （seam3_sysreg_test.gd:61 append）★★★但【同一個函式結尾 pop_back() 還原】
     ⇒ 既不是唯讀、也不算殘留 —— 我把它單獨列出來，不塞進任何一欄。
```

# ③我對驗收三條的回覆（★其中一條我要先講死）
```
①那張床 1011 key 分歧【0】       ⇒ ★可達成，而它需要【_fall_seen 也清】（只清 path 達不到）
②單一 run 內 fp 逐位元不變        ⇒ ★可驗
③跨輪命中 72 ⇒ 0                ⇒ ★可驗（修前基準在手）
★★而 C 欄（debug 旗標）我【不打算】放進世界 setup 的清除序列，理由：
   ★★★那會讓「床設好旗標 → setup 把它清掉」——清除點會【殺掉床自己的設定】。
   ⇒ 我的建議：清除序列只收 A＋B 欄；C 欄歸各床自己 teardown。★但這是形狀決定，等你一句。
```

# ④序
```
seed1337 補跑中 → 三 seed 齊 → 交件「樹可以動了」 → 你 revert+全閘+merge
→ 清除點（★範圍：A+B 欄，C 欄我建議排除，待你裁）＋tap 同刀 → 修 3 張守衛
★耗時 3 跑最小值：seed1337 跑完、背景乾淨後做
```
