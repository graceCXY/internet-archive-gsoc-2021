# import 
import pcre
import strutils except strip
import nre

import streams
import json

import httpclient
import htmlparser
import xmltree

# import libutils

import parsecsv
import tables

import nimpy/nimpy
let np = pyImport("numpy")
let a = np.mean([1, 2, 3])
# let f = np.sin(a)
echo "numpy check"
echo a

# let pytz = pyImport("pytz")
# echo "pytz check"

# let six = pyImport("six")
# echo "six check"

# let bs4 = pyImport("bs4")
# echo "bs4 check"

# let beautifulsoup = pyImport("BeautifulSoup")
# echo "beautiful soup check"

# let python_dateutil = pyImport("dateutil")
# echo "python dateutil check"

let pd = pyImport("pandas")
# let df_temp = pd.DataFrame({"A": 1, "B": 2})
echo "pandas check"
# echo df_temp

# let regex = pyImport("re")
# echo "regex check"

# let tzlocal = pyImport("tzlocal")
# echo "tzlocal check"

# let dateparser = pyImport("dateparser")
# var parsed_date = dateparser.parse("June 2008")
# echo "dateparser Check"
# echo parsed_date


# Declare variables 
const
    ### change this part for different alias for different languages 
    journal_aliases = ["journal", "newspaper", "magazine", "work", "website", "periodical", 
                        "encyclopedia", "encyclopaedia", "dictionary", "mailinglist", "dergi", "gazete", 
                       "eser", "çalışma", "iş", "websitesi", "süreliyayın", "ansiklopedi", "sözlük", "program"]
    
    date_aliases = ["date", "air-date", "airdate", "tarih"]
    
    year_aliases = ["year", "yıl", "sene"]
    
    volume_aliases = ["volume", "cilt"]
    
    issue_aliases = ["issue", "number", "sayı", "numara"]

    page_aliases = ["p", "page", "s", "sayfa"]
    pages_aliases = ["pp", "pages", "ss", "sayfalar"]

    url_aliases = ["url", "URL", "katkı-url", "chapter-url", "contribution-url", "entry-url", "article-url", "section-url"]

    title_aliases= ["title", "başlık"]

    doi_aliases = ["doi", "DOI", "pmid", "PMID", "jstor"]


# Parsing a wikipedia citation data
proc parse_citation_data(citation: string): tuple = 
    var cite = replace(citation, re"[{}]", "")
    var citation_list = cite.split("|")

    var journal = ""
    var sim_id = ""
    var volume = ""
    var issue = ""
    
    var title = ""
    var page = ""
    
    var url = ""
    var doi = ""
    
    var date = ""
    # var month_str = ""
    var year = 0
    
    for f in citation_list:
        var field = strip(f)
        
        # find journal title
        for j_a in journal_aliases:
            var journal_regex = j_a & "(\\s{0,})="
            if field.match(re(journal_regex)).isSome:
                journal = field.split("=")[1].strip()
                journal = replace(journal, re"[^A-Za-z0-9 ]+", "")
                # if journal != "":
                #     sim_id = journal.toLowerAscii()
                #     var sim_id_lst = sim_id.split(" ")
                #     sim_id = join(sim_id_lst, "-")
                #     sim_id = "sim_" & sim_id
                break
   
#         # find journal volume 
        for v_a in volume_aliases:
            var volume_regex = v_a & "(\\s{0,})="
            if field.match(re(volume_regex)).isSome:
                volume = field.split("=")[1].strip()
                volume = replace(volume, re"[^0-9]+", "")
                break
            
#         # find journal issue
        for i_a in issue_aliases:
            var issue_regex = i_a & "(\\s{0,})="
            if field.match(re(issue_regex)).isSome:
                issue = field.split("=")[1].strip()
                break
        
#         # find journal year
        for y_a in year_aliases:
            var year_regex = y_a & "(\\s{0,})="
            if field.match(re(year_regex)).isSome:
                field = field.split("=")[1].strip()
                date = replace(field, re"[^0-9]+", "")
                try:
                    year = parseInt(date)
                except:
                    year = 0
                break
            
        # find journal date
        for d_a in date_aliases:
            var date_regex = d_a & "(\\s{0,})="
            if field.match(re(date_regex)).isSome:
                field = field.split("=")[1].strip()
                echo "has date"
                try:
                    year = parseInt(field)
                    date = intToStr(year)
                except:
                    echo field
                    # use the python library for parsing
                    # let dateparser = pyImport("dateparser")
                    # var parsed_date = dateparser.parse(field).to(string)
                    # echo parsed_date
                    # if not isEmptyOrWhiteSpace(parsed_date):
                        # if parsed_date.year <= 2021:
                            # if parsed_date.year >= 1800:
                                # year = parsed_date.year
                                # date = intToStr(year)
                        # echo "ahh"

                        # if parsed_date.month < 10:
