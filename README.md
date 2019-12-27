# Retraction-Case-Study-Matsuyama
The directory contains the following files:
* FinalData
* FinalDataCode: R code for all network diagrams and timeline
* Python Code: extracting first-generation and second-generation article metadata automatically via Web of Science updated on **December 26, 2019**
* Google Scholar nodes.csv
* Google Scholar edges.csv
* R code for network diagrams

**Python code**

Before using the code:
* You need to download a Chrome Webdriver from http://chromedriver.chromium.org/downloads based on your laptop and the Chrome version.
* Put the Chrome Webdriver in a local file and put its path later into Python code.
* You need to install Python module Selenium.

In Anaconda Prompt:
```bash
pip install Selenium
```
* You need to enter your netid and password
* You need to change the directory where you want to store the data
* You will need to revise the code for your purpose

**Python Files**
* get_metadata.ipynb: run using Jupyter Notebook
* get_metadata_on_VPN.py: run using Anaconda Prompt/Terminal - Same functionality as get_metadata.py, but assumes that you are on-campus or using VPN with Group 4_TunnelAll_2FA_Duo (which requires username/password/and authentication preference push,sms,phone - definitely works with phone).
* get_metadata.py: run using Anaconda Prompt/Terminal - NOTE: This doesn't work with 2FA.
```bash
python get_metadata.py
```
Follow the instruction by entering NetID, password, 
```bash
Enter NetId:
Enter Password:
Enter Article Title: 
Enter Chrome Driver Path (similar to 'C:/Users/diye4/Desktop/Python/chromedriver_win32/chromedriver'): 
Enter the path for the downloaded file (similar to "C:\\Users\\diye4\\Downloads\\"): 
```

The code can do the following:
* Get the citing articles for a article by downloading metadata XLS file to your local directory (For my Windows laptop, the xls file is stored in "Downloads")
* Clean the XLS file by excluding the first 26 rows which contain the plots and other information and creating a new cleaned csv file
* Rename the CSV file to the article title you searched for




Notes:
* It is possible that a title contains multiple search results. Please be cautious about the XLS file downloaded. If the XLS file is not what you want, please manually download the XLS file.
* The website keeps changing. To verify whether the code is working, please run the function get_metadata line by line. If one line of the code is not working, you can use Chrome to Web of Science, right click "inspect", locate the element, and right click to copy the element xpath and put the xpath into the code.
* The WOS article websites might have different website structures, meaning that it is likely that the code that works for one article might not work for others. 
* BeautifulSoup is a good module for web scraping. However, I didn't find a way for BeautifulSoup to deal with the shibboleth authentication request. 

