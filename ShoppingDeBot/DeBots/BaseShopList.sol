pragma ton-solidity >=0.35.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;

import "AListInitDeBot.sol";

abstract contract BaseShopList is AListInitDeBot {
 
    function setSummary(SummaryPurchase _summary) public override {
        summary = _summary;
        _menu();
    }

    function _menu() virtual internal {}

    function onError(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(0, format("Operation failed. sdkError {}, exitCode {}", sdkError, exitCode));
        _menu();
    }


    function showList(uint32 index) public view {
        
        optional(uint256) none;
        ShoppingListInterface(listAddress).getPurchases {
            abiVer: 2,
            extMsg: true,
            sign: false,
            pubkey: none,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(showList_),
            onErrorId: 0
        }();
    }



    function removePurchaseFromList(uint32 index) public {

        if (summary.countOfBoughtPurhases + summary.countOfUnBoughtPurhases > 0) {

            Terminal.input(tvm.functionId(removePurchaseFromList_), "Enter number of purchases: ", false);
        } else {

            Terminal.print(0, "Sorry, you have no purchases to delete");
            _menu();
        }
        
    }

    function removePurchaseFromList_(string value) public {
        
        optional(uint256) pubkey = 0;
        (uint res,) = stoi(value);
        ShoppingListInterface(listAddress).removePurchase {
            abiVer: 2,
            extMsg: true,
            sign: true,
            pubkey: pubkey,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(onSuccess),
            onErrorId: tvm.functionId(onError)
        } (res);
    }

    function showList_(Purchase[] myShoppingList) public {
        
        if(myShoppingList.length > 0) {

            for (uint32 i = 0; i < myShoppingList.length; i++) {

                string completed;

                if (myShoppingList[i].isBought) {

                    completed = "✓";
                    Terminal.print(0, format("{} {}  \"{}\"  at {} (price: {})", myShoppingList[i].id, completed, myShoppingList[i].name, myShoppingList[i].creationDate, myShoppingList[i].price));
                } else {

                    completed = " ";
                    Terminal.print(0, format("{} {}  \"{}\"  at {}", myShoppingList[i].id, completed, myShoppingList[i].name, myShoppingList[i].creationDate));
                }
                
            }
        } else {
            Terminal.print(0, "Your list is empty");
        }
        
        _getSummary(tvm.functionId(upDateSummary));//to update summary, when it changed by another Debot
    }

    function upDateSummary(SummaryPurchase _summary) public {
        
        summary = _summary;
        _menu();
    }
}