#!/usr/bin/env python
# coding: utf-8

# ## Getting a single article's citing work from Web of Science

# In[1]:


def get_metadata(title, netid, pw, chromedriver_path, file_path):
    # import packages
    from selenium import webdriver
    from selenium.webdriver.support.ui import Select
    import time
    import os
    from os import listdir
    import pandas as pd
    
    ##################################
    # remove punctuations from title #
    ##################################
    def remove_punc(title):
        # remove punctuations in title
        punctuations = '''![]{};:'"\,<>./?@#$%^&*_~'''
        my_str = title

        no_punct = ""
        for char in my_str:
            if char not in punctuations:
                no_punct = no_punct + char
        return no_punct
    
    ####################
    # open wos webpage #
    ####################
    def open_wos(title, netid, pw):
        # remove punctuation
        title = remove_punc(title)
        searchtitle = '"' + title + '"'

        # open Web of Science
        url = "http://apps.webofknowledge.com.proxy2.library.illinois.edu/WOS_GeneralSearch_input.do?product=WOS&search_mode=GeneralSearch&SID=5CzMx7AeqrOibrRiEIE&preferencesSaved="
        chromedriver = chromedriver_path
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
        time.sleep(10)
        chrome.close()

        # rename the file
        time.sleep(7)
        dir1 = file_path + 'savedrecs.xls'
        dir2 = file_path + title + '.xls'
        os.rename(dir1, dir2)
        print('Finished: ' + title)
    
    ######################
    # clean the xls file #
    ######################
    def cleanxls(file_path, title):
        titledir = file_path + title + '.xls'
        df = pd.read_excel(titledir)
        df.columns = df.loc[26]
        df = df[27:]
        df.to_csv(file_path + title + ".csv", index = False)
        print("xls file is cleaned and converted to csv file.")
    
    open_wos(title, netid, pw)
    cleanxls(file_path, title)


# In[ ]:


# Sample
# title = "Effects of Omega-3 Polyunsaturated Fatty Acids on Inflammatory Markers in COPD"
# chromedriver_path = 'C:/Users/diye4/Desktop/Python/chromedriver_win32/chromedriver'
# file_path = 'C:\\Users\\diye4\\Downloads\\'
def main():
    netid = input("Enter NetId: ")
    pw = input("Enter Password: ")
    title = input ("Enter Article Title: ")

    chromedriver_path = input("Enter Chrome Driver Path (similar to 'C:/Users/diye4/Desktop/Python/chromedriver_win32/chromedriver'): ")
    file_path = input("Enter the path for the downloaded file: ")
    print("Start scraping...")
    get_metadata(title, netid, pw, chromedriver_path, file_path)
    
    # continue?
    cont = input("Do you want to continue? (Y/N): ")
    while cont == "Y":
        title = input ("Enter Article Title: ")
        get_metadata(title, netid, pw, chromedriver_path, file_path)
    print("End")

main()

