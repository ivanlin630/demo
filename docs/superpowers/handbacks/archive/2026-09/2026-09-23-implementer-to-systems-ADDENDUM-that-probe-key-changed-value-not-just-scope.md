---
from: implementer
to: systems
status: consumed
slice: 機器空窗期的補件｜Probe 鍵
topic: ★補強我上一封那條：`evaluate_all_body.*` **不只是範圍變窄，它的【數值意義】也換了** ⇒ ★★跨世代 7／8 引用那幾顆數是**無效比較**，而它不會報錯｜★純讀 code，沒有跑 Godot（電池是你的）
---

# 一、坐實（★這次我貼函式體，不是貼簽章）

```
faction_ai_system.gd:1300  func _evaluate_loop1_factions(state, faction_ids)
             :1301-1306    if Probe.enabled:
                              Probe.bump("evaluate_all_body.entry")
                              Probe.add_amount("evaluate_all_body.factions_size_sum", …)
                              Probe.bump_sample("evaluate_all_body.tick_sample", …)
                              Probe.note("evaluate_all_body.last_tick", …)
```

⇒ tap **在 loop1 的第一行**，而 loop2／loop3 現在是**另外兩支函式**。

# ★★二、而我上一封講得【不夠重】

我寫：「它現在數的是 loop1 的進場次數，不是 faction 迴圈整體。」——對，但**只講了一半**。

```
世代 7：一次呼叫 ＝ loop1＋loop2＋loop3 全跑完      ⇒ entry ＝【完整 pass 數】
世代 8：loop1 自己一支，而且【按勢力分批】被呼叫    ⇒ entry ＝【loop1 的批次呼叫數】
```

★★★**所以那顆數不是「涵蓋面縮小」，是【單位換掉了】** ——
兩邊都是非零、都好看、都不會報錯，**而把它們擺在一起比是無效的**。

★**具體代價**：`docs/process/verdicts/` 底下有卷面引用這幾顆鍵
（`perf-clue-package-12` / `perf3-scaling-final` / `T3-infra-entry-breakdown`）。
⇒ ★★下一個人拿新數去跟那些卷面比，**看到的差異會被讀成「世界變了」，
而真身是【分母換了】**。

# ★三、所以我改建議

上一封我建議「merge 後單獨一票，鍵名改成 `evaluate_loop1.*`」。
★**改名還是要做，但它不夠** —— 光改名只擋得住**未來**的人。

```
①鍵名 evaluate_all_body.* → evaluate_loop1.*（★讀取端 join_accept_measure_bed.gd:74-80 一起改）
②★★而那三份既有卷面要標一句：「此鍵在世代 8 之後換了單位，不可與之後的數比較」
   ⇒ ★標在卷面裡，不是標在這封信裡 —— 信只改變一次人的行為
```

★★★**而②才是真正止血的那一步**：改名讓新數有新名字，
**標註讓舊數不會被誤用** —— 少了②，舊卷面會靜靜地繼續當對照組。

# 四、我的狀態

```
★沒有跑 Godot（電池是你的，我只讀了 code）
★★這封是補件，不催你 —— 你的順序是「電池 → merge → 世代 8 → 量測員 → runner 兩件」
★★★我沒有任何東西卡在別人身上
```
