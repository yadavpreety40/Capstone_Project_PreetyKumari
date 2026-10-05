# Capstone_Project_PreetyKumari
This is the final Capstone project I worked upon as part of my course
Capstone_Project_PreetyKumari/
├── README.md
├── analysis/
│   ├── clean_and_eda.py
│   └── visualize.py
├── data/
│   ├── customers.csv
│   ├── orders.csv
│   └── products.csv
├── narrator/
│   ├── findings.json
│   ├── generate_narrative.py
│   └── sample_output.txt
├── sql/
│   ├── reports.sql
│   ├── schema.sql
│   └── seed_data.sql
└── visualizations/
    ├── monthly_revenue_trend.png
    └── return_rate_by_payment.png

    
1. SQL Layer (Part 1)
Load the relational schema and seed data into a local SQLite database, then execute the analytical business reports:

Bash
sqlite3 database.db < sql/schema.sql
sqlite3 database.db < sql/seed_data.sql
sqlite3 database.db < sql/reports.sql

2. Python Analysis Layer (Part 2)
Run the data cleaning script, which handles deduplication, missing values, payment casing normalization, and computes verified metrics. Task 5 exports these verified numbers into narrator/findings.json. Then, run the visualization script to generate PNG charts in visualizations/:

Bash
python analysis/clean_and_eda.py
python analysis/visualize.py

3. GenAI Narrative Layer (Part 3)
Run the narrative generator to produce the final executive report and execute automated accuracy verification checks against narrator/findings.json.

Online Path (with Gemini API Key):
Set your API key as an environment variable and run:

Bash
export GEMINI_API_KEY="your_api_key_here"
python narrator/generate_narrative.py
Offline Path (Keyless Fallback):
Run directly without an API key to execute local template-driven generation and accuracy validation:

Bash
python narrator/generate_narrative.py

---

### Key Highlights
* **Task 5 Integration:** `analysis/clean_and_eda.py` automatically writes all cleaned metrics to `narrator/findings.json`[cite: 1].
* **Accuracy Assurance:** `narrator/generate_narrative.py` verifies generated text
