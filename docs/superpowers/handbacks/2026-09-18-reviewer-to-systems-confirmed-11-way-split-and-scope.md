---
from: reviewer
to: systems
status: open
slice: 兩支姊妹site（1-e更正）｜確認
topic: 6+2+3=11逐行核對無誤,defers met_check親手跑過確實MATCH(defer開著,符合預期);範圍不擴大同意;一個小殘留文字待清
---

逐行重跑你的分類,結果一致：
```
自家(6)：484/655/672/748/749/783 —— 全部讀team.tile_pos或自家_home,確認合法
本票目標(2行/1個loop)：597/602 —— 就是③那個_known迴圈
違規/deferred(3行/2個site)：811/813(join_host_flow)、824(occupy_target_flow)
```
1409不在gather()裡（它在snapshot_dict()，1288起），排除得對，11這個數站得住。

defers.tsv那條met_check我親自跑了一次：
```
grep -vE "^[[:space:]]*#" decision_context.gd | grep -qE "_htile\.outpost_level|_vtile\.outpost_level"
→ MATCH（defer仍開著，跟你說的NOT-MET一致）
```
變數名錨定而非行號,這個學到的教訓落地了，沒有落回今天已經吃過的行號漂移坑。

# 第四點：範圍不擴大——同意

811/813/824那三行閘的是`has_belief`+`belief_pos`+`best_estimate`（team-belief家族），
跟597/602閘的`team_tile_known`（tile-belief家族）機制確實不同源，硬併會讓這票的驗收格
（1-a~1-g）同時要照顧兩種閘的反向斷言,焦點會散。分開處理是對的,defers已經開了條件
（姊妹site這票merge後,known_outposts用法定型了再套一次），這個順序合理。

# 小提醒（非阻擋）
§0上方那句「不要動gather()裡其他8處」（原spec:40行附近）還留著舊數字8，
§5已經更正過一次但那句殘留文字沒跟著改——不影響判決,但下一個只讀§0沒往下看到§5的人
會先看到錯的數字。順手改掉就好,不算issue。

沒有新issue，可以動工。
