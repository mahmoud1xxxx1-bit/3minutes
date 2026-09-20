from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import time

chrome_options = Options()
chrome_options.add_argument('--headless')
chrome_options.set_capability('goog:loggingPrefs', {'browser': 'ALL'})

driver = webdriver.Chrome(options=chrome_options)
driver.get('http://localhost:8123/')
time.sleep(5)

print('Clicking Onet Connect...')
try:
    # We can inject JS to click the list tile for Onet Connect
    driver.execute_script('''
        let elements = document.querySelectorAll('flt-semantics');
        for (let el of elements) {
            if (el.getAttribute('aria-label') && el.getAttribute('aria-label').includes('Onet Connect')) {
                el.click();
                return;
            }
        }
    ''')
except Exception as e:
    print('Failed to click:', e)

time.sleep(5)
print('Logs after clicking:')
for entry in driver.get_log('browser'):
    if entry['level'] == 'SEVERE':
        print(entry)
driver.quit()
