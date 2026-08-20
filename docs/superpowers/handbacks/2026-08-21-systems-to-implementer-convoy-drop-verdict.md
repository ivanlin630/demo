---
from: systems
to: implementer
status: open
topic: "[convoy drop 列舉驗收=★好活,而且你撿到的比我要的重要·①判讀:六站全零→【我原本要分辨的『世界沒貨(⑤) vs 機制擋住(②④⑥⑦)』兩個假設【都不是】;唯一燒的 ④ throttle 在 peaceful 燒 90% 但【只在那一趟在飛的 day10-15 窗內】=真 binding 但短暫·②★你的時間線才是真故事:day15 後 attempt 凍在 10、throttle 早放開(porter 已不在 TASK_CONVOY)、【領主再也沒選過 deliver】→『90 天只派 1 次』不是被擋、是【一趟賣完就再也不想賣】→靶移到【選項生成/秤價層】,你沒擴大 scope 去追=對(evidence-only 紀律)·③★★你撿到的 RETURN 腿斷比 ④ 更像真身:deliver=1/settled=1 但 return=0、porter 變 pop=1 遊魂子隊漂成 貿易→逃跑→外交;warring return=23/dispatch=51=有時走完→【不是恆斷、是條件性斷】·這條同時踩兩條新法:失敗/完成【沒有收尾反饋】(執行失敗反饋鐵律的『成功收尾』對稱面)+子隊生命週期沒閉環·★我裁:【開一票量它】,但不是現在 fix——先答『貨款/剩貨有沒有回到母隊』(守恆問題,比遊魂本身嚴重)·④tap 去留:★照你建議【④inflight 與 dispatch_attempt 留成常設】(全量暫態可觀測性本來就要求 dispatch chokepoint 有分母),其餘 temp revert;→請開一支【小觀測 slice】只留這兩個 tap+補全閘(fp byte-identical 應成立=純 Probe-gated)、走正常 merge·⑤warring 那段 partial(timeout 砍)【不必重跑】:結論(六站零/上游零漏/④是唯一燒點)在兩 config 一致,補完整 30 天不會改結論——省一輪·⑥★我原本說『opt_chosen 10』是下界你抓得好:solo 路徑貢獻 34、warring 總 58——我引數字時沒查全路徑,記下"
---

# convoy drop 列舉驗收：★好活，**你撿到的比我要的重要**

**①判讀**：六站全零 → **我原本要分辨的兩個假設「世界沒貨（⑤）vs 機制擋住（②④⑥⑦）」都不是**。唯一燒的 ④ throttle 在 peaceful 燒 90%，**但只在那一趟在飛的 day10–15 窗內** ＝ 真 binding 但**短暫**。

**②★你的時間線才是真故事**：day15 後 `attempt` **凍在 10**、throttle 早放開（porter 已不在 `TASK_CONVOY`）、**領主再也沒選過 deliver** → 「90 天只派 1 次」**不是被擋、是「一趟賣完就再也不想賣」** → **靶移到選項生成/秤價層**。**你沒擴大 scope 去追 ＝ 對**（evidence-only 紀律）。

**③★★RETURN 腿斷比 ④ 更像真身**：`deliver=1/settled=1` 但 **`return=0`**、porter 變 **pop=1 遊魂子隊**漂成 貿易→逃跑→外交；warring `return=23/dispatch=51` ＝ **不是恆斷、是條件性斷**。
這條**同時踩兩條新法**：**完成沒有收尾反饋**（執行失敗反饋鐵律的「成功收尾」對稱面）＋**子隊生命週期沒閉環**。
★**我裁：開一票量它**，但**不是現在 fix**——**先答「貨款/剩貨有沒有回到母隊」**（**守恆問題，比遊魂本身嚴重**）。

**④tap 去留**：★照你建議——**`④inflight` 與 `dispatch_attempt` 留成常設**（**全量暫態可觀測性本來就要求 dispatch chokepoint 有分母**），其餘 temp revert。
→ 請開一支**小觀測 slice**：只留這兩個 tap + **補全閘**（**fp byte-identical 應成立** ＝ 純 Probe-gated），走正常 merge。

**⑤warring partial 不必重跑**：結論（六站零／上游零漏／④是唯一燒點）**兩 config 一致**，補完整 30 天**不會改結論**——**省一輪**。

**⑥** 我原本說「`opt_chosen` 10」是下界，**你抓得好**：solo 路徑貢獻 34、warring 總 58——**我引數字時沒查全路徑**，記下。
