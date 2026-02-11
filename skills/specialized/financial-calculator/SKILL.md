---
name: financial-calculator
description: Advanced financial calculations skill for ROI analysis, budget planning, financial projections, investment analysis, and business financial modeling. Supports NPV, IRR, payback period, and cash flow analysis.
license: MIT
source: Community aggregation (Python cashflows library, financial calculators)
version: 1.0.0
last_updated: 2026-02-09
supports_subagent: true
environment_variables:
  - name: DEFAULT_CURRENCY
    description: Default currency for calculations
    required: false
    default: USD
  - name: DEFAULT_TAX_RATE
    description: Default tax rate for calculations (decimal)
    required: false
    default: "0.21"
---

# Financial Calculator Skill

## Overview

This skill provides comprehensive financial calculation capabilities for business operations:
- ROI (Return on Investment) calculations
- Budget planning and variance analysis
- Financial projections and forecasting
- NPV (Net Present Value) and IRR (Internal Rate of Return)
- Payback period analysis
- Cash flow modeling
- Investment analysis
- Break-even analysis
- Loan and mortgage calculations

## Installation

### 1. Install Dependencies

```bash
# Python financial libraries
pip install numpy pandas numpy-financial

# Optional: Excel export
pip install openpyxl

# Optional: Visualization
pip install matplotlib seaborn
```

### 2. Create Financial Models Directory

```bash
mkdir -p ~/.openclaw/data/financial-models
```

## Key Features

### ROI Analysis
- Calculate return on investment
- Compare multiple investment options
- Risk-adjusted returns
- Time-weighted returns

### Budget Planning
- Create annual budgets
- Track actual vs. planned spending
- Variance analysis
- Department/category breakdowns

### Financial Projections
- Revenue forecasting
- Expense projections
- Cash flow predictions
- Scenario modeling (best/worst/likely)

### Investment Analysis
- NPV calculations
- IRR determination
- Payback period
- Profitability index

### Cash Flow Modeling
- Operating cash flow
- Free cash flow
- Discounted cash flow (DCF)
- Cash flow statements

## Usage Examples

### Calculate ROI

```python
def calculate_roi(initial_investment, final_value, time_period_years=None):
    """
    Calculate Return on Investment.
    
    Args:
        initial_investment: Initial investment amount
        final_value: Final value of investment
        time_period_years: Optional time period for annualized ROI
    
    Returns:
        dict with roi, profit, and annualized_roi (if time_period provided)
    """
    profit = final_value - initial_investment
    roi = (profit / initial_investment) * 100
    
    result = {
        "initial_investment": initial_investment,
        "final_value": final_value,
        "profit": profit,
        "roi_percent": round(roi, 2)
    }
    
    if time_period_years:
        annualized_roi = ((final_value / initial_investment) ** (1/time_period_years) - 1) * 100
        result["annualized_roi_percent"] = round(annualized_roi, 2)
        result["time_period_years"] = time_period_years
    
    return result

# Example usage
investment_result = calculate_roi(
    initial_investment=10000,
    final_value=15000,
    time_period_years=2
)
print(f"ROI: {investment_result['roi_percent']}%")
print(f"Annualized ROI: {investment_result['annualized_roi_percent']}%")
```

### NPV (Net Present Value) Calculation

```python
import numpy_financial as npf

def calculate_npv(discount_rate, cash_flows):
    """
    Calculate Net Present Value.
    
    Args:
        discount_rate: Discount rate (e.g., 0.10 for 10%)
        cash_flows: List of cash flows, first element is initial investment (negative)
    
    Returns:
        NPV value
    """
    npv = npf.npv(discount_rate, cash_flows)
    return round(npv, 2)

# Example usage
cash_flows = [-100000, 30000, 35000, 40000, 45000]  # Initial investment + 4 years returns
discount_rate = 0.10  # 10% discount rate

npv_result = calculate_npv(discount_rate, cash_flows)
print(f"NPV: ${npv_result:,.2f}")

if npv_result > 0:
    print("Investment is profitable at this discount rate")
else:
    print("Investment is not profitable at this discount rate")
```

### IRR (Internal Rate of Return) Calculation

```python
def calculate_irr(cash_flows):
    """
    Calculate Internal Rate of Return.
    
    Args:
        cash_flows: List of cash flows, first element is initial investment (negative)
    
    Returns:
        IRR as a percentage
    """
    irr = npf.irr(cash_flows)
    return round(irr * 100, 2)

# Example usage
cash_flows = [-100000, 30000, 35000, 40000, 45000]
irr_result = calculate_irr(cash_flows)
print(f"IRR: {irr_result}%")
```

