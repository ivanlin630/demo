# ③ audit seed1337 — 各指標團初始屬性/個性(tick10 首錄)

## 8 指標團(specimen trace,strided team_id)

### team 0  (tick10, faction f0)
- 狀態: pop=9 存糧effective_food=1300 私糧=500 倉糧=800 coin=50 物資material=50 日耗consume=7.2 rung(階)=0
- 領袖個性 leader_traits: food_sec_target=4.8 , 好戰=0.37 , 慎重=0.62 , 求生欲=0.5 , 貪婪=0.55 , 野心=0.42
- 初始 intent: ""
- 初始決策候選 candidates: []
- 初始 threat: {}

### team 6  (tick10, faction f1)
- 狀態: pop=10 存糧effective_food=250 私糧=250 倉糧=0 coin=15 物資material=30 日耗consume=8 rung(階)=0
- 領袖個性 leader_traits: food_sec_target=4 , 好戰=0.6 , 慎重=0.62 , 求生欲=0.42 , 貪婪=0.36 , 野心=0.62
- 初始 intent: "日常"
- 初始決策候選 candidates: [{"nd": false, "opt": "建設", "util": 0.102943915485499}]
- 初始 threat: {"threat_id": -1, "threat_pos": [-1, -1], "threat_react": 0}

### team 12  (tick10, faction f3)
- 狀態: pop=8 存糧effective_food=1300 私糧=500 倉糧=800 coin=50 物資material=50 日耗consume=6.4 rung(階)=0
- 領袖個性 leader_traits: food_sec_target=5.2 , 好戰=0.05 , 慎重=0.4 , 求生欲=0.95 , 貪婪=0.5 , 野心=0.11
- 初始 intent: ""
- 初始決策候選 candidates: []
- 初始 threat: {}

### team 18  (tick10, faction f4)
- 狀態: pop=10 存糧effective_food=250 私糧=250 倉糧=0 coin=15 物資material=30 日耗consume=8 rung(階)=0
- 領袖個性 leader_traits: food_sec_target=5.7 , 好戰=0.13 , 慎重=0.46 , 求生欲=0.89 , 貪婪=0.53 , 野心=0.03
- 初始 intent: "日常"
- 初始決策候選 candidates: [{"nd": false, "opt": "建設", "util": 0.0672773131592725}]
- 初始 threat: {"threat_id": -1, "threat_pos": [-1, -1], "threat_react": 0}

### team 24  (tick10, faction f5)
- 狀態: pop=8 存糧effective_food=250 私糧=250 倉糧=0 coin=15 物資material=30 日耗consume=6.4 rung(階)=0
- 領袖個性 leader_traits: food_sec_target=4.6 , 好戰=0.43 , 慎重=0.53 , 求生欲=0.55 , 貪婪=0.39 , 野心=0.37
- 初始 intent: "日常"
- 初始決策候選 candidates: [{"nd": false, "opt": "建設", "util": 0.0949037863198164}]
- 初始 threat: {"threat_id": -1, "threat_pos": [-1, -1], "threat_react": 0}

### team 30  (tick10, faction f7)
- 狀態: pop=10 存糧effective_food=250 私糧=250 倉糧=0 coin=15 物資material=30 日耗consume=8 rung(階)=0
- 領袖個性 leader_traits: food_sec_target=5.2 , 好戰=0.51 , 慎重=0.65 , 求生欲=0.62 , 貪婪=0.39 , 野心=0.35
- 初始 intent: "日常"
- 初始決策候選 candidates: [{"nd": false, "opt": "覓食", "util": 0.365004621446133}, {"nd": false, "opt": "建設", "util": 0.0885271076621072}]
- 初始 threat: {"threat_id": -1, "threat_pos": [-1, -1], "threat_react": 0}

### team 36  (tick10, faction f-1)
- 狀態: pop=9 存糧effective_food=1120 私糧=320 倉糧=800 coin=20 物資material=60 日耗consume=7.2 rung(階)=0
- 領袖個性 leader_traits: food_sec_target=4.9 , 好戰=0.02 , 慎重=0.36 , 求生欲=0.89 , 貪婪=0.46 , 野心=0.15
- 初始 intent: {"intent": "致富", "mode": "trade", "why": "貪婪驅動，treasury 增"}
- 初始決策候選 candidates: [{"nd": false, "opt": "覓食", "util": 0.406824740022421}, {"nd": false, "opt": "囤貨", "util": 0.296883557859217}, {"nd": false, "opt": "駐守", "util": 0.141157735842109}, {"nd": false, "opt": "建設", "util": 0.0605303480902018}]
- 初始 threat: {"threat_id": -1, "threat_pos": [-1, -1], "threat_react": 0}

### team 42  (tick10, faction f-1)
- 狀態: pop=10 存糧effective_food=180 私糧=180 倉糧=0 coin=8 物資material=0 日耗consume=8 rung(階)=0
- 領袖個性 leader_traits: food_sec_target=3.4 , 好戰=0.57 , 慎重=0.46 , 求生欲=0.64 , 貪婪=0.63 , 野心=0.62
- 初始 intent: {"intent": "致富", "mode": "trade", "why": "貪婪驅動，treasury 增"}
- 初始決策候選 candidates: [{"nd": false, "opt": "囤貨", "util": 0.435249199460857}, {"nd": false, "opt": "建設", "util": 0.0937876910138418}]
- 初始 threat: {"threat_id": -1, "threat_pos": [-1, -1], "threat_react": 0}

## 8 勢力領袖(json leader_diag,月1)——立國 gate 相關

| 勢力 | 統領cmd | 野心 | readiness | 領隊pop | 轄隊數 | 過立國門檻 |
|---|---|---|---|---|---|---|
| f0 | 0.101 | 0.422 | 1.00 | 6 | 9 | ✗ |
| f1 | 0.289 | 0.500 | 1.00 | 4 | 9 | ✗ |
| f2 | 0.334 | 0.083 | 1.00 | 8 | 3 | ✗ |
| f3 | 0.335 | 0.113 | 1.00 | 6 | 7 | ✗ |
| f4 | 0.139 | 0.570 | 1.00 | 8 | 8 | ✗ |
| f5 | 0.174 | 0.086 | 1.00 | 7 | 6 | ✗ |
| f6 | 0.170 | 0.535 | 1.00 | 5 | 4 | ✗ |
| f7 | 0.221 | 0.496 | 1.00 | 1 | 8 | ✗ |