import requests
import json
import argparse
import glob

def scanproject():
    try:
        file_list = (glob.glob("**/*.tf", recursive=True))
        print ('files to be scanned {}'.format(file_list))
    except Exception as e:
        print("Error parsing files {}".format(e))

    for file in file_list:
        scan(file,'no')
    return



def scan(filename,displayjson):
    url = 'https://scan.api.redlock.io/v1/iac'
    # url = 'https://vscanapidoc.redlock.io/scan.sh'
    file = filename
    highsevlist = []
    medsevlist = []
    lowsevlist = []
    with open(file,"rb") as f:
        data = f.read().strip()


    response = requests.post(url, data=data)
    respdict = json.loads (response.content)
    if 'rules_matched' in respdict['result']:
        resultslist = respdict['result']['rules_matched']
        if displayjson =='yes':
            print ('Response body is \n\n{}'.format(respdict))

        for result in resultslist:
            if result['severity'] == 'high':
                highsevlist.append(result)
            elif result['severity'] == 'medium':
                medsevlist.append(result)
            elif result['severity'] == 'low':
                lowsevlist.append(result)
            else:
                print ('Didnt understand severity {}'.format(result['severity']))
        if len(highsevlist) > 0:
            print ('\n\n\n#### Template file {} requires modification ####'.format(filename))
            print ('High Severity Items Found')
            for item in highsevlist:
                printitems(item)
        if len(medsevlist) > 0:
            print ('\nMedium Severity Items Found')
            for item in medsevlist:
                printitems(item)
        if len(lowsevlist) > 0:
            print ('\nLow Severity Items Found')
            for item in lowsevlist:
                printitems(item)

def printitems(item):
    print('Problem: {}'.format(item['name']))


if __name__ == '__main__':
    """
    Input arguments
    Mandatory -f filename
    Optional -d dump raw json output
    """
    parser = argparse.ArgumentParser(description='Get Terraform Params')
    parser.add_argument('-d', '--displayjson', help='Display json response yes/no', default='no')
    parser.add_argument('-f', '--filename', help='File', required=True)
    parser.add_argument('-t','--scan_tf_project', help='Scan entire tf project', default='no')
    args = parser.parse_args()
    filename = args.filename
    displayjson = args.displayjson
    scan_tf = args.scan_tf_project
    if scan_tf == 'yes':
        scanproject()
    else:
        scan(filename,displayjson)

