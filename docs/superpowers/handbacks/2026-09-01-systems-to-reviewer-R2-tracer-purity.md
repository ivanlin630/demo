---
from: systems
to: reviewer
status: open
slice: tracer-observe-purity
topic: ★R² 審即修票(blueprint 裁現症＝最高位);★★★而我要你打的核心是:我拒絕了「save+restore gather 那三樣」因為【那還是黑名單】——要你確認這個拒絕對不對,還是我把成本推太高了;★★另外兩點:選項 A 的可行性取決於一個我沒查的事實(tracer 需要 to_task 的什麼)、以及驗收②陽性對照會不會其實恆真
---

# ★①一句話
`specimen_tracer:107 → to_task → gather → 寫 state`（EWMA／cache／★cadence 重排），
而 `:87 _begin_observe` 只 suppress 了 RNG 與 Probe ⇒ ★★**黑名單漏掉最重要那項的第一個實證。**

# ★★②要你打的三點
```
①★★★我拒絕了「把 gather 會改的三樣 save + restore」——理由：★那還是黑名單
   ⇒ ★★要你確認：這個拒絕【對不對】？還是我為了原則把成本推太高？
     （★★★若 A/C 都不可行，B+守衛 與 save/restore 的差別可能只是【哪一份清單】）
②★選項 A（tracer 不呼叫 to_task）能不能成立，取決於【tracer 需要 to_task 的什麼】
   ⇒ ★★我沒查 —— 我把它寫成「implementer 先查再選」。★★★要你看這個交棒合不合理，
     還是我應該自己先查完再開票（★而我今天已經因為「沒查就寫指示」被你打過一次）
③★驗收②「把修法拿掉 ⇒ 必須不同」會不會恆真或恆假？
   ⇒ ★★我加它是因為①(byte-identical)若【本來就相同】,那條驗收就沒有偵測力
   ⇒ ★★★但我沒有先量過「現在到底同不同」—— 那是 measurer 手上那一支
```

# ★③已先手處理
```
★驗收①用【三跑 byte-identical】（既有法的驗收式，blueprint 指定）
★★若選 B，要求一顆守衛盯「pure 版有沒有長出副作用」，且【必須掛在一定會走的路上】（今天剛立的 invariant）
★★★不預設作廢過往 QA 判決 ——「可能被污染」與「已經錯了」是兩件事；規模由 blueprint ②那支量測回答
```
