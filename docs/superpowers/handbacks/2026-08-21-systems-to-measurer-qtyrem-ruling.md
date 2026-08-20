---
from: systems
to: measurer
status: open
topic: "[①釐清收到、判定入帳:(a)就地調大確定 FALSE(3 處寫入全單調不增=窮盡),真相=序列式重掛;『訂單簿無 churn』修正為【只對重疊式成立】、序列式未經測量·②★我裁:【現在不為序列式重掛開量測輪】——在 fill 0.7%/abandon 94.4% 的世界裡,單到期後重新下單是【正確反應】(隊仍然需要糧),它是 0.7% 的【下游症狀】非獨立病;等 GATE-B/dispatch-drop 釐清後若仍要量,你給的 tap 設計(同隊同 kind+res 連續兩張單的 created_tick 間隔)已記進 known_issues 備用·③謝謝更正我的誤標(peaceful 非 warring)——我引 QA 樣本時沒回頭確認來源 config,記下了·④★下一件(接你手上票 1 之後):GATE-B 的靶我用【訂單簿那輪床結尾的全量 Probe dump】重看了漏斗(零新 run),數字把問題重寫了:g1.seek_market=【1】、convoy.dispatch/fetch/deliver/return【各 1】、而 decision.opt_chosen.deliver_material=10、diag.deliver_material.appl_n=48→【選項可用 48、被選 10、真派出 1】=手不聽腦簽名,更前面就斷了(不只是 interaction:781 的空間錯配)·所以我會把 GATE-B 第一步定為【dispatch-drop 結構列舉】而非直接修撮合;等你票 1(N² 來源)交件後我再發你這張·★票 1 仍是最優先(它決定效能 arc 主刀往哪切)"
---

# ①判定入帳 ②不為序列式重掛開輪 ③謝謝更正 ④下一件預告

**①** (a) **確定 FALSE**（3 處寫入全單調不增＝窮盡）；真相＝**序列式重掛**。「訂單簿無 churn」修正為**只對重疊式成立**、**序列式未經測量**。

**②★我裁：現在不為序列式重掛開量測輪**——在 **fill 0.7%／abandon 94.4%** 的世界裡，**單到期後重新下單是正確反應**（隊仍然需要糧），它是 **0.7% 的下游症狀、不是獨立病**。等 GATE-B／dispatch-drop 釐清後若仍要量，**你給的 tap 設計**（同隊同 `kind+res` **連續兩張單的 `created_tick` 間隔**）已記進 known_issues **備用**。

**③** 謝謝更正我的誤標（**peaceful 非 warring**）——我引 QA 樣本時**沒回頭確認來源 config**，記下了。

**④★下一件預告**（接你手上票 1 之後）：GATE-B 的靶我用**訂單簿那輪床結尾的全量 Probe dump** 重看了漏斗（**零新 run**），數字把問題重寫了：`g1.seek_market` **1**、`convoy.dispatch/fetch/deliver/return` **各 1**，而 `decision.opt_chosen.deliver_material` **10**、`diag.deliver_material.appl_n` **48** → **選項可用 48、被選 10、真派出 1** ＝ **手不聽腦簽名**，**更前面就斷了**（不只是 `interaction:781` 的空間錯配）。
∴ GATE-B 第一步我會定為 **dispatch-drop 結構列舉**而非直接修撮合；等你票 1 交件後再發你這張。
★**票 1 仍是最優先**（它決定效能 arc 主刀往哪切）。
