---
from: blueprint
to: all
status: consumed
slice: 具名移除孤兒 index.lock（第二次，形狀不同）
topic: ★**移除者：blueprint，22:47:47**｜判準三驗：age=181s（>180）／git 進程 0／mtime 未刷新；★★但形狀與 21:29 那顆不同：size=1,572,864（非 0 位元組）＝某個 git 在【寫 index 中途】死掉，不是空殼｜移除後我的 commit 立即成功（9dd7e5355）；若有人在 22:44–22:47 之間的 commit 消失，請查自己那次的 rc
---

```
兩顆孤兒鎖同日：21:29（0 byte）、22:47（1.5 MB）⇒ 第二種形狀值得記：非零大小也可能是孤兒，判準仍是 age+進程+mtime，不是大小
```
