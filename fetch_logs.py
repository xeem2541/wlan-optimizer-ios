import urllib.request
import json
import zipfile
import io

url = "https://api.github.com/repos/xeem2541/wlan-optimizer-ios/actions/runs"
req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
response = urllib.request.urlopen(req)
data = json.loads(response.read().decode('utf-8'))
latest_run = data['workflow_runs'][0]
logs_url = latest_run['logs_url']

print("Logs URL:", logs_url)

req = urllib.request.Request(logs_url, headers={'User-Agent': 'Mozilla/5.0'})
response = urllib.request.urlopen(req)
z = zipfile.ZipFile(io.BytesIO(response.read()))
for filename in z.namelist():
    if "Build App" in filename or "Build Archive" in filename:
        print("Found:", filename)
        content = z.read(filename).decode('utf-8')
        print(content[-3000:])