#                             month = parsed_date.month
#                             month_str = "0" + str(month)
#                         else:
#                             month = parsed_date.month
#                             month_str = str(month)
                            
# # #                         print(month_str)

#                         if month_str != "":
#                             date = date + "-" + month_str 
                break
        
        # find existing url
        for u_a in url_aliases:
            var url_regex = u_a & "(\\s{0,})="
            if field.match(re(url_regex)).isSome:
                url = field.split("=")[1].strip()
                break
            
        # find page field 
        for p_a in page_aliases:
            var page_regex = p_a & "(\\s{0,})="
            if field.match(re(page_regex)).isSome:
                page = field.split("=")[1].strip()
                if "[" in page:
                    page = ""
                break
                
        # find pages field
        for ps_a in pages_aliases:
            var pages_regex = ps_a & "(\\s{0,})="
            if field.match(re(pages_regex)).isSome:
                var pages = field.split("=")[1].strip()
                if "[" in pages:
                    break
                else:
                    if "-" in pages:
                        page = pages.split("-")[0].strip()
                    elif "–" in pages:
                        page = pages.split("–")[0].strip()
                    else:
                        page = ""   
                break
                
        # find page field 
        for t_a in title_aliases:
            var title_regex = t_a & "(\\s{0,})="
            if field.match(re(title_regex)).isSome:
                title = field.split("=")[1].strip()
                if "[" in title:
                    title = ""
                break
                
        # find field 
        for doi_a in doi_aliases:
            var doi_regex = doi_a & "(\\s{0,})="
            if field.match(re(doi_regex)).isSome:
                doi = field.split("=")[1].strip()
                break  

    var result = (journal: journal, sim_id: sim_id, date: date, year: year, 
            volume: volume, issue: issue, title: title, page: page, 
            url: url, doi: doi)
    
    return result


# ### make sure year is within range and not one of those na
# def within_year_range(row, year):
#     first = row['First Volume']
#     last = row['Last Volume']
#     gaps = row['NA Gaps']
#     if first != np.nan and last != np.nan:
#         if year > first and year < last:
#             if gaps != np.nan and gaps != "":
#                 gaps = str(gaps)
#                 gaps_list = gaps.split(";")
#                 for gap in gaps_list:
#                     if gap.strip() == str(year):
#                         return False
#                 return True
#             return True
#     return False


### generate sim ids
proc generate_sim_ids(journal: string): seq[string] =

    # special characters
    var result = "";
    if contains(journal, "/"): # turn / into -
        result = replace(journal, re"/", "");
    if contains(journal, "-"): # drop - first so that we can join with - later
        result = replace(journal, re"-", " ");
    if contains(journal, "["): # ignore what's in between '[' and ']'
        var index_front = find(journal, "[")
        var index_back = find(journal, "]")
        if index_back > index_front:
            result = journal[0 .. index_front] & journal[index_back .. journal.len]
        else:
            result = journal[0 .. index_front]
    if contains(journal, "="): # ignore what comes after =
        result = journal.split("=")[0]
    
    if result == "":
        result = journal

    result = replace(result, re"[^A-Za-z0-9 ]+", "")
    var sim_ids: seq[string];
    if result != "":
        var sim_id = journal.toLowerAscii();
        var sim_id_lst = sim_id.split()
        
        if sim_id_lst[0] == "the":
            var sim_id_without_the = join(sim_id_lst[1 .. sim_id_lst.len], "-")
            sim_id_without_the = "sim_" & sim_id_without_the
            sim_ids.add(sim_id_without_the)
            
        sim_id = join(sim_id_lst, "-")
        sim_id = "sim_" & sim_id
        
        sim_ids.add(sim_id)
    return sim_ids


proc perform_advanced_search(identifier:string): seq[string] =

    var url_head = "https://archive.org/advancedsearch.php?q="
    var url_tail = "&fl%5B%5D=identifier&sort%5B%5D=&sort%5B%5D=&sort%5B%5D=&rows=5000&page=1&output=json&callback=callback&save=yes"
    var url_search = url_head & identifier & url_tail

    var cookiefile = "cookies.txt"
    var search_res = runShellBasic("wget --load-cookies " & shquote(cookiefile) & " -q -O- " & shquote(url_search))
    search_res = strip(search_res)

    var response = search_res[9..search_res.len-2]
    var response_json = parseJson(response)["response"]
    echo type(response_json)

    var nums = response_json["numFound"].getInt();

    if nums == 0: 
        return @[];

    var result: seq[string];
    for item in response_json["docs"]:
        result.add(item["identifier"].getStr())

    return result


