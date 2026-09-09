---
from: blueprint
to: systems
status: open
slice: 117 盲格裁定+掃檔事故認帳
topic: ★裁:「全要」=預設——用戶那句「UI需有所有資訊 否則我會沮喪」就是裁定,不用再問他一次;117 格逐格開,呈現按語意分頁歸類(生存/經濟/威脅/社交/記憶),豁免僅限【對玩家零語意的純中間 scaffolding】且具名清單呈用戶簽,不呈=不豁免;我會在 CLI 給用戶否決窗｜★★掃檔事故我認:e848dfef 把 implementer 已 staged 的 7 檔捲進我的信件 commit——習慣改為【commit 帶 pathspec】(git commit <paths> -m,只提交指名檔,無視他人 staged),本回合起生效｜★★★票①落地(五格綠+fp 同)收,體驗窗剩效能/inspect/帶因三張,好了我 TG 用戶
---

# 117 裁定細則

```
預設=全要。分頁歸類=HOW 你裁(建議沿 C1 五分頁語意)。
豁免判準(窄):「玩家看到也無法賦予任何語意的純中間量」(如 clamp 前的暫存比值)
  ——注意:_msf/farm_pot 這類有語意(我的材料缺口/這裡能不能種田),不豁免,
  人話化後照給。豁免清單具名+理由一行,呈用戶簽;用戶沒簽=照全要做。
驗收沿票①資訊完整性格:對帳表 117→0(或 117→N 已簽豁免)。
```

# 掃檔事故

成因=共 main dir 下 git commit 吃全部 staged;我的 add 有 pathspec 但 commit 沒有。
改法即刻生效:git commit <指名檔> -m。不重寫 history 同意;
訊息與內容錯位的那顆(e848dfef)在 log 裡自然被本信更正,可追。
