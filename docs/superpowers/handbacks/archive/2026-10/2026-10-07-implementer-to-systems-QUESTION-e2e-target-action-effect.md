---
from: implementer
to: systems
status: consumed
slice: 終端 E2E（架構改版 R² CLEAN 之後動工中）
topic: ★問一題（不停工，其餘照做）：目標動作（鍵位空間 (i)）要不要也填 `effect`？spec §3「只 10 個 listed」與「畫面上出現過的每一個動作都要有 effect，缺⇒紅」在 (i) 上互相矛盾
---

# 實測（worktree `feat/terminal-e2e`，探路腳本，default seed 1337，佈置一支同格 NPC＋強制事件）

```
[T] → [Tab] → [1] Team7320 之後，「─ 動作（9／12 可做，未綁鍵 3）」列出的是**目標動作**：
  [6] 攻擊｜[3] 要求納貢｜[7] 勒索｜[5] 打聽情報｜[9] 邀請定居｜[2] 提議同盟｜[4] 招募｜[8] 招募匿名｜[1] 貿易
  （未綁鍵）乞討／忽略／投降請和
⇒ 它們在 ACTION_SHAPE 全是 `listed: false`、`target: "team"`、**沒有 effect**
```

# 矛盾

```
§3 ①「只有 10 個 listed: true 的動作要填（R² 數過）」
§3 ②「反向掃：畫面上**出現過的**每一個動作，ACTION_SHAPE 都要有 effect ⇒ 缺 ⇒ 紅並指名」
§1 ①(i) 鍵位空間 ＝ action_block 數字鍵 ＝ 就是上面這 9 個
⇒ 照 ② 走 ⇒ 床第一次跑就紅 9 個（不可註冊）；照 ① 走 ⇒ (i) 空間的 P3（紅二）沒有判準
```

# 我的預設（你不回就照這個做，交件時可整段拿掉）

```
(甲) 9 個綁鍵的目標動作也填 effect，同樣逐支開 handler 核寫了什麼（file:line 附表上方）
    ★未綁鍵的 3 個不填（畫面上按不到 ⇒ 不會被走到）
    ★「打聽情報」打開選題子選單、本身不下令（實測：按 [5] tick 不動、鍵列變 [1-5]選題）⇒ effect 仍照 handler 填
⇒ 理由：(i) 是 spec 點名要走的空間；不填就是 P3 在那一半恆不適用（空的綠）
```
