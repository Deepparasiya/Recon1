#! /usr/bin/bash
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
RESET=$(tput sgr0)

echo "${GREEN} ######################################################### ${RESET}"
echo "${GREEN} ###                 STARTING THE TOOL                 ### ${RESET}"
echo "${GREEN} ######################################################### ${RESET}"

echo "${GREEN}
                                                              
  ██▄████   ▄████▄    ▄█████▄   ▄████▄   ██▄████▄ 
  ██▀      ██▄▄▄▄██  ██▀    ▀  ██▀  ▀██  ██▀   ██ 
  ██       ██▀▀▀▀▀▀  ██        ██    ██  ██    ██ 
  ██       ▀██▄▄▄▄█  ▀██▄▄▄▄█  ▀██▄▄██▀  ██    ██ 
  ▀▀         ▀▀▀▀▀     ▀▀▀▀▀     ▀▀▀▀    ▀▀    ▀▀ 
  
                                             CY-8
                                             ${RESET}"



read -p "Do you want to install tools: " i
if [ $i = y ]
then 

installtools


installtools () {


echo "${GREEN} ######################################################### ${RESET}"
echo "${GREEN} ###                INSTALLING DEPENDENCIES            ### ${RESET}"
echo "${GREEN} ######################################################### ${RESET}"



sudo apt-get update -y

sudo apt-get upgrade -y

sudo apt-get install python3 -y

sudo apt-get install pyhton3-pip -y

apt install jq -y

pip3 install censys

echo "${GREEN} [+] Installing Golang ${RESET}"
if [ ! -f /usr/bin/go ];then
    cd ~
    {
    wget -q -O - https://raw.githubusercontent.com/canha/golang-tools-install-script/master/goinstall.sh | bash
  export GOROOT=$HOME/.go
  export PATH=$GOROOT/bin:$PATH
  export GOPATH=$HOME/go
    echo 'export GOROOT=$HOME/.go' >> ~/.bash_profile
    echo 'export GOPATH=$HOME/go' >> ~/.bash_profile
    echo 'export PATH=$GOPATH/bin:$GOROOT/bin:$PATH' >> ~/.bash_profile
    source ~/.bash_profile
    } > /dev/null
else
    echo "${BLUE} Golang is already installed${RESET}"
fi
echo "${BLUE} Done installing Golang ${RESET}"

echo "${RED} INSTALLING SUBFINDER...                  ${RESET}"
apt install subfinder -y

echo "${RED} INSTALLING AMASS...                  ${RESET}"
apt install amass -y

echo "${RED} INSTALLING ANEW...                  ${RESET}"
go install -v github.com/tomnomnom/anew@latest

echo "${RED} INSTALLING GAU...                  ${RESET}"
go install github.com/lc/gau/v2/cmd/gau@latest

echo "${RED} INSTALLING HTTPX...                  ${RESET}"
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest

echo "${RED} INSTALLING NUCLEI...                  ${RESET}"
go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest

nuclei -update -ut
wget https://github.com/0xElkot/My-Nuclei-Templates/blob/main/sqli.yaml
mv sqli.yaml /root/nuclei-templates



echo "${RED} INSTALLING GF...                  ${RESET}"
go install github.com/tomnomnom/gf@latest
git clone https://github.com/1ndianl33t/Gf-Patterns
echo 'source /root/go/src/github.com/tomnomnom/gf/gf-completion.bash' >> ~/.bashrc
source ~/.bashrc
mkdir ~/.gf
cp -r /root/go/src/github.com/tomnomnom/gf/examples ~/.gf
cp Gf-Patterns/*.json ~/.gf

cp ~/go/bin/* /usr/local/bin
cd ../



echo "${RED} INSTALLING URO...                  ${RESET}"
pip3 install uro


}


letshack () {
read -p "ENTER DOMAIN NAME :" DOMAIN

mkdir recon
cd recon

echo "${RED} [+]STARTING HOST DISCOVERY...         ${RESET}"
echo "${RED} [+]COLLECTING IPS...                  ${RESET}"

censys search $DOMAIN --index-type hosts | jq -c '.[] | {ip: .ip }' | cut -d '"' -f4 | httpx  | tee -a ips.txt 


echo "${RED}[+] STARTING SUBDOMAIN ENUMERATION....                  ${RESET}"
subfinder -d $DOMAIN -silent -o subfinder.txt
echo "${RED} [+]RUNNING AMASS...                  ${RESET}"
amass enum -brute -norecursive -noalts -nocolor -active -passive -nolocaldb -d $DOMAIN -o amass.txt 



echo "${RED} FINISHED ENUMERATION....                  ${RESET}"
echo "${RED} [+]Sorting Files...                  ${RESET}"
cat subfinder.txt amass.txt | anew subs.txt

echo "${RED} [+]Sorting Subdomains...                  ${RESET}"
cat subs.txt | httpx | tee -a finalsubs.txt

echo "${RED} [+]Collecting urls...                  ${RESET}"

cat finalsubs.txt | gau | uro |  tee -a urls.txt



#echo "${RED} [+]LOOKING FOR SQL INJECTION...                  ${RESET}"
cat urls.txt | gf sqli | sqliurl.txt
#sqlmap -m sqliurl.txt --batch  -a --level 3 --risk 2 

echo "${RED} [+]LOOKING FOR ERROR-BASED SQL INJECTION...                  ${RESET}"
nuclei -l sqliurl.txt -t sqli.yaml -o nuclei_sqli.txt

echo "${RED} [+]RUNNING NUCLEI...                  ${RESET}"
nuclei -l urls.txt -rl 10 -c 5 

}

#code starts here
read -p "Do you want to install tools(y/n): " i
if [ $i = y ]
then 

installtools

else 

letshack

fi