proc find_close_match_from_cite_info(cite_info:tuple, search_result:seq[string], verbose = false): string =
    
    var close_matches: seq[string];
    for possible_id in search_result:
        var possible_id_list = possible_id.split("_")
        
        if len(possible_id_list) < 4:
            continue;
        
        if cite_info.issue != "" and possible_id_list.len >= 5:
            
            if verbose: 
                echo "longer than 5";
            
            # Check that it is sim
            if possible_id_list[0] == "sim":
                
                # Check that journal name matches
                if possible_id_list[1] == cite_info.sim_id[4..cite_info.sim_id.len-1]:
                    
                    # Check that year/date is within other case
                    if contains(possible_id_list[2], intToStr(cite_info.year)):
                        
                        # Check that journal volume matches
                        if possible_id_list[3] == cite_info.volume:
                            
                            # Check that journal issue matches
                            if possible_id_list[4] == cite_info.issue:
                                close_matches.add(possible_id)
                                continue;
                                
                            if verbose: 
                                echo "Not the right issue";
                            continue;
                            
                        if verbose: 
                            echo "Not the right volume";
                        continue;
                        
                    if verbose: 
                        echo "Not the right year";
                    continue;
                    
                if verbose: 
                    echo "Possible id journal name not exact match";
                continue;
                
            if verbose: 
                echo "Possible id is not in sim";
            continue;
            
        if len(possible_id_list) == 4:
            
            if verbose: 
                echo "equal to 4";
            
            # Check that it is sim
            if possible_id_list[0] == "sim":
                
               # Check that journal name matches
                if possible_id_list[1] == cite_info.sim_id[4..cite_info.sim_id.len-1]:
                    
                    # Check that year/date is within other case
                    if contains(possible_id_list[2], intToStr(cite_info.year)):
                        
                        # Check that journal volume matches
                        if possible_id_list[3] == cite_info.volume:
                            close_matches.add(possible_id)
                            
                        if verbose: 
                            echo "Not the right volume";
                        continue;
                        
                    if verbose: 
                        echo "Not the right year";
                    continue;
                    
                if verbose: 
                    echo "Possible id journal name not exact match";
                continue;
                            
            if verbose: 
                echo "Possible id is not in sim";
            continue;
            
    if verbose: 
        echo "close matches: ";
        echo close_matches
                    
    if close_matches == @[]:
        return ""
    
    return close_matches[0]


proc generate_url_actual(identifier:string): string =
    return "https://archive.org/details/" & identifier


proc load_sim_info(): seq[tuple[pubIssueId:string, title:string, yearGaps:string, firstVolume:string, lastVolume:string]] = 
    var parser: CsvParser
    parser.open("SIM_info.csv")
    parser.readHeaderRow()
    echo parser.headers

    var result: seq[tuple[pubIssueId:string, title:string, yearGaps:string, firstVolume:string, lastVolume:string]]
    while parser.readRow():
        var curr: tuple[pubIssueId:string, title:string, yearGaps:string, firstVolume:string, lastVolume:string]
        curr.pubIssueId = parser.rowEntry("PubIssueID")
        curr.title = parser.rowEntry("Title")
        curr.yearGaps = parser.rowEntry("NA Gaps")
        curr.firstVolume = parser.rowEntry("First Volume")
        curr.lastVolume = parser.rowEntry("Last Volume")
        result.add(curr)
        
    parser.close()

    return result

# proc load_sim_ids(): seq[string]