### Payback Period Calculation

```python
def calculate_payback_period(initial_investment, annual_cash_flows):
    """
    Calculate payback period for an investment.
    
    Args:
        initial_investment: Initial investment (positive number)
        annual_cash_flows: List of annual cash flows
    
    Returns:
        Payback period in years (float)
    """
    cumulative_cash_flow = 0
    
    for year, cash_flow in enumerate(annual_cash_flows, start=1):
        cumulative_cash_flow += cash_flow
        
        if cumulative_cash_flow >= initial_investment:
            # Calculate fractional year
            previous_cumulative = cumulative_cash_flow - cash_flow
            remaining = initial_investment - previous_cumulative
            fraction = remaining / cash_flow
            
            return round(year - 1 + fraction, 2)
    
    return None  # Investment not recovered

# Example usage
initial_investment = 100000
annual_cash_flows = [30000, 35000, 40000, 45000]

payback = calculate_payback_period(initial_investment, annual_cash_flows)
if payback:
    print(f"Payback period: {payback} years")
else:
    print("Investment not recovered within the projection period")
```

### Budget Planning and Variance Analysis

```python
import pandas as pd

def create_budget_analysis(budget_data, actual_data):
    """
    Create budget vs actual variance analysis.
    
    Args:
        budget_data: Dict of {category: budgeted_amount}
        actual_data: Dict of {category: actual_amount}
    
    Returns:
        DataFrame with variance analysis
    """
    df = pd.DataFrame({
        'Budget': pd.Series(budget_data),
        'Actual': pd.Series(actual_data)
    })
    
    df['Variance'] = df['Actual'] - df['Budget']
    df['Variance %'] = (df['Variance'] / df['Budget'] * 100).round(2)
    df['Status'] = df['Variance'].apply(
        lambda x: '🟢 Under Budget' if x < 0 else '🔴 Over Budget' if x > 0 else '✅ On Budget'
    )
    
    return df

# Example usage
budget = {
    'Salaries': 120000,
    'Marketing': 30000,
    'Operations': 50000,
    'Technology': 40000,
    'Travel': 15000
}

actual = {
    'Salaries': 125000,
    'Marketing': 28000,
    'Operations': 52000,
    'Technology': 38000,
    'Travel': 12000
}

analysis = create_budget_analysis(budget, actual)
print(analysis)
print(f"\nTotal Budget: ${sum(budget.values()):,.2f}")
print(f"Total Actual: ${sum(actual.values()):,.2f}")
print(f"Total Variance: ${sum(actual.values()) - sum(budget.values()):,.2f}")
```

### Financial Projections

```python
def create_financial_projection(starting_revenue, growth_rate, years, cogs_percent=0.40, opex_percent=0.30):
    """
    Create multi-year financial projections.
    
    Args:
        starting_revenue: Year 1 revenue
        growth_rate: Annual growth rate (e.g., 0.15 for 15%)
        years: Number of years to project
        cogs_percent: Cost of goods sold as % of revenue
        opex_percent: Operating expenses as % of revenue
    
    Returns:
        DataFrame with projections
    """
    projections = []
    
    for year in range(1, years + 1):
        revenue = starting_revenue * ((1 + growth_rate) ** (year - 1))
        cogs = revenue * cogs_percent
        gross_profit = revenue - cogs
        opex = revenue * opex_percent
        ebitda = gross_profit - opex
        
        projections.append({
            'Year': year,
            'Revenue': round(revenue, 2),
            'COGS': round(cogs, 2),
            'Gross Profit': round(gross_profit, 2),
            'Gross Margin %': round((gross_profit / revenue) * 100, 1),
            'OpEx': round(opex, 2),
            'EBITDA': round(ebitda, 2),
            'EBITDA Margin %': round((ebitda / revenue) * 100, 1)
        })
    
    return pd.DataFrame(projections)

# Example usage
projections = create_financial_projection(
    starting_revenue=1000000,
    growth_rate=0.20,  # 20% annual growth
    years=5,
    cogs_percent=0.35,
    opex_percent=0.25
)

print(projections.to_string(index=False))
```

### Break-Even Analysis

