pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "../Debot.sol"; // <== import "../../HelloDebotProject/Debot.sol";
import "../Terminal.sol";
import "../Menu.sol";
import "../AddressInput.sol";
import "../ConfirmInput.sol";
import "../Upgradable.sol";
import "../Sdk.sol";
import "../Interfaces/Transactable.sol";
import "../Interfaces/ShoppingListInterface.sol";
import "../HasConstructorWithPubKey.sol";

abstract contract AListInitDeBot is Debot, Upgradable {

    TvmCell shoppingListStateInit;
    address listAddress;
    uint32 purchaseId;
    uint256 my_PubKey;
    address walletForPayment;
    SummaryPurchase summary;
    uint32 INITIAL_BALANCE =  200000000;

    function getDebotInfo() public functionID(0xDEB) override view returns(
        string name, string version, string publisher, string key, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "Test DeBot";
        version = "0.0.1";
        publisher = "publisher name";
        key = "How to use";
        author = "Author name";
        support = address.makeAddrStd(0, 0x000000000000000000000000000000000000000000000000000000000000);
        hello = "Hello, i am an test DeBot.";
        language = "en";
        dabi = m_debotAbi.get();
        icon = '';
    }

    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [ Terminal.ID, Menu.ID, AddressInput.ID, ConfirmInput.ID ];
    }

    
    
    function onCodeUpgrade() internal override {
        tvm.resetStorage();
    }

    function setShoppingCode(TvmCell code, TvmCell data) public {

        require(msg.pubkey() == tvm.pubkey(), 101);
        tvm.accept();
        shoppingListStateInit = tvm.buildStateInit(code, data);

    }

    function start() public override {

        Terminal.input(tvm.functionId(savePublicKey), "Please enter your public key", false);
    }
    

    function savePublicKey(string value) public {

        (uint res, bool status) = stoi("0x" + value);
        if (status) {
            my_PubKey = res;

            Terminal.print(0, "Checking if you already have a shopping list ...");
            TvmCell deployState = tvm.insertPubkey(shoppingListStateInit, my_PubKey);
            listAddress = address.makeAddrStd(0, tvm.hash(deployState));
            Terminal.print(0, format( "Info: your shopping list contract address is {}", listAddress));
            Sdk.getAccountType(tvm.functionId(checkAccauntStatus), listAddress);

        } else {
            Terminal.input(tvm.functionId(savePublicKey), "Wrong public key. Try again!\nPlease enter your public key", false);
        }
    }

    function checkAccauntStatus(int8 acc_type) public {

        if (acc_type == 1) {
            
            _getSummary(tvm.functionId(setSummary));

        } else if (acc_type == -1)  { // acc is inactive
            Terminal.print(0, "You don't have a ShoppingList yet, so a new contract with an initial balance of 0.2 tokens will be deployed");
            AddressInput.get(tvm.functionId(selectWalletForPayment), "Select a wallet for payment. We will ask you to sign two transactions");

        } else  if (acc_type == 0) { // acc is uninitialized
            Terminal.print(0, format(
                "Deploying new contract. If an error occurs, check if your ShoppingList contract has enough tokens on its balance"
            ));
            deploy();

        } else if (acc_type == 2) {  // acc is frozen
            Terminal.print(0, format("Can not continue: account {} is frozen", listAddress));
        }
    }

    function selectWalletForPayment(address value) public {
        walletForPayment = value;
        optional(uint256) pubkey = 0;
        TvmCell empty;
        Transactable(walletForPayment).sendTransaction {
            abiVer: 2,
            extMsg: true,
            sign: true,
            pubkey: pubkey,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(waitForDeploying),
            onErrorId: tvm.functionId(onErrorRepeatWalletChoosing)
        }(listAddress, INITIAL_BALANCE, false, 3, empty);
    }

    function onErrorRepeatWalletChoosing(uint32 sdkError, uint32 exitCode) public {
        sdkError;
        exitCode;
        selectWalletForPayment(walletForPayment);
    }

    function waitForDeploying() public {

        Sdk.getAccountType(tvm.functionId(checkContractIsDeployed), listAddress);

    }

    function checkContractIsDeployed(int8 acc_type) public {

        if (acc_type == 0) {

            deploy();

        } else {
            
            waitForDeploying();
        }

    }

    function deploy() private view {
        
        TvmCell image = tvm.insertPubkey(shoppingListStateInit, my_PubKey);
        optional(uint256) none;
        TvmCell deployMsg = tvm.buildExtMsg({
            abiVer: 2,
            dest: listAddress,
            callbackId: tvm.functionId(onSuccess),
            onErrorId:  tvm.functionId(onErrorRepeatDeploy),
            time: 0,
            expire: 0,
            sign: true,
            pubkey: none,
            stateInit: image,
            call: {AShoppingList, my_PubKey}
        });
        
        tvm.sendrawmsg(deployMsg, 1);
    }

    function onSuccess() public view {

        _getSummary(tvm.functionId(setSummary));
    }

    function onErrorRepeatDeploy(uint32 sdkError, uint32 exitCode) public view {

        sdkError;
        exitCode;
        deploy();
    }

    function setSummary(SummaryPurchase _summary) virtual public {}

    function _getSummary(uint32 answerId) internal view {
        optional(uint256) none;
        ShoppingListInterface(listAddress).getSummary {
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: answerId,
            onErrorId: 0
        }();
    }

}