# ETHMINER
Industry: Cryptocurrency, Monero

Target OS: Linux

License: open source

Website: https://github.com/ethereum-mining/ethminer; https://www.ethermine.org; 

Notes: This is a cryptocurrency miner designed to mine ETH (Ethereum). Specifically, it targets Nvidia GPU platforms. It will not work for CPU mining. 

Environment varaibles:

SCHEME
	Options:
		- http
		- stratum+tcp
		- stratum1+tcp
		- stratum2+tcp

WALLET
	Options:
		- must be a valid Etherum wallet address
		
WORKERNAME
	Options:
		- alphanumerical name (i.e. bigIron)

PASSWORD
	Options:
		- this is optional, usually not required for most mining pools

POOLNAME
	Options:
		- eu1.ethermine.org:4444 stratum
		- asia1.ethermine.org:4444, stratum
		- us1.ethermine.org:4444, stratum (east)
		- us2.ethermine.org:4444, stratum (west)

PORT
	Options:
		- see pool for port specification
		
ethminer -U --pool stratum+tcp://0xf12dEe43BBB573aD5fF4f0Dc773fE3e729e0a95B.bigIron@us2.ethermine.org:4444