```python
def calculate_break_even(fixed_costs, price_per_unit, variable_cost_per_unit):
    """
    Calculate break-even point.
    
    Args:
        fixed_costs: Total fixed costs
        price_per_unit: Selling price per unit
        variable_cost_per_unit: Variable cost per unit
    
    Returns:
        Dict with break-even units and revenue
    """
    contribution_margin = price_per_unit - variable_cost_per_unit
    contribution_margin_ratio = contribution_margin / price_per_unit
    
    break_even_units = fixed_costs / contribution_margin
    break_even_revenue = break_even_units * price_per_unit
    
    return {
        'break_even_units': round(break_even_units, 2),
        'break_even_revenue': round(break_even_revenue, 2),
        'contribution_margin': round(contribution_margin, 2),
        'contribution_margin_ratio': round(contribution_margin_ratio * 100, 2)
    }

# Example usage
result = calculate_break_even(
    fixed_costs=50000,
    price_per_unit=100,
    variable_cost_per_unit=60
)

print(f"Break-even units: {result['break_even_units']:,.0f}")
print(f"Break-even revenue: ${result['break_even_revenue']:,.2f}")
print(f"Contribution margin: ${result['contribution_margin']:.2f} per unit")
```

### Loan/Mortgage Calculator

```python
def calculate_loan_payment(principal, annual_rate, years):
    """
    Calculate monthly loan payment.
    
    Args:
        principal: Loan amount
        annual_rate: Annual interest rate (e.g., 0.05 for 5%)
        years: Loan term in years
    
    Returns:
        Dict with payment details
    """
    monthly_rate = annual_rate / 12
    num_payments = years * 12
    
    if monthly_rate == 0:
        monthly_payment = principal / num_payments
    else:
        monthly_payment = principal * (monthly_rate * (1 + monthly_rate)**num_payments) / \
                         ((1 + monthly_rate)**num_payments - 1)
    
    total_paid = monthly_payment * num_payments
    total_interest = total_paid - principal
    
    return {
        'monthly_payment': round(monthly_payment, 2),
        'total_payments': num_payments,
        'total_paid': round(total_paid, 2),
        'total_interest': round(total_interest, 2),
        'interest_percent_of_principal': round((total_interest / principal) * 100, 2)
    }

# Example usage
loan_details = calculate_loan_payment(
    principal=250000,
    annual_rate=0.045,  # 4.5%
    years=30
)

print(f"Monthly payment: ${loan_details['monthly_payment']:,.2f}")
print(f"Total interest: ${loan_details['total_interest']:,.2f}")
```

### Scenario Analysis

```python
def scenario_analysis(base_case, scenarios):
    """
    Perform scenario analysis on financial projections.
    
    Args:
        base_case: Base case assumptions dict
        scenarios: List of scenario dicts with name and adjustments
    
    Returns:
        DataFrame comparing scenarios
    """
    results = []
    
    # Calculate base case
    base_result = calculate_scenario(base_case)
    base_result['Scenario'] = 'Base Case'
    results.append(base_result)
    
    # Calculate alternative scenarios
    for scenario in scenarios:
        scenario_assumptions = {**base_case, **scenario['adjustments']}
        scenario_result = calculate_scenario(scenario_assumptions)
        scenario_result['Scenario'] = scenario['name']
        results.append(scenario_result)
    
    return pd.DataFrame(results)

def calculate_scenario(assumptions):
    """Helper function to calculate scenario results."""
    revenue = assumptions['revenue']
    growth = assumptions['growth_rate']
    margin = assumptions['margin']
    
    year_1_profit = revenue * margin
    year_3_revenue = revenue * ((1 + growth) ** 2)
    year_3_profit = year_3_revenue * margin
    
    return {
        'Year 1 Revenue': revenue,
        'Year 1 Profit': year_1_profit,
        'Year 3 Revenue': year_3_revenue,
        'Year 3 Profit': year_3_profit,
        'Growth Rate': growth * 100,
        'Margin %': margin * 100
    }

# Example usage
base = {
    'revenue': 1000000,
    'growth_rate': 0.15,
    'margin': 0.20
}

scenarios = [
    {
        'name': 'Best Case',
        'adjustments': {'growth_rate': 0.25, 'margin': 0.25}
    },
    {
        'name': 'Worst Case',
        'adjustments': {'growth_rate': 0.05, 'margin': 0.15}
    }
]

comparison = scenario_analysis(base, scenarios)
print(comparison)
```

