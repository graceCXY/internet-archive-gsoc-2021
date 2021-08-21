# Google Summer of Code 2021 -- Internet Archive
#### Grace Chen

This repository is a collection of research I had done for various aspects of different probelms during my time as a GSoC intern for the Internet Archive. I worked in the Turn All References Blue team and learned so much about specific tooling the organization, and the open source community! 

More polished python command line tools can be seen at 
https://github.com/graceCXY/wiki-journal-link
https://github.com/graceCXY/iso4-abbrev-expander


## Projects 
### Wikipedia Journal Links
My main task was to explore different methods of automating the process of adding journal links to Wikipedia citations, from the serials in microfilms collection and the database of scholar.archive.org. 

Input citations: download from https://tools-static.wmflabs.org/botwikiawk/xcite/xcite.html 
SIM_info.csv: information on the collection installed from a google sheet (not in this repo)

#### Data Analysis
Sim_Metadata_Parsing.ipynb: analyzing the data we have, understand properties and edge cases.

Wikipedia_Dump_Parsing.ipynb: analyzing the data we have, understand commonalities and edge cases.


#### Initial Attempt 
URL_generation.ipynb: experimentation with the url format of the archive.org by generating links via a particular pattern and checking whether these links exist. 

run_deadlink_checker.php: calling the deadlink checker program 

composer.json: supporting file for deadlink checker 
composer.lock: supporting file for deadlink checker
composer.phar: supporting file for deadlink checker


### Preprocessing 
Citation_Preprocessing.ipynb: all preprocessing steps, including parse and normalize.


#### Serial in Microfilms 
Using_Advanced_Search.ipynb: Experimentation with the advanced search elastic search endpoint using identifiers. Results were very useful to the end product.

Citation_Pipeline.ipynb: Builds upon Using_Advanced_Search.ipynb and yields great result for SIM. It is a fairly robust citation pipeline: parse, filter, search, generate. 

url_gen.nim: A nim version of Citation_Pipeline. I wanted it to be directly callable by LAMP (a nim project) but encountered some difficulties with libraries unique to python so the script is not fully operational.


#### Fatcat and Scholar 
Scholar_Query.ipynb: An attempt to use the scholar.archive.org's full text elastic search system to generate results, and later verify these results with a fatcat client command line tool. I realized that this process was too inefficient so it is paused in the middle. 

Fatcat_Query.ipynb: An attempt to use fatcat's Elastic Search endpoint to generate results, verify, and link to scholar based on the work id. The notebook include different ways of acheiving the same thing as well as explanations for design choices. This process was enventually adopted and incorporated into the general pipeline.

#### End Product 
The final product is a pipeline that consists of both the serials in microfilms processes as well as the fatcat and scholar process to output a url that can be sent to LAMP to be added on. 
Read more or view the python command line tool at https://github.com/graceCXY/wiki-journal-link.

### Autourl Verification 
On Wikipedia, automatic url generation for citation templates is not as simple as a boolean value in the url or external identifier field. After researching into this issue, my approach was to use Wikimedia's parse endpoint and html parsing to decide if an url is automatically generated. 

Autourl_Verfication.ipynb: research script with thought process and documentation. 
autourl_check.py: python script.
autourl_check.nim: nim script. (can be ran by LAMP directly since it is in nim)

### Summary of tools 
During my research phase, I learned about a variety of internal and external tools that are currently being used or can be potentially useful for the team. I compiled an inventory of summary, discussing the general idea behind these programs, what they can be used for, and important side notes to keep in mind. 

### Abbreviation Expansion
This subproject originated from my attempt to improve the normalization module of the main task. It attempts to tackle a very niche problem but also general usage beyond this project. Not only can the project be used by others in this space when working with abbreviated journal names, the work also inspired my interest in NLP and the general concept of recovering lost semantic meaning in text. I can see myself working on this well beyond this summer. 

The bulk of the work lies in de-abbreviate.ipynb. The journal abbreviation folder also contains some useful data.

Read more or view the python command line tool at https://github.com/graceCXY/iso4-abbrev-expander.


## Credits 

This had been my first exposure to the open source community and I am beyond grateful for the help I received throughout my time at the Internet Archive. I would like to especially thank Mark Graham, my mentor, for all the wonderful resources and guidance throughout the summer, Stephen for guiding me through complications big and small in this space, Martin for helping me navigate fatcat and scholar as well as answering my random questions, Max for setting up the deadlink checker for me, Karim for providing me great packaging resources and narrowing my focus, as well as the rest of my team! My summer would not have been half as memorable without you! Thank you so much!
