---
from: systems
to: reviewer
status: consumed
slice: 批尾小修二 增補段
topic: R²e 只審 M1–M4 對應段（D7 fixture 三種＋修前紅＋:360 巢位＋放手段、E7 累計器實際 delta／不受 Probe／n14、E8 J 頁從 bc 取＋原始 credibility）；S1–S6 已併
---

# 改了哪裡（spec `docs/superpowers/specs/2026-10-17-tail-fixes-2-HOW.md`，本信同 commit）
- **M1**：D7「誰走得到這裡」一段；驗收 D7 改三種 fixture（附身主隊當市集 peer／玩家派出子隊路遇／同勢力主隊路遇），每格修前先紅（≥1 才有效）；n11 三格各自紅。親屬子隊（非玩家派）明寫不算玩家方、照常交易，驗收有反向格。
- **M2**：閘巢在 `:360` TRADE 分支內、`:364-365` 之後 `:366` 之前，寫成字面；明禁放在 `:360` 之前。`:973-984` 放手段二選一（抽出來閘那一支也跑／交件寫達不到＋普查數）。驗收加「玩家子隊與 BEG／JOIN 隊同格修前修後逐字相同」。
- **M3**：四入口各傳實際 delta（逐一點名變數）；不受 `Probe.enabled`；`ui.food_reason.n` >0 配 unmapped＝0；Probe 關下也出句；`remove` 夾位／`set_amt` 對帳 0；n14。三個累計器寫進誠實限。
- **M4**：J 頁管道、可信度、來源隊全從 `bc`（`:96`）取，`source` 欄一起改；兩處都用原始 `credibility`；驗收加「兩筆不同來源、勝出的不是最後一筆」與「幾天後 J 頁與當時事件句一致」。「有疑點」記 known_issues（本 commit）。
- **S1** D7 母體＝四族 reason；**S2** 存糧項 ≥0.5 天才印原因；**S3** distorted 真／假逐字相同＋鍵集合；**S4** 時間預期走「印 N」、禁先寫走不到的分支；**S5** 誠實限寫管道決定大半＋商旅兩側對照；**S6** 另跑一趟有附身隊的 fp 歸因（不換 expect）。

# 另
- 藍圖新票「電腦隊想跟你換跳視窗報價」排小修二後；你 M1 挖到的「非同勢力主隊到不了 :360」我記成那張 HOW 的前提（progress）。D7 段加一句：下一張接在這兩個閘上。

# 交回
VERDICT to:systems，commit，敲 demo-32。CLEAN 後通知實作端（排程不變）。
