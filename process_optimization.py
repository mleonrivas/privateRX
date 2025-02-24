import csv
import os
import re
import subprocess
import sys
from pathlib import Path
from datetime import datetime
from decimal import Decimal

FOLDER = "./optimizations/data"
# execute git rev-parse HEAD
def main():
    opt_name = ""
    offset: int = 0
    for arg in sys.argv:
        if arg.startswith('--name='):
            opt_name = arg.removeprefix('--name=')
        if arg.startswith('--offset='):
            offset = int(arg.removeprefix('--offset='))

    if opt_name == "":
        print("ERROR: MISSING --name= argument")
        exit(-1)
    
    process_opt_file(f"{FOLDER}/{opt_name}.htm", offset)


def process_opt_file(f: str, offset: int) -> str:
    print(f"procesing test {f}")
    content = Path(f).read_text(encoding='cp1252').replace("\n", "")
    #print(content)
    initial_deposit = Decimal(re.match(r'.*<tr align=left><td colspan=2>Depósito inicial</td><td colspan=4>([0-9\.]+)</td></tr>', content).group(1))
    
    period_match = re.match(r'.*<tr align=left><td colspan=2>Período</td><td colspan=4>.*\((\d\d\d\d\.\d\d\.\d\d) - (\d\d\d\d\.\d\d\.\d\d)\)</td></tr>', content)
    start_date = datetime.strptime(period_match.group(1), '%Y.%m.%d')
    end_date = datetime.strptime(period_match.group(2), '%Y.%m.%d')
    period = Decimal(round(float((end_date - start_date).days)/365.0, 1))
    rows = re.findall(r'<tr(?: bgcolor="#E0E0E0")? align=right>(.*?)<\/tr>', content)
    print(f"ROWS = {len(rows)}")
    data = []
    for row in rows:
        data_row = process_row(row, initial_deposit, period, offset)
        data.append(data_row)
    
    with open(f"{f}.csv", 'w') as csvfile:
        fieldnames = ['test_num', 'ts_history_size', 'ts_distances_increase', 'ts_price_point_percentage', 'net_benefits', 'final_balance', 'initial_deposit', 'test_years', 'total_transactions', 'benefit_factor', 'expected_benefit', 'dd_amount', 'dd_percent', 'total_profit_percent', 'avg_year_profit_percent', 'avg_year_profit_vs_dd_ratio']
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(data)

def process_row(row: str, initial_deposit: Decimal, period: Decimal, offset: int):
    ### SAMPLE ROW:
    # <tr bgcolor="#E0E0E0" align="right">
    #    <td title="TS_STAT_HistorySize=35; TS_W_DistancesIncreasePercent=0.1; TS_PricePointPercentage=0.1; THREAD_RandomSeed=1; ATRFREQ_WeeksForFrequentATR=1; SH_ENT_EntropyCoeficient=1; THREAD_AtrFreqPeriod=14; THREAD_AtrFreqBandPercentage=0.33; MM_MaxGlobalRisk=0.4; MM_RiskPerOperation=0.001; MM_MinCompensationFactor=1.1; MM_MaxCompensationFactor=1.4; MM_StepDecay=0.1; TS_HA_HistorySize=1400; TS_StaticTargetDistance=6.4; TS_StaticCoverDistance=6; RW_LoopDivisions=13; RW_MaxStepsPerRecovery=5; RW_MaxNestedRecoveries=0; RW_AcceptLossesOnEnd=1; RW_TrailingBufferFactor=0.3; RW_RecordStats=0; FT_HourStart=14; FT_HourEnd=22; FT_AtrPeriod=14; EXPERT_TestThreadWithoutRecovery=0; EXPERT_EnableFilters=0; ">4</td>
    #    <td class="mspt">-3294.82</td>
    #    <td>184</td>
    #    <td class="mspt">0.69</td>
    #    <td class="mspt">-17.91</td>
    #    <td class="mspt">3825.66</td>
    #    <td class="mspt">25.17</td>
    # </tr>
    ###
    #print(f"PROCESSING ROW: {row}")
    first_match = re.match(r'.*<td title=\"TS_STAT_HistorySize=([0-9\.]+); TS_W_DistancesIncreasePercent=([0-9\.]+); TS_PricePointPercentage=([0-9\.]+); [^>]+>([0-9]+)</td>', row)
    ts_history = first_match.group(1)
    ts_distances_increase = first_match.group(2)
    ts_price_point = first_match.group(3)
    test_num = offset + int(first_match.group(4))

    second_match = re.match(r'.*<td class=mspt>([0-9\.-]+)</td><td>([0-9\.-]+)</td><td class=mspt>([0-9\.-]+)</td><td class=mspt>([0-9\.-]+)</td><td class=mspt>([0-9\.-]+)</td><td class=mspt>([0-9\.-]+)</td>', row)
    benefits = Decimal(second_match.group(1))
    transactions = int(second_match.group(2))
    benefit_factor = second_match.group(3)
    expected_benefit = second_match.group(4)
    dd_amount = second_match.group(5)
    dd_percent = Decimal(second_match.group(6))

    total_profit_percent: Decimal = round((((initial_deposit + benefits)/initial_deposit) - Decimal(1))*Decimal(100), 2)
    total_result: Decimal = ((initial_deposit + benefits)/initial_deposit)
    avg_year_profit_percent = round((pow(total_result, Decimal(1)/period) - Decimal(1)) * Decimal(100), 2)
    avg_year_profit_vs_dd_ratio = round(avg_year_profit_percent / dd_percent, 2)

    return {
        'test_num': test_num,
        'ts_history_size': ts_history,
        'ts_distances_increase': ts_distances_increase,
        'ts_price_point_percentage': ts_price_point,
        'net_benefits': benefits,
        'final_balance': (initial_deposit + benefits),
        'initial_deposit': initial_deposit,
        'test_years': period,
        'total_transactions': transactions,
        'benefit_factor': benefit_factor,
        'expected_benefit': expected_benefit,
        'dd_amount': dd_amount,
        'dd_percent': dd_percent,
        'total_profit_percent': total_profit_percent,
        'avg_year_profit_percent': avg_year_profit_percent,
        'avg_year_profit_vs_dd_ratio': avg_year_profit_vs_dd_ratio
    }

def delete_files(name):
    os.unlink(f"{FOLDER}/{name}.htm")
    os.unlink(f"{FOLDER}/{name}.gif")

if __name__ == "__main__":
    main()
