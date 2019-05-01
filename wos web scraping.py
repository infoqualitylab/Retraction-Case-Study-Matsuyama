#!/usr/bin/env python
# coding: utf-8

# Install a pip package in the current Jupyter kernel
## import sys
## !{sys.executable} -m pip install beautifulsoup4
## !{sys.executable} -m pip install selenium

from selenium import webdriver
from selenium.webdriver.support.ui import Select
import time
import os
from os import listdir
import pandas as pd

def remove_punc(title):
    # remove punctuations in title
    punctuations = '''![]{};:'"\,<>./?@#$%^&*_~'''
    my_str = title

    no_punct = ""
    for char in my_str:
       if char not in punctuations:
           no_punct = no_punct + char
    return no_punct

def open_wos(title, netid, pw):
    # remove punctuation
    title = remove_punc(title)
    searchtitle = '"' + title + '"'
    # open Web of Science
    url = "http://apps.webofknowledge.com.proxy2.library.illinois.edu/WOS_GeneralSearch_input.do?product=WOS&search_mode=GeneralSearch&SID=5CzMx7AeqrOibrRiEIE&preferencesSaved="
    chromedriver = 'C:/Users/diye4/Desktop/Python/chromedriver_win32/chromedriver'
    chrome = webdriver.Chrome(chromedriver)
    chrome.get(url)

    # login by using NetID and Password
    username = chrome.find_element_by_id("j_username")
    password = chrome.find_element_by_id("j_password")
    username.send_keys(netid)
    password.send_keys(pw)
    chrome.find_element_by_name("_eventId_proceed").click()

    # search the article
    search = chrome.find_element_by_name("value(input1)")
    search.send_keys(searchtitle)
    chrome.find_element_by_class_name("searchButton").click()
    chrome.find_element_by_css_selector("div.search-results-data-cite").click()

    # get articles that cited it
    time.sleep(1)
    timecited = chrome.find_element_by_xpath("//a[@title='View all of the articles that cite this one']")
    link = timecited.get_attribute("href")
    chrome.get(link)

    # View the citation report
    report = chrome.find_element_by_xpath("//a[@title='View Citation Report']")
    reportlink = report.get_attribute("href")
    chrome.get(reportlink)

    # open the window
    chrome.find_element_by_xpath("//select[@id='cr_saveToMenuBottom']/option[text()='Save to Excel File']").click()
    # download the file
    # chrome.find_element_by_xpath('//*[@id="ui-id-7"]/form/div[2]/span/button').click()
    chrome.find_element_by_xpath('//*[@id="numberOfRecordsRange"]').click()
    chrome.find_element_by_xpath('//*[@id="exportButton"]').click()
    chrome.close()
    # rename the file
    time.sleep(7)
    dir1 = 'C:\\Users\\diye4\\Downloads\\savedrecs.xls'
    dir2 = 'C:\\Users\\diye4\\Downloads\\' + title + '.xls'
    os.rename(dir1, dir2)
    print('finished: ' + title)

# find target title xls in the directory
def findxls(path_to_dir, title):
    title = remove_punc(title)
    filenames = listdir(path_to_dir)
    return [filename for filename in filenames if filename.startswith(title)]

# clean the xls file
def cleanxls(path_to_dir, titlexls):
    titledir = path_to_dir + titlexls
    df = pd.read_excel(titledir)
    df.columns = df.loc[26]
    df = df[27:]
    return(df)

def mergexls(path_to_dir, title):
    xls = findxls(path_to_dir, title)
    df = cleanxls(path_to_dir, xls[0])
    if len(xls) >= 2:
        for titlexls in xls[1:]:
            df = df.append(cleanxls(path_to_dir, titlexls))
    return(df)

def movexls(path_to_dir, title):
    xls = findxls(path_to_dir, title)
    title = remove_punc(title)
    new_path_to_dir = path_to_dir + title + "\\"
    os.mkdir(new_path_to_dir)
    if len(xls) >= 2:
        for titlexls in xls:
            dir1 = path_to_dir + titlexls
            dir2 = new_path_to_dir + titlexls
            os.rename(dir1, dir2)
    print("Put " + title + " into the folder")


# put title of first-generation articles into the function to get sg articles from WOS
def getcitingarticles(path_to_dir, title, netid, pw):
    open_wos(title, netid, pw)
    df = mergexls(path_to_dir, title)
    movexls(path_to_dir, title)
    df.to_csv(path_to_dir + title + ".csv", index = False)
    print("Merged csv is put in the directory.")


netid = "netid"
pw = "password"
path_to_dir = "C:\\Users\\diye4\\Downloads\\"
title = "Effects of Omega-3 Polyunsaturated Fatty Acids on Inflammatory Markers in COPD"
# first-generation articles
# getcitingarticles(path_to_dir, title, netid, pw)


df = pd.read_csv(path_to_dir + title + ".csv")
titles = df[df["Total Citations"] > 0]["Title"]
def getsgarticles(path_to_dir, titles, netid, pw, start = 0, end = len(titles)):
    for title in titles[start:end]:
        getcitingarticles(path_to_dir, title, netid, pw)

# getsgarticles(path_to_dir, titles, netid, pw, 0, 3)