proc main(citation:string, doi_filter = false, verbose = false): string = 
    
    var cite_info = parse_citation_data(citation)

    if verbose:
        echo "The citation info are as follow: ";
        echo cite_info;
    
    # make sure there's no existing url 
    if cite_info.url != "":
        echo "There is already an existing url.";
        return ""
    
    if doi_filter and cite_info.doi != "":
        echo "There is already an existing doi link.";
        return ""

    # check citation has all desired info
    if (cite_info.journal == "" or cite_info.year == 0) or (cite_info.volume == "" or cite_info.page == ""):
        echo "Citation has incomplete info.";
        return ""
    
    # load all sim information 
    var all_sim = load_sim_info();

    # Generate sim ids 
    var possible_sim_ids = generate_sim_ids(cite_info.journal)
    var sim_id = "";
    
    echo all_sim
    echo type(all_sim[0])
    block checkID:
        for serial in all_sim:
            for poss_id in possible_sim_ids:
                # check in collection
                if poss_id == serial.pubIssueId:
                    # check within year range
                    if cite_info.year > parseInt(serial.firstVolume) and cite_info.year < parseInt(serial.lastVolume):
                        if contains(serial.yearGaps, intToStr(cite_info.year)) == false:
                            sim_id = poss_id
                            break checkID
    
    cite_info.sim_id = sim_id
    
    if cite_info.sim_id != "":
        # generate a id
        var gen_id = cite_info.sim_id & "_" & intToStr(cite_info.year)
            
        if verbose: 
            echo "Gen id: " & gen_id
            
        # find all entries with this journal name
        var search_result = perform_advanced_search(gen_id)
            
        if verbose: 
            echo "search results: ";
            echo search_result

        if search_result != @[]:

            # find close match on generated id
            var real_id = find_close_match_from_cite_info(cite_info, search_result)
                
            if verbose:
                echo "real id: "; 
                echo real_id;

            if real_id != "":

                # new citation
                var url = generate_url_actual(real_id)
                echo "url: ";
                echo url;
                return url
                
            echo "No close match exist for ids. The id is " & gen_id
            return ""
                
        echo "There's no search result for the id: " & gen_id;
        return ""
    
    echo "Citation not in SIM collection."
    return "" 

var test_cite1 = "{{Akademik dergi kaynağı|url=|başlık=Large-scale analysis of the yeast proteome by multidimensional protein identification technology|erişimtarihi=|yazarlar=Washburn|tarih=Mart 2001|sayı=3|dil=En|sayfalar=242-247|çalışma=Nature Biotechnology|yayıncı=|cilt=19}}"
var test_cite2 = ""
echo main(test_cite1, verbose = true);

# var test_cite = "{{Akademik dergi kaynağı|url=|başlık=Large-scale analysis of the yeast proteome by multidimensional protein identification technology|erişimtarihi=|yazarlar=Washburn|tarih=Mart 2001|sayı=3|dil=En|sayfalar=242-247|çalışma=Nature Biotechnology|yayıncı=|cilt=19}}"
# var result_tuple = parse_citation_data(test_cite);
# echo result_tuple;
# echo result_tuple.year

# var sim_ids = generate_sim_ids(result_tuple.journal)
# echo sim_ids

# result_tuple.sim_id = sim_ids[0]
# echo result_tuple

# var identifier = "sim_nature-biotechnology_2001"
# var search_result = perform_advanced_search(identifier)
# echo search_result

# var actual_id = find_close_match_from_cite_info(result_tuple, search_result);
# echo generate_url_actual(actual_id)

# try:
#   ## Input (somefile.txt):
#   ## The first line
#   ## the second line
#   ## the third line
#   var strm = openFileStream("output_log_1_150.txt")
#   echo strm.readLine()
#   ## Output:
#   ## The first line
#   strm.close()
# except:
#   stderr.write getCurrentExceptionMsg();

# let file = open("cookie.txt");


# # let f = open("data.txt")
# defer: 
#     file.close()


proc old_login(): string =
    var strm = openFileStream("cookie.txt");
    var login_data_raw = strm.readAll();
    var login_data = parseJson(login_data_raw);

    strm.close();
    
    var client = newHttpClient()
    client.headers = newHttpHeaders({ "Content-Type": "application/json" })

    var login_url = "https://archive.org/account/login"
    # var login_res = client.request(login_url, httpMethod = HttpPost, body = $login_data)
    # echo login_res.status

    var identifier = "sim_nature-biotechnology_2001"
        
    var url_head = "https://archive.org/advancedsearch.php?q="
    var url_tail = "&fl%5B%5D=identifier&sort%5B%5D=&sort%5B%5D=&sort%5B%5D=&rows=5000&page=1&output=json&callback=callback&save=yes"
    var url_search = url_head & identifier & url_tail

    var search_headers = newHttpHeaders()
    search_headers["username"] = "gracec@archive.org";
    search_headers["password"] = "graceCXY";
    search_headers["remember"] = "true";
    search_headers["referer"] = "https://archive.org/advancedsearch.php";
    search_headers["submit-to-login"] = "Log in";

    let gethtml = request(client, login_url, HttpGet, "", search_headers)
    var stream = newStringStream(gethtml.body)
    var html = htmlparser.parseHtml(stream);

    var login_field_value = "";
    for elem in html.findAll("input"):
        if elem.attr("name") == "login":
            echo "yes"
            echo elem
            echo elem.text
            login_field_value = elem.text
            # echo login_field_value

    search_headers["login"] = login_field_value

    # search_headers["login"] = html.findAll("input", attrs = {"name":"login"})["value"]

    # echo search_headers


    # var request = client.request(url_search, httpMethod = HttpGet, body = $login_data, headers= search_headers)
    # echo request.status
    # echo request.body
    

