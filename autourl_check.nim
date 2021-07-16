import strutils
import regex
import uri
import httpclient
import json


### BACK story of autourls 
# https://en.wikipedia.org/wiki/User:GreenC/testcases/autourl
# 
# {{tlx|cite journal}} will auto-generate a URL in the {{para|url}} field under some conditions eg. 
# when {{para|doi-access|free}} and {{para|url}} is otherwise empty. My question is, do other templates auto-generate {{para|url}}?  
# The conditions are not important, only knowledge of which templates are capable of auto-generating URLs in the {{para|url}} field (for whatever reason). 
# Is it possible {{tlx|cite magazine}} can auto-generate a URL?  Or any of the other CS1|2 templates? 
# -- [[User:GreenC|<span style="color: #006A4E;">'''Green'''</span>]]
# [[User talk:GreenC|<span style="color: #093;">'''C'''</span>]] 
# 16:01, 15 July 2021 (UTC)
#
# No.  Only {{tlx|cite journal}} supports this because the identifiers that are the source for the url (currently {{para|pmc}} and {{para|doi}}) 
# typically apply to journal articles.  It has been suggested that {{para|doi}} with {{para|doi-access|free}} might be applied to chapters of books or entries in encyclopedia. 
# So far as I know, there has been no effort undertaken to accomplish this or to even determine if we should support {{para|chapter}} / {{para|entry}} autolinking from {{para|doi}}.  
# I think that there has also been a suggestion to autolink {{para|title}} in {{tlx|cite book}} from {{para|hdl}} but again, just the suggestion.
# :—[[User:Trappist the monk|Trappist the monk]] ([[User talk:Trappist the monk|talk]]) 16:12, 15 July 2021 (UTC)



### perform http request 
# INPUT:
## language: wikipedia language (ex.en, tr)
## citation: the citation input ({{cite journal}})
## verbose: debug mode 
# OUTPUT:
## json string
proc get_wikimedia_json(language:string, citation:string, verbose = false): string = 
    
    ### build url
    var url_header = "https://" & language & ".wikipedia.org/w/api.php?action=parse&text="
    var url_content = encodeUrl(citation, usePlus = false)
    var url_param = "&contentmodel=wikitext&format=json"
    
    var url = url_header & url_content & url_param
    
    ### debug
    if verbose: echo url
    
    ### make http request
    var client = newHttpClient(timeout = 20000)
    var response = client.getContent(url)
    
    # if response.status_code != 200:
    #     return ""
    
    # return response.text
    return response



### find html element strings with href 
# INPUT:
## json: json string returned by wikipedia parse
# OUTPUT:
## list of html strings with href 
proc find_html_lst_from_json(response_text:string, verbose = false): seq[string] = 

    var res_json = parseJson(response_text)
    var html_json_node = res_json["parse"]["text"]["*"]
    var html_str = html_json_node.getStr()

    if verbose: echo html_str
    
    var html_tags = findAndCaptureAll(html_str, re"<[^>]*>")
    
    if verbose: echo html_tags
    
    var has_href: seq[string]
    for tag in html_tags:
        if tag.contains("href"):
            has_href.add(tag)
    
    return has_href

### find html element strings with href 
# INPUT:
## list of html strings with href 
# OUTPUT:
## list of urls
proc find_urls(html_lst:seq[string], verbose = false): seq[string] =
    
    var urls: seq[string]
    for element in html_lst:
        var elem1 = replace(element, "<", "")
        var element = replace(elem1, ">", "")

        var attr_lst = element.split()
        
        if verbose: echo attr_lst
            
        for attr in attr_lst:
            
            if attr.contains("="):
                var field_name = attr.split("=")[0].strip()
                var field_content = attr.split("=")[1].strip()
                
                if verbose:
                    echo attr
                    echo field_name
                    echo field_content
                    
                if "href" == field_name or field_name.contains("href"):
                    
                    if verbose: echo "it's href"
                    
                    var url_regex = re"\/\/[a-zA-Z0-9]+\.[^\s]{2,}"
        
                    if contains(field_content, url_regex):
                
                        if verbose: 
                            echo "match"
                        
                        urls.add(field_content)
                        break
                    else: 
                        if verbose: echo "href content is not url"
                        
    return urls


### Main function to checking if auto url exists
# Input:
## language: wikipedia language (ex.en, tr)
## citation: the citation input ({{cite journal}})
# Output:
## Boolean: True or False
proc autourl_exists(citation:string, language = "en", verbose = false): bool = 
    
    var res_json = get_wikimedia_json(language, citation, verbose)
    
    var html_lst = find_html_lst_from_json(res_json, verbose)
    
    var urls = find_urls(html_lst, verbose)
    
    if urls == @[] or urls.len() == 0:
        return false
    
    return true


### Step by step 
## has auto
var test_cite1 = "{{cite journal |title=The Discodermia calyx Toxin Calyculin A |last1=Edelson |first1=Jessica R. |last2=Brautigan |first2=David L. |date=24 January 2011 |journal=Toxins |volume=3 |issue=1 |pages=105–119 |doi=10.3390/toxins3010105 |doi-access=free |pmid=22069692 |pmc=3210456}}"
var test_json =  get_wikimedia_json("en", test_cite1)
var html_lst = find_html_lst_from_json(test_json)
var urls = find_urls(html_lst)
echo urls
## no auto
var test_cite2 = "{{Akademik dergi kaynağı|başlık=Masked priming with graphemically related forms: Repetition or partial activation?|sayı=2|sayfalar=211-251|çalışma=The Quarterly Journal of Experimental Psychology A|yıl=1987|cilt=39A}}"
var test_json2 =  get_wikimedia_json("tr", test_cite2)
var html_lst2 = find_html_lst_from_json(test_json2)
var urls2 = find_urls(html_lst2)
echo urls2


### Main function
## example of having autogenerated url 
echo autourl_exists(test_cite1, "en")

## example of having no autogenerated url
echo autourl_exists(test_cite2, "tr")

        