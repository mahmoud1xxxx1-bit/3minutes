from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
import time

chrome_options = Options()
chrome_options.add_argument('--headless')
chrome_options.set_capability('goog:loggingPrefs', {'browser': 'ALL'})

driver = webdriver.Chrome(options=chrome_options)
driver.get('http://localhost:8123/')
time.sleep(10)
try:
    buttons = driver.find_elements(By.TAG_NAME, 'flt-semantics')
    for b in buttons:
        if 'Onet' in b.get_attribute('aria-label') or '8' in b.get_attribute('aria-label'):
            b.click()
            break
except Exception as e:
    print('Click failed', e)

time.sleep(5)
print('Logs:')
for entry in driver.get_log('browser'):
    print(entry)
driver.quit()
