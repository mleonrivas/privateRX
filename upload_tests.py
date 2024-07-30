import boto3
import os
import re
import subprocess
import sys
from pathlib import Path
from datetime import datetime

FOLDER = "./backtests"
# execute git rev-parse HEAD
def main():
    test_files = os.listdir(FOLDER)
    for f in test_files:
        if  f.endswith('.htm'):
            new_name = process_test_file(f)
            upload_test(new_name)
            delete_files(new_name)


def process_test_file(f: str) -> str:
    print(f"procesing test {f}")
    content = Path(f"{FOLDER}/{f}").read_text(encoding='cp1252').replace("\n", "")
    #print(content)
    symbol = re.match(r'.*<td colspan=2>Símbolo<\/td><td colspan=4>([a-zA-Z0-9-_\.]+)', content).group(1)
    periodMatch = re.match(r'.*<td colspan=2>Período<\/td><td colspan=4>.*\(([A-Z0-9]+)\).*\((\d\d\d\d\.\d\d.\d\d) - (\d\d\d\d\.\d\d.\d\d)\)', content)
    timeframe = periodMatch.group(1)
    start_date = datetime.strptime(periodMatch.group(2), '%Y.%m.%d')
    end_date = datetime.strptime(periodMatch.group(3), '%Y.%m.%d')
    period = round(float((end_date - start_date).days)/365.0, 1)
    start_balance = float(re.match(r'.*<td>Depósito inicial<\/td><td align=right>([\d\.]+)', content).group(1))
    net_profit = float(re.match(r'.*<td>Beneficio neto total<\/td><td align=right>([\d\.]+)', content).group(1))
    profit_percent = round(net_profit*100/start_balance, 2)
    max_drawdown = re.match(r'.*<td>Drawdown máximo<\/td><td align=right>[\d\.]* \(([\d\.]+)%\)', content).group(1)
    commit = subprocess.run(['git', 'rev-parse', 'HEAD'], stdout=subprocess.PIPE).stdout.decode('utf-8').strip()
    
    nowst = datetime.now().strftime('%Y%m%d-%H%M')
    name = f"{symbol}_{timeframe}_{nowst}_{period}Y_{profit_percent}_{max_drawdown}_{commit}"

    #rename files
    image_name = f"{f.removesuffix('.htm')}.gif"
    content = content.replace(image_name, f"{name}.gif")
    os.rename(f"{FOLDER}/{f}", f"{FOLDER}/{name}.htm")
    os.rename(f"{FOLDER}/{image_name}", f"{FOLDER}/{name}.gif")
    Path(f"{FOLDER}/{name}.htm").write_text(content, encoding='cp1252')
    print(f"Renamed test to: {name}")
    return name

def upload_test(name: str):
    profile = ""
    for arg in sys.argv:
        if arg.startswith('--profile='):
            profile = arg.removeprefix('--profile=')

    if profile == "":
        print("ERROR: MISSING --profile=NAME argument")
        exit(-1)

    session = boto3.Session(profile_name=profile)
    client = session.client('s3')
    client.upload_file(f"{FOLDER}/{name}.htm", 'ibt-quant-recoveryx-tests-data', f"{name}.htm", ExtraArgs={'ContentType': 'text/html'})
    client.upload_file(f"{FOLDER}/{name}.gif", 'ibt-quant-recoveryx-tests-data', f"{name}.gif", ExtraArgs={'ContentType': 'image/gif'})
    return

def delete_files(name):
    Path.unlink(f"{FOLDER}/{name}.htm")
    Path.unlink(f"{FOLDER}/{name}.gif")

if __name__ == "__main__":
    main()