## Sub-Agent Execution Support

**YES** - This skill strongly supports sub-agent execution:

### Multi-Agent Financial Analysis

1. **Data Collection Agent**: Gathers financial data from sources
2. **Calculation Agent**: Performs complex calculations
3. **Analysis Agent**: Interprets results and provides insights
4. **Reporting Agent**: Generates formatted reports
5. **Scenario Agent**: Runs what-if analyses

### Example Multi-Agent Workflow

```python
# Agent 1: Data Collection
financial_data = data_agent.collect_from_sources(
    sources=['quickbooks', 'bank_statements', 'invoices']
)

# Agent 2: ROI Calculation
roi_results = calculation_agent.calculate_roi(financial_data)

# Agent 3: Budget Analysis
budget_variance = analysis_agent.analyze_budget(
    budget=planned_budget,
    actual=financial_data['actual_spending']
)

# Agent 4: Projections
projections = forecasting_agent.create_projections(
    historical_data=financial_data,
    growth_assumptions={'conservative': 0.10, 'aggressive': 0.25}
)

# Agent 5: Report Generation
report = reporting_agent.generate_financial_report(
    roi=roi_results,
    budget=budget_variance,
    projections=projections,
    format='pdf'
)
```

## Configuration

### Environment Variables

```bash
# Optional configuration
export DEFAULT_CURRENCY=USD
export DEFAULT_TAX_RATE=0.21
export DEFAULT_DISCOUNT_RATE=0.10
export FINANCIAL_DATA_DIR=~/.openclaw/data/financial-models
```

### OpenClaw Configuration

Add to `~/.openclaw/skills/financial-calculator/config.json`:

```json
{
  "name": "financial-calculator",
  "enabled": true,
  "defaults": {
    "currency": "USD",
    "tax_rate": 0.21,
    "discount_rate": 0.10,
    "fiscal_year_start": "01-01"
  },
  "integrations": {
    "quickbooks": {
      "enabled": false,
      "api_key": null
    },
    "stripe": {
      "enabled": false,
      "api_key": null
    }
  },
  "reporting": {
    "default_format": "xlsx",
    "auto_save": true,
    "save_directory": "~/.openclaw/data/financial-models"
  }
}
```

## Best Practices

1. **Use Consistent Time Periods**: Annual, quarterly, or monthly
2. **Document Assumptions**: Record all assumptions for calculations
3. **Scenario Planning**: Always include best/worst/likely cases
4. **Regular Updates**: Update projections with actuals quarterly
5. **Sensitivity Analysis**: Test key assumptions
6. **Peer Review**: Have financial calculations reviewed
7. **Archive Results**: Save historical calculations for reference

## Security Considerations

- Store financial data locally (avoid cloud storage)
- Encrypt sensitive financial information
- Use environment variables for API keys
- Limit access to financial reports
- Audit trail for all calculations

## Performance Considerations

- NumPy vectorization for large datasets
- Pandas for efficient data manipulation
- Cache repeated calculations
- Use generators for large cash flow series

## Troubleshooting

### Calculation Errors

```python
# Verify inputs
assert initial_investment > 0, "Investment must be positive"
assert discount_rate > 0 and discount_rate < 1, "Invalid discount rate"

# Handle edge cases
if len(cash_flows) == 0:
    raise ValueError("Cash flows cannot be empty")
```

### IRR Convergence Issues

```python
# IRR may not converge for certain cash flow patterns
try:
    irr_result = npf.irr(cash_flows)
except:
    print("IRR could not be calculated (no solution or multiple solutions)")
```

## Integration with OpenClaw Model Routing

```json
{
  "skills": {
    "financial-calculator": {
      "model": "claude-3-5-haiku-20241022",
      "reason": "Cost-effective for standard calculations"
    },
    "financial-calculator:analysis": {
      "model": "claude-3-5-sonnet-20241022",
      "reason": "Better reasoning for financial insights"
    }
  }
}
```

## Source References

- **cashflows**: Python library for financial calculations
- **numpy-financial**: NumPy financial functions
- **Financial modeling best practices**: CFA Institute standards

## Additional Resources

- Corporate Finance Institute: https://corporatefinanceinstitute.com/
- Investopedia: https://www.investopedia.com/
- NumPy Financial: https://numpy.org/numpy-financial/
- Pandas Financial Analysis: https://pandas.pydata.org/
