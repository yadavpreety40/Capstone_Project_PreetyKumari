import json
import os
from google import genai
from google.genai import types

def generate_scr_narrative_offline(findings: dict) -> dict:
    """Task 4: Offline fallback path formatting SCR narrative using f-string template."""
    narrative = f"""### Situation
Total cleaned revenue reached INR {findings['cleaned_total_revenue_inr']:,} across all channels. True peak performance was recorded in March 2026 with INR {findings['true_peak_month']['revenue_inr']:,} in revenue.

### Complication
High return rates are impacting margins. Cash on Delivery (COD) return rate stands at {findings['return_rate_by_payment']['COD']}%. The highest-risk segment is COD orders in Tier-2 cities with a return rate of {findings['highest_risk_segment']['return_rate_pct']}%. Furthermore, double-submit data issues caused a reconciliation delta of INR {findings['duplicate_reconciliation_delta_inr']:,}.

### Resolution
Focus on reducing COD returns in Tier-2 cities using verification checks and apply automated deduplication rules to ensure financial accuracy.
"""
    return {
        "status": "success",
        "narrative": narrative,
        "tokens": None
    }

def generate_scr_narrative(findings: dict) -> dict:
    """Task 2 & 3: GenAI SCR Narrative Generator with Parameter Locking & Error Handling."""
    api_key = os.environ.get("GEMINI_API_KEY")
    
    if not api_key:
        return generate_scr_narrative_offline(findings)

    try:
        client = genai.Client(api_key=api_key)

        system_instruction = (
            "You are a senior data analyst writing for Mamaearth's regional ops and finance heads. "
            "Structure your response into exactly three labeled sections: Situation, Complication, Resolution. "
            "Constraint: Every number in the output must come from the supplied findings and appear with the exact same value. Do not invent or estimate statistics."
        )

        user_prompt = f"Here are the verified data findings from Parts 1 & 2: {json.dumps(findings)}"

        config = types.GenerateContentConfig(
            system_instruction=system_instruction,
            temperature=0.0,
            max_output_tokens=500
        )

        response = client.models.generate_content(
            model='gemini-2.5-flash',
            contents=user_prompt,
            config=config
        )

        return {
            "status": "success",
            "narrative": response.text,
            "tokens": getattr(response, 'usage_metadata', None)
        }

    except Exception as err:
        print(f"API Error encountered: {str(err)}. Falling back to offline path...")
        return generate_scr_narrative_offline(findings)

def check_numeric_accuracy(narrative_text: str) -> bool:
    """Task 5: Asserts all 5 key figures are present as substrings."""
    text_clean = narrative_text.replace(',', '')
    required_figures = [
        ("97358.3", "Cleaned Total Revenue"),
        ("44.4", "COD Return Rate"),
        ("54.5", "COD Tier-2 Return Rate"),
        ("2501.9", "Reconciliation Delta"),
        ("20318.9", "March Peak Revenue")
    ]

    all_passed = True
    for fig, label in required_figures:
        if fig in text_clean:
            print(f"[PASS] {label}: Found {fig}")
        else:
            print(f"[FAIL] {label}: Missing {fig}")
            all_passed = False

    return all_passed

if __name__ == "__main__":
    findings_path = os.path.join("narrator", "findings.json")
    
    if os.path.exists(findings_path):
        with open(findings_path, "r") as f:
            data = json.load(f)

        res = generate_scr_narrative(data)
        print("\n=== GENERATED NARRATIVE ===")
        print(res["narrative"])
        print("\n=== ACCURACY CHECK ===")
        check_numeric_accuracy(res["narrative"])
    else:
        print("Error: narrator/findings.json file not found.")
