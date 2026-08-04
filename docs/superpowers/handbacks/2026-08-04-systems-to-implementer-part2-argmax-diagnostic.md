---
from: systems
to: implementer
status: consumed
topic: "[Part2求援argmax-loss確認diagnostic(blueprint①GO first,measure-first別下修結論只交真值,確認root再設計(a)side-action):RE-measure#2揭help/scout/distribute仍全0,推翻dispatch-gate診斷=真blocker在argmax(求援applicable但輸argmax從沒reach dispatch)·假設待證:DESPERATION_DAYS=3 help applicable food<3,SURVIVAL_BOOST_FLOOR=2 boost food<2→窗口[2,3)求援applicable但util≈0.35輸餓隊食物option(覓食/relocate/買糧),food<2 survival-boost 2.5破頂·bed:小pop(2-3)餓resident+有名冊可達領主(help_target解析得到)+food掃過窗口[2,3)及<2·tap逐站:①求援applicable?(can_send_herald=pop≥2 && help_target_id!=-1 && help_need_severity>0各條真值)②求援進rank_scored?③求援util實值④★argmax winner是誰?(求援輸給哪option:覓食/relocate/買糧/其他+各util)⑤food<2時survival-boost後求援util vs winner·⑥blueprint③note順驗:若人工把distress訊塞進領主team_known,distribute會不會fire(證distribute=0下游於herald非獨立第二關)·純觀測tap零行為變,bed復用famine/jia範式(seed1337 honest-carrier)·落地docs/measurements→我讀確認argmax-loss root+distribute依賴→設計(a)·別下修結論只交真值+argmax輸給誰的表"
branch: feat/part2-argmax-diag
---

# Part2 求援 argmax-loss 確認 diagnostic（blueprint ① GO first、measure-first）

RE-measure #2 揭 help/scout/distribute 仍全 0——**推翻 dispatch-gate 診斷（我 round-1 跳步）**，真 blocker 在 **argmax**（求援 applicable 但輸 argmax、從沒 reach dispatch）。**確認再修（(a) side-action）**。

## 假設待證（常數坐實、需 measure 確認）
`DESPERATION_DAYS=3`（help applicable food<3）、`SURVIVAL_BOOST_FLOOR=2`（boost food<2）→ 窗口 [2,3) 求援 applicable 但 util≈0.35 **輸餓隊食物 option**（覓食/relocate/買糧）、food<2 survival-boost 2.5 破頂。

## bed
小 pop（2-3）餓 resident + 有名冊可達領主（`help_target_id` 解析得到）+ food 掃過窗口 [2,3) 及 <2。復用 famine/jia 範式（seed1337、honest-carrier）。

## tap 逐站（★別再跳步、全鏈每步）
1. **求援 applicable?**（`can_send_herald=pop≥2` && `help_target_id!=-1` && `help_need_severity>0` **各條真值**——哪條擋/全過）。
2. **求援進 rank_scored?**（在 scored 候選陣列？）。
3. **求援 util 實值**（食窗口內）。
4. **★argmax winner 是誰?**（求援**輸給哪 option**：覓食/relocate/買糧/其他 + **各 util**——這是核心）。
5. **food<2 時**：survival-boost 後求援 util vs winner（絕境窗確認）。
6. **★blueprint ③ note 順驗**：**若人工把 distress 訊塞進領主 team_known，distribute 會不會 fire?**（證 `distribute=0` 是**下游於 herald**[領主沒聽到→無從賑濟]、非獨立第二關）。

## 交付
- 純觀測 tap（零行為變）。落地 `docs/measurements/` → 我讀**確認 argmax-loss root + distribute 依賴**→ 設計 (a) side-action。
- **★別下修結論、只交真值 + 「argmax 輸給誰」的表 + distribute 依賴驗**。卡 → 報 `to:systems`。
