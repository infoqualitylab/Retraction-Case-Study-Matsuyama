# Retraction-Case-Study-Matsuyama
The directory contains the following files:
* FinalData
* FinalDataCode: R code for all network diagrams and timeline
* Python code for extracting first-generation and second-generation article metadata automatically via Web of Science updated on **April 26, 2019**
* Google Scholar nodes.csv
* Google Scholar edges.csv
* R code for network diagrams

** Python code**
The code can do the following:
* Get the citing articles for a article by downloading metadata XLS file to your local directory (For my Windows laptop, the xls file is stored in "Downloads")
* Clean the XLS file by excluding the first 26 rows which contain the plots and other information and creating a new cleaned csv file
* Rename the CSV file to the article title you search for

Before using the code:
* You need to download a Chrome Webdriver from http://chromedriver.chromium.org/downloads based on your laptop and the Chrome version.
* You need to install Python module Selenium 
* You need to enter your netid and password
* You need to change the directory where you want to store the data
* You will need to revise the code for your purpose

Notes:
* The website keeps changing. To verify whether the code is working, please run the function open_wos line by line. If one line of the code is not working, you can use Chrome to Web of Science, right click "inspect", locate the element, and right click to copy the element xpath and put the xpath into the code.
* The WOS article websites might have different website structures, meaning that it is likely that the code that works for one article might not work for others. 
* BeautifulSoup is a good module for web scraping. However, I didn't find a way for BeautifulSoup to deal with the shibboleth authentication request. 

