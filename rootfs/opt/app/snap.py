#!/usr/bin/env python3

from selenium import webdriver
import selenium
import time
import sys
import os

# total arguments
# We need 2 arguments - the website URL (argv[1]) and the ICAO (argv[2])
if len(sys.argv) != 3:
    sys.exit('Expected use: snap.py <tar1090 base url> <icao>')

urlraw = sys.argv[1]
icao = sys.argv[2]

def get_screenshot(urlraw, icao, fname='screenshot.png'):
    #url = f"https://globe.adsbexchange.com/?icao={icao}"
    #url = f'https://globe.adsbexchange.com/?icao={icao}&zoom=11&hideSidebar&hideButtons'
    url = f'{urlraw}?icao={icao}&zoom=11&hideSidebar&hideButtons&mapDim=0'

    zoom = 75

    co = selenium.webdriver.chrome.options.Options()
    co.add_argument("--delay 5")
    co.add_argument("--headless")
    co.add_argument("--no-sandbox")
    co.add_argument("--incognito")
    co.add_argument(f'window-size=1200x1600')
    browser = selenium.webdriver.Chrome(options=co)

    browser.get(url)
    #elems = browser.find_elements_by_css_selector("#map_canvas canvas")
    #if not len(elems):
    #  raise Exception("no elements found (eg missing map canvas)")
    #elif not elems[0].is_displayed():
    #  raise Exception(f"have {len(elems)}, but the first isn't displayed")

    #browser.execute_script(f"document.body.style.zoom='{zoom}%'")

    time.sleep(5)
    br = browser.save_screenshot(fname)
    # print(f"done {br}")

    browser.quit()

    return fname

f = get_screenshot(urlraw, icao, fname='/tmp/snap.png')
os.system('chmod a+r /tmp/snap.png')
# print(f)